#include <jni.h>
#include <android/asset_manager_jni.h>
#include <android/log.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <bit>
#include <atomic>
#include <cstring>
#include <cstdint>
#include <memory>
#include <mutex>
#include <type_traits>
#include <vector>
#include "dynarmic_host.h"
#include "elf_loader.h"
#include "jni_fake_env.h"

// AIR owns scheduling, surfaces and touch coordinates. Preserve that contract.
std::unique_ptr<DynarmicHost> g_host;
JavaVM* g_jvm = nullptr;
JavaVM* GetHostJavaVM() { return g_jvm; }
void RegisterAirImports(DynarmicHost&);

namespace {
constexpr const char* kTag = "BannerSagaBridge";
struct NativeBinding { const char* owner; const char* name; const char* signature; bool is_static; const char* symbol; };
struct NativeClass { const char* owner; const JNINativeMethod* methods; size_t count; };
extern const NativeBinding kBindings[];
std::mutex g_load_mutex;
bool g_loaded = false;

void Throw(JNIEnv* env, const char* message) {
    if (!env->ExceptionCheck()) {
        jclass cls = env->FindClass("java/lang/UnsatisfiedLinkError");
        if (cls) { env->ThrowNew(cls, message); env->DeleteLocalRef(cls); }
    }
}

struct NativeScope {
    FakeJniEnv& jni = FakeJniEnv::Instance();
    bool valid;
    explicit NativeScope(JNIEnv* env) : valid(jni.BeginNativeCall(env)) {}
    ~NativeScope() { if (valid) jni.EndNativeCall(); }
};

template<typename T>
void Push(std::vector<uint32_t>& words, FakeJniEnv& jni, T value) {
    if constexpr (std::is_pointer_v<T>) words.push_back(jni.AddObjectRef(value));
    else if constexpr (sizeof(T) == 8) {
        if (words.size() & 1) words.push_back(0);
        uint64_t bits = std::bit_cast<uint64_t>(value);
        words.push_back(uint32_t(bits)); words.push_back(uint32_t(bits >> 32));
    } else if constexpr (std::is_floating_point_v<T>) words.push_back(std::bit_cast<uint32_t>(value));
    else words.push_back(static_cast<uint32_t>(value));
}

template<size_t Index, typename Result, typename... Args>
Result Forward(JNIEnv* env, jobject receiver, Args... args) {
    if (!g_host || g_host->HasFailed()) {
        Throw(env, "AIR ARM32 guest is unavailable");
        if constexpr (!std::is_void_v<Result>) return {};
        else return;
    }
    NativeScope scope(env);
    if (!scope.valid) {
        Throw(env, "AIR guest JNI frame failed");
        if constexpr (!std::is_void_v<Result>) return {};
        else return;
    }
    const auto& binding = kBindings[Index];
    jclass owner = binding.is_static ? static_cast<jclass>(receiver) : env->GetObjectClass(receiver);
    uint32_t target = scope.jni.FindNative(env, owner, binding.name, binding.signature);
    if (!binding.is_static) env->DeleteLocalRef(owner);
    if (!target) target = g_host->FindLibrarySymbol("libCore.so", binding.symbol);
    if (!target) {
        __android_log_print(ANDROID_LOG_ERROR, kTag, "Missing guest native %s.%s%s", binding.owner, binding.name, binding.signature);
        Throw(env, "AIR guest native was neither exported nor registered");
        if constexpr (!std::is_void_v<Result>) return {};
        else return;
    }
    std::vector<uint32_t> words{scope.jni.EnvTableGuestAddr(), scope.jni.AddObjectRef(receiver)};
    (Push(words, scope.jni, args), ...);
    uint32_t timer_before[5]{};
    const bool timer_snapshot = words.size() == 4 && std::strcmp(binding.name, "callTimeoutFunction") == 0 &&
        g_host->GuestAllocSize(words[2]) >= sizeof(timer_before);
    if (timer_snapshot) std::memcpy(timer_before, g_host->GetGuestMemoryBase() + words[2], sizeof(timer_before));
    uint32_t low = g_host->RunFunction(target, words);
    uint32_t high = g_host->GetResultHigh();
    if constexpr (std::is_same_v<Result, jboolean> && sizeof...(Args) == 10) {
        static std::atomic<unsigned> diagnostics{0};
        if (std::strcmp(binding.name, "nativeOnTouchCallback") == 0 && diagnostics.fetch_add(1) < 24) {
            __android_log_print(ANDROID_LOG_INFO, kTag, "guest touch type=%u x=%.1f y=%.1f id=%u primary=%u array=%08x count=%u result=%u",
                words[2], std::bit_cast<float>(words[3]), std::bit_cast<float>(words[4]), words[6], words[9], words[10], words[11], low);
        }
    }
    if (g_host->HasFailed() || scope.jni.HasFailed()) {
        __android_log_print(ANDROID_LOG_ERROR, kTag, "Failed guest native %s.%s%s entry=%08x arg_words=%zu arg0=%08x arg1=%08x", binding.owner, binding.name, binding.signature, target, words.size(), words.size()>2?words[2]:0, words.size()>3?words[3]:0);
        if (timer_snapshot) {
            __android_log_print(ANDROID_LOG_ERROR, kTag, "Timer before %08x: %08x %08x %08x %08x %08x", words[2], timer_before[0], timer_before[1], timer_before[2], timer_before[3], timer_before[4]);
            const uint32_t live_size = g_host->GuestAllocSize(words[2]);
            __android_log_print(ANDROID_LOG_ERROR, kTag, "Timer after %08x live_size=%u", words[2], live_size);
            if (live_size >= sizeof(timer_before)) {
                std::memcpy(timer_before, g_host->GetGuestMemoryBase() + words[2], sizeof(timer_before));
                __android_log_print(ANDROID_LOG_ERROR, kTag, "Timer after fields: %08x %08x %08x %08x %08x", timer_before[0], timer_before[1], timer_before[2], timer_before[3], timer_before[4]);
            }
        }
        Throw(env, "AIR guest execution failed; see bridge diagnostic");
        if constexpr (!std::is_void_v<Result>) return {};
        else return;
    }
    if constexpr (std::is_void_v<Result>) return;
    else if constexpr (std::is_pointer_v<Result>) return static_cast<Result>(scope.jni.ResolveObject(low));
    else if constexpr (sizeof(Result) == 8) return std::bit_cast<Result>(uint64_t(low) | (uint64_t(high) << 32));
    else if constexpr (std::is_floating_point_v<Result>) return std::bit_cast<Result>(low);
    else return static_cast<Result>(low);
}

#include "air_natives.inc"

struct AssetMapping {
    void* mapping = MAP_FAILED;
    size_t span = 0;
    const uint8_t* data = nullptr;
    size_t size = 0;
    ~AssetMapping() {
        if (mapping != MAP_FAILED) {
            int rc = munmap(mapping, span);
            __android_log_print(rc ? ANDROID_LOG_ERROR : ANDROID_LOG_INFO, kTag, "guest munmap span=%zu result=%d", span, rc);
        }
    }
    bool Open(AAssetManager* assets, const char* name, uint32_t guest_base) {
        std::string path = std::string("guest_libs/") + name;
        AAsset* asset = AAssetManager_open(assets, path.c_str(), AASSET_MODE_RANDOM);
        if (!asset) return false;
        off64_t offset = 0, length = 0;
        int asset_fd = AAsset_openFileDescriptor64(asset, &offset, &length);
        int fd = asset_fd >= 0 ? dup(asset_fd) : -1;
        if (asset_fd >= 0) close(asset_fd);
        AAsset_close(asset);
        if (fd < 0) return false; // STORED assets only; no extraction fallback.
        struct stat info{};
        const size_t page = static_cast<size_t>(sysconf(_SC_PAGESIZE));
        bool valid = page && (page & (page - 1)) == 0 && fstat(fd, &info) == 0 && offset >= 0 && length >= 52 && length <= 64 * 1024 * 1024 && offset <= info.st_size && length <= info.st_size - offset;
        if (!valid) { close(fd); return false; }
        const off64_t aligned = offset & ~off64_t(page - 1);
        const size_t bias = static_cast<size_t>(offset - aligned);
        size = static_cast<size_t>(length); span = size + bias;
        mapping = mmap(nullptr, span, PROT_READ, MAP_PRIVATE, fd, aligned);
        __android_log_print(mapping == MAP_FAILED ? ANDROID_LOG_ERROR : ANDROID_LOG_INFO, kTag,
            "guest mmap: asset=%s fd=%d offset=%lld size=%lld file_size=%lld -> 0x%08x result=%p", path.c_str(), fd, static_cast<long long>(offset), static_cast<long long>(length), static_cast<long long>(info.st_size), guest_base, mapping);
        close(fd);
        if (mapping == MAP_FAILED) return false;
        data = static_cast<const uint8_t*>(mapping) + bias;
        return true;
    }
};

void Bootstrap(JNIEnv* env, jclass, jobject context) {
    std::lock_guard lock(g_load_mutex);
    if (g_loaded) return;
    if (g_host || !context) { Throw(env, "AIR bootstrap is invalid or previously failed"); return; }
    jclass context_class = env->GetObjectClass(context);
    jmethodID get_assets = env->GetMethodID(context_class, "getAssets", "()Landroid/content/res/AssetManager;");
    jobject assets_object = get_assets ? env->CallObjectMethod(context, get_assets) : nullptr;
    AAssetManager* assets = assets_object ? AAssetManager_fromJava(env, assets_object) : nullptr;
    env->DeleteLocalRef(context_class);
    if (!assets || env->ExceptionCheck()) { Throw(env, "AIR AssetManager unavailable"); return; }
    g_host = std::make_unique<DynarmicHost>();
    if (!g_host->Initialize()) { Throw(env, "AIR Dynarmic initialization failed"); return; }
    auto& jni = FakeJniEnv::Instance();
    if (!jni.Init(*g_host)) { Throw(env, "AIR fake JNI initialization failed"); return; }
    NativeScope scope(env);
    if (!scope.valid) { Throw(env, "AIR bootstrap frame failed"); return; }
    struct Module { const char* name; uint32_t base; uint32_t limit; };
    // Dependency constructor order; all images relocate before constructors.
    constexpr Module modules[] = {
        {"libstlport_shared.so", 0x40000000, 0x41000000},
        {"FlashRuntimeExtensions.so", 0x41000000, 0x41100000},
        {"libfmodex.so", 0x41100000, 0x41800000},
        {"libfmodevent.so", 0x41800000, 0x42000000},
        {"libysshared.so", 0x42000000, 0x42800000},
        {"libCore.so", 0x43000000, 0x48000000},
        {"libair.fmod.ane.FmodContext.so", 0x48000000, 0x49000000},
    };
    std::vector<std::unique_ptr<AssetMapping>> mappings;
    std::vector<GuestModuleImage> images;
    for (const auto& module : modules) {
        auto mapping = std::make_unique<AssetMapping>();
        if (!mapping->Open(assets, module.name, module.base)) { Throw(env, "AIR guest ELF must be a valid STORED APK asset"); return; }
        images.push_back({module.name, mapping->data, mapping->size, module.base, module.limit});
        mappings.push_back(std::move(mapping));
    }
    env->DeleteLocalRef(assets_object);
    if (!g_host->LoadModulesFromMemory(images)) { Throw(env, "AIR ELF relocation/constructors failed"); return; }
    mappings.clear();
    uint32_t on_load = g_host->FindLibrarySymbol("libCore.so", "JNI_OnLoad");
    if (!on_load) { Throw(env, "AIR guest JNI_OnLoad is missing"); return; }
    uint32_t version = g_host->RunFunction(on_load, {jni.VmTableGuestAddr(), 0});
    if (g_host->HasFailed() || jni.HasFailed() || (version != JNI_VERSION_1_4 && version != JNI_VERSION_1_6)) {
        Throw(env, "AIR guest JNI_OnLoad failed"); return;
    }
    g_loaded = true;
    __android_log_print(ANDROID_LOG_INFO, kTag, "AIR guest bootstrap complete: modules=7 natives=%zu JNI=0x%x host_bits=%zu page=%ld",std::size(kBindings), version, sizeof(void*) * 8, sysconf(_SC_PAGESIZE));
}
void LoadLibrary(JNIEnv* env,jclass,jstring value) {
    std::lock_guard lock(g_load_mutex);
    if(!g_loaded||!value||g_host->HasFailed()){Throw(env,"AIR guest libraries are unavailable");return;}
    const char* chars=env->GetStringUTFChars(value,nullptr);if(!chars)return;
    const std::string requested(chars);env->ReleaseStringUTFChars(value,chars);
    std::string name="lib"+requested+".so";
    if(!g_host->FindModule(name)&&requested.starts_with("lib"))name=requested+".so";
    if(!g_host->FindModule(name)||!g_host->RunLibraryConstructors(name)){
        __android_log_print(ANDROID_LOG_ERROR,kTag,"Requested guest module is unavailable: %s",name.c_str());
        Throw(env,"Requested AIR guest module is not loaded");
    } else __android_log_print(ANDROID_LOG_INFO,kTag,"AIR requested module ready: %s",name.c_str());
}
} // namespace

extern "C" JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
    g_jvm = vm;
    JNIEnv* env = nullptr;
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) return JNI_ERR;
    auto& jni = FakeJniEnv::Instance(); jni.SetJavaVM(vm);
    jclass bridge = env->FindClass("com/stoicstudio/port/Arm64Bridge");
    if (!bridge || !jni.CacheClassLoader(env, bridge)) return JNI_ERR;
    const JNINativeMethod bootstrap[] = {
        {const_cast<char*>("nativeBootstrap"),const_cast<char*>("(Landroid/content/Context;)V"),reinterpret_cast<void*>(Bootstrap)},
        {const_cast<char*>("loadLibrary"),const_cast<char*>("(Ljava/lang/String;)V"),reinterpret_cast<void*>(LoadLibrary)}
    };
    if (env->RegisterNatives(bridge, bootstrap, 2) != JNI_OK) return JNI_ERR;
    env->DeleteLocalRef(bridge);
    for (const auto& cls : kClasses) {
        jclass owner = env->FindClass(cls.owner);
        if (!owner || !jni.DeclareNatives(env, owner, cls.methods, cls.count) || env->RegisterNatives(owner, cls.methods, static_cast<jint>(cls.count)) != JNI_OK) return JNI_ERR;
        env->DeleteLocalRef(owner);
    }
    __android_log_print(ANDROID_LOG_INFO, kTag, "AIR host registered %zu native declarations on %zu classes; sizeof(void*)=%zu",std::size(kBindings),std::size(kClasses), sizeof(void*));
    return JNI_VERSION_1_6;
}
