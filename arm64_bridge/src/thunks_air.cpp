#include "dynarmic_host.h"
#include "thunk_manager.h"
#include "thunk_types.h"
#include "jni_fake_env.h"
#include <android/bitmap.h>
#include <algorithm>
#include <cmath>
#include <cwchar>
#include <cwctype>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <mutex>
#include <vector>

namespace {
void* Span(DynarmicHost& h, uint32_t p, size_t n) {
    void* value = p ? GuestSpan(h.GetGuestMemoryBase(), h.GetGuestMemorySize(), p, n) : nullptr;
    if (!value) throw std::out_of_range("AIR import guest span");
    return value;
}
const char* Text(DynarmicHost& h, uint32_t p) {
    const char* value = p ? GuestCString(h.GetGuestMemoryBase(), h.GetGuestMemorySize(), p) : nullptr;
    if (!value) throw std::out_of_range("AIR import guest string");
    return value;
}
}

void RegisterAirImports(DynarmicHost& host) {
    auto& thunks = host.GetThunkManager();
    using Jit = Dynarmic::A32::Jit;
    using Host = DynarmicHost;
    // ARM Linux kuser ABI: fixed entry addresses, real atomics, return value and carry flag.
    // Reuse the normal SVC dispatch veneer; the original guest calls these addresses directly.
    auto kernel = [&](const char* name, uint32_t address, ThunkHandler handler) {
        uint32_t veneer = thunks.RegisterThunk(name, std::move(handler));
        host.MemoryWrite64(address, host.MemoryRead64(veneer));
        host.AddExecutableRange(address, 8);
    };
    kernel("__kuser_cmpxchg", 0xffff0fc0, [](Jit& j, Host& h) {
        Span(h, j.Regs()[2], 4);
        bool success = h.MemoryWriteExclusive32(j.Regs()[2], j.Regs()[1], j.Regs()[0]);
        j.Regs()[0] = success ? 0 : 1;
        j.SetCpsr((j.Cpsr() & ~(1u << 29)) | (success ? 1u << 29 : 0));
    });
    kernel("__kuser_cmpxchg64", 0xffff0f60, [](Jit& j, Host& h) {
        Span(h, j.Regs()[0], 8); Span(h, j.Regs()[1], 8); Span(h, j.Regs()[2], 8);
        bool success = h.MemoryWriteExclusive64(j.Regs()[2], h.MemoryRead64(j.Regs()[1]), h.MemoryRead64(j.Regs()[0]));
        j.Regs()[0] = success ? 0 : 1;
        j.SetCpsr((j.Cpsr() & ~(1u << 29)) | (success ? 1u << 29 : 0));
    });
    kernel("__kuser_memory_barrier", 0xffff0fa0, [](Jit&, Host&) { std::atomic_thread_fence(std::memory_order_seq_cst); });
    kernel("__kuser_get_tls", 0xffff0fe0, [](Jit& j, Host& h) { j.Regs()[0] = h.GuestTlsAddress(); });
    host.MemoryWrite32(0xffff0ffc, 5);
    thunks.RegisterSymbol("__kuser_helper_version", 0xffff0ffc);
    thunks.RegisterThunk("strnlen", [](Jit& j, Host& h) { j.Regs()[0] = j.Regs()[1]?strnlen(static_cast<char*>(Span(h, j.Regs()[0], j.Regs()[1])), j.Regs()[1]):0; });
    thunks.RegisterThunk("strndup", [](Jit& j, Host& h) {
        size_t n = j.Regs()[1]?strnlen(static_cast<char*>(Span(h, j.Regs()[0], j.Regs()[1])), j.Regs()[1]):0;
        uint32_t p = h.GuestAlloc(n + 1);
        if (p) { if(n)memcpy(Span(h, p, n + 1), Span(h, j.Regs()[0], n), n); h.MemoryWrite8(p + n, 0); }
        else h.MemoryWrite32(h.GuestErrnoAddress(), ENOMEM);
        j.Regs()[0] = p;
    });
    thunks.RegisterThunk("valloc", [](Jit& j, Host& h) { j.Regs()[0] = h.GuestAlloc(j.Regs()[0], 4096); if (!j.Regs()[0]) h.MemoryWrite32(h.GuestErrnoAddress(), ENOMEM); });
    thunks.RegisterThunk("arc4random", [](Jit& j, Host&) { j.Regs()[0]=arc4random(); });
    thunks.RegisterThunk("__isfinite", [](Jit& j, Host&) { j.Regs()[0] = std::isfinite(ReadDF(j, 0)); });
    thunks.RegisterThunk("lrint", [](Jit& j, Host&) { j.Regs()[0] = static_cast<uint32_t>(static_cast<int32_t>(std::lrint(ReadDF(j, 0)))); });
    thunks.RegisterThunk("hypot", [](Jit& j, Host&) { WriteDF(j, 0, std::hypot(ReadDF(j, 0), ReadDF(j, 1))); });
    thunks.RegisterThunk("coshf", [](Jit& j, Host&) { WriteSF(j, 0, std::cosh(ReadSF(j, 0))); });
    thunks.RegisterThunk("sinhf", [](Jit& j, Host&) { WriteSF(j, 0, std::sinh(ReadSF(j, 0))); });
    thunks.RegisterThunk("iswcntrl", [](Jit& j, Host&) { j.Regs()[0] = iswcntrl(j.Regs()[0]); });
    thunks.RegisterThunk("iswlower", [](Jit& j, Host&) { j.Regs()[0] = iswlower(j.Regs()[0]); });
    thunks.RegisterThunk("iswprint", [](Jit& j, Host&) { j.Regs()[0] = iswprint(j.Regs()[0]); });
    thunks.RegisterThunk("iswpunct", [](Jit& j, Host&) { j.Regs()[0] = iswpunct(j.Regs()[0]); });
    thunks.RegisterThunk("wcscmp", [](Jit& j, Host& h) {
        // Android ARM32 and ARM64 both use 32-bit wchar_t. Bound both terminators.
        auto wide = [&](uint32_t p) { size_t n = 0; for(;;){Span(h,p,(n+1)*4);if(!h.MemoryRead32(p+n*4))break;if(++n>262144)throw std::out_of_range("AIR wchar string");}return static_cast<wchar_t*>(Span(h,p,(n+1)*4)); };
        j.Regs()[0] = wcscmp(wide(j.Regs()[0]), wide(j.Regs()[1]));
    });
    thunks.RegisterThunk("wcsncpy", [](Jit& j, Host& h) {
        uint32_t dest = j.Regs()[0], src = j.Regs()[1], n = j.Regs()[2];
        if(!n)return;
        auto* d = static_cast<wchar_t*>(Span(h, dest, uint64_t(n) * 4));
        size_t length = 0;
        while (length < n) { Span(h, src, (length + 1) * 4); if (!h.MemoryRead32(src + length * 4)) break; ++length; }
        if (length) memcpy(d, Span(h, src, length * 4), length * 4);
        if (length < n) memset(d + length, 0, (n - length) * 4);
        j.Regs()[0] = dest;
    });
    thunks.RegisterThunk("cacheflush", [](Jit& j, Host& h) {
        uint32_t start = j.Regs()[0], end = j.Regs()[1];
        if (end < start || !GuestRangeValid(h.GetGuestMemorySize(), start, uint64_t(end) - start)) { j.Regs()[0] = uint32_t(-1); h.MemoryWrite32(h.GuestErrnoAddress(), EINVAL); return; }
        h.InvalidateGuestCode(start, end - start); j.Regs()[0] = 0;
    });
    thunks.RegisterThunk("AndroidBitmap_getInfo", [](Jit& j, Host& h) {
        auto& fake = FakeJniEnv::Instance(); JNIEnv* env = fake.GetEnv();
        jobject bitmap = fake.ResolveObject(j.Regs()[1]); AndroidBitmapInfo info{};
        int rc = AndroidBitmap_getInfo(env, bitmap, &info);
        if (!rc) memcpy(Span(h, j.Regs()[2], sizeof(info)), &info, sizeof(info));
        env->DeleteLocalRef(bitmap); j.Regs()[0] = rc;
    });
    struct Pixels{jobject owner;void* native;uint32_t guest;size_t size;unsigned locks;};
    struct PixelLocks{std::mutex mutex;std::vector<Pixels> values;};
    auto pixels=std::make_shared<PixelLocks>();
    thunks.RegisterThunk("AndroidBitmap_lockPixels", [pixels](Jit& j, Host& h) {
        const uint32_t out=j.Regs()[2];Span(h,out,4);h.MemoryWrite32(out,0);
        auto& fake=FakeJniEnv::Instance();JNIEnv* env=fake.GetEnv();jobject bitmap=fake.ResolveObject(j.Regs()[1]);
        if(!env||!bitmap){j.Regs()[0]=ANDROID_BITMAP_RESULT_BAD_PARAMETER;return;}
        AndroidBitmapInfo info{};void* native=nullptr;int result=AndroidBitmap_getInfo(env,bitmap,&info);
        size_t size=uint64_t(info.stride)*info.height;
        // ponytail: mirrors are limited to 256 MiB per bitmap; increase after a measured larger AIR caller.
        if(!result&&(!size||size>256*1024*1024))result=ANDROID_BITMAP_RESULT_BAD_PARAMETER;
        if(!result)result=AndroidBitmap_lockPixels(env,bitmap,&native);
        if(!result){
            std::lock_guard lock(pixels->mutex);
            auto it=std::find_if(pixels->values.begin(),pixels->values.end(),[&](const Pixels& p){return env->IsSameObject(bitmap,p.owner);});
            if(it!=pixels->values.end()){
                if(it->size!=size||it->native!=native){AndroidBitmap_unlockPixels(env,bitmap);result=ANDROID_BITMAP_RESULT_BAD_PARAMETER;}
                else{++it->locks;h.MemoryWrite32(out,it->guest);}
            }else{
                uint32_t guest=h.GuestAlloc(size,16);jobject owner=guest?env->NewGlobalRef(bitmap):nullptr;
                if(!guest||!owner){if(guest)h.GuestFree(guest);AndroidBitmap_unlockPixels(env,bitmap);result=env->ExceptionCheck()?ANDROID_BITMAP_RESULT_JNI_EXCEPTION:ANDROID_BITMAP_RESULT_ALLOCATION_FAILED;}
                else{memcpy(Span(h,guest,size),native,size);pixels->values.push_back({owner,native,guest,size,1});h.MemoryWrite32(out,guest);}
            }
        }
        env->DeleteLocalRef(bitmap);j.Regs()[0]=result;
    });
    thunks.RegisterThunk("AndroidBitmap_unlockPixels", [pixels](Jit& j, Host& h) {
        auto& fake=FakeJniEnv::Instance();JNIEnv* env=fake.GetEnv();jobject bitmap=fake.ResolveObject(j.Regs()[1]);
        if(!env||!bitmap){j.Regs()[0]=ANDROID_BITMAP_RESULT_BAD_PARAMETER;return;}
        int result=ANDROID_BITMAP_RESULT_BAD_PARAMETER;
        {
            std::lock_guard lock(pixels->mutex);
            auto it=std::find_if(pixels->values.begin(),pixels->values.end(),[&](const Pixels& p){return env->IsSameObject(bitmap,p.owner);});
            if(it!=pixels->values.end()){
                memcpy(it->native,Span(h,it->guest,it->size),it->size);result=AndroidBitmap_unlockPixels(env,bitmap);
                if(!result&&!--it->locks){h.GuestFree(it->guest);env->DeleteGlobalRef(it->owner);pixels->values.erase(it);}
            }
        }
        env->DeleteLocalRef(bitmap);j.Regs()[0]=result;
    });
}
