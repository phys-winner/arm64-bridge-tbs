#include "dynarmic_host.h"
#include "thunk_manager.h"
#include "jni_fake_env.h"
#include <jni.h>
#include <bit>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <thread>
#include <vector>

std::string g_saved_apk_path, g_saved_files_dir;
static JavaVM* test_vm;
JavaVM* GetHostJavaVM() { return test_vm; }
namespace {
unsigned checks;
#define CHECK(e) do { ++checks; if(!(e)) { fprintf(stderr,"JNI FAIL line %d: %s\n",__LINE__,#e);std::abort(); } } while(0)
uint32_t Text(DynarmicHost& h,const char* text) {
    uint32_t p=h.GuestAlloc(strlen(text)+1);CHECK(p);memcpy(h.GetGuestMemoryBase()+p,text,strlen(text)+1);return p;
}
uint32_t Call(DynarmicHost& h,size_t slot,std::vector<uint32_t> args) {
    args.insert(args.begin(),FakeJniEnv::Instance().EnvTableGuestAddr());
    uint32_t value=h.RunFunction(h.GetThunkManager().FindRegisteredSymbol("jni_env_"+std::to_string(slot*4)),args);
    CHECK(!h.HasFailed()&&!FakeJniEnv::Instance().HasFailed());return value;
}
#define SLOT(n) (offsetof(JNINativeInterface,n)/sizeof(void*))
}
extern "C" JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm,void*) { test_vm=vm;return JNI_VERSION_1_6; }
extern "C" JNIEXPORT void JNICALL Java_BridgeJniRegression_run(JNIEnv* env,jclass cls) {
    DynarmicHost host;CHECK(host.Initialize());
    auto& jni=FakeJniEnv::Instance();jni.SetJavaVM(test_vm);
    CHECK(jni.CacheClassLoader(env,cls));CHECK(jni.Init(host));CHECK(jni.RunSelfChecks());CHECK(jni.BeginNativeCall(env));
    jclass bitmap_class=env->FindClass("android/graphics/Bitmap"),config_class=env->FindClass("android/graphics/Bitmap$Config");CHECK(bitmap_class&&config_class);
    jobject config=env->GetStaticObjectField(config_class,env->GetStaticFieldID(config_class,"ARGB_8888","Landroid/graphics/Bitmap$Config;"));
    jobject bitmap=env->CallStaticObjectMethod(bitmap_class,env->GetStaticMethodID(bitmap_class,"createBitmap","(IILandroid/graphics/Bitmap$Config;)Landroid/graphics/Bitmap;"),2,2,config);CHECK(bitmap);
    uint32_t bitmap_ref=jni.AddObjectRef(bitmap),pixels_out=host.GuestAlloc(8);
    auto bitmap_call=[&](const char* name,std::vector<uint32_t> args){return host.RunFunction(host.GetThunkManager().FindRegisteredSymbol(name),args);};
    CHECK(bitmap_call("AndroidBitmap_lockPixels",{jni.EnvTableGuestAddr(),bitmap_ref,pixels_out})==0);
    uint32_t pixels=host.MemoryRead32(pixels_out);CHECK(pixels);host.MemoryWrite32(pixels,0xff332211);
    CHECK(bitmap_call("AndroidBitmap_unlockPixels",{jni.EnvTableGuestAddr(),bitmap_ref})==0);
    CHECK(bitmap_call("AndroidBitmap_lockPixels",{jni.EnvTableGuestAddr(),bitmap_ref,pixels_out})==0);
    CHECK(host.MemoryRead32(host.MemoryRead32(pixels_out))==0xff332211);
    CHECK(bitmap_call("AndroidBitmap_unlockPixels",{jni.EnvTableGuestAddr(),bitmap_ref})==0);
    env->DeleteLocalRef(bitmap);env->DeleteLocalRef(config);env->DeleteLocalRef(config_class);env->DeleteLocalRef(bitmap_class);
    const uint32_t type=jni.AddObjectRef(cls);
    auto method=[&](const char* name,const char* sig) { uint32_t a=Text(host,name),b=Text(host,sig);uint32_t id=Call(host,SLOT(GetStaticMethodID),{type,a,b});host.GuestFree(a);host.GuestFree(b);CHECK(id);return id; };
    CHECK(Call(host,SLOT(CallStaticByteMethod),{type,method("byteValue","()B")})==uint32_t(-7));
    CHECK(Call(host,SLOT(CallStaticCharMethod),{type,method("charValue","()C")})==0xf123);
    CHECK(Call(host,SLOT(CallStaticShortMethod),{type,method("shortValue","()S")})==uint32_t(-1234));
    const uint32_t float_method=method("floatValue","(F)F");
    const uint64_t promoted=std::bit_cast<uint64_t>(1.25);
    CHECK(Call(host,SLOT(CallStaticFloatMethod),{type,float_method,0,uint32_t(promoted),uint32_t(promoted>>32)})==std::bit_cast<uint32_t>(2.5f));
    uint32_t values=host.GuestAlloc(32,8);host.MemoryWrite32(values,std::bit_cast<uint32_t>(-2.5f));
    CHECK(Call(host,SLOT(CallStaticFloatMethodA),{type,float_method,values})==std::bit_cast<uint32_t>(-5.0f));
    host.MemoryWrite64(values,promoted);
    CHECK(Call(host,SLOT(CallStaticFloatMethodV),{type,float_method,values})==std::bit_cast<uint32_t>(2.5f));
    CHECK(Call(host,SLOT(CallStaticLongMethod),{type,method("mixed","(IFJD)J"),7,0,0x3ff40000,0x55667788,0x11223344,0,0x400c0000})==0x55667788);
    CHECK(host.GetResultHigh()==0x11223344);
    jclass int_class=env->FindClass("BridgeJniRegression$IntField"),text_class=env->FindClass("BridgeJniRegression$TextField");CHECK(int_class&&text_class);
    jobject int_object=env->NewObject(int_class,env->GetMethodID(int_class,"<init>","()V"));
    jobject text_object=env->NewObject(text_class,env->GetMethodID(text_class,"<init>","()V"));CHECK(int_object&&text_object);
    const uint32_t int_type=jni.AddObjectRef(int_class),text_type=jni.AddObjectRef(text_class);
    const uint32_t int_ref=jni.AddObjectRef(int_object),text_ref=jni.AddObjectRef(text_object);
    auto field=[&](uint32_t owner,const char* name,const char* sig,bool is_static=false) {
        uint32_t a=Text(host,name),b=Text(host,sig);uint32_t id=Call(host,is_static?SLOT(GetStaticFieldID):SLOT(GetFieldID),{owner,a,b});
        host.GuestFree(a);host.GuestFree(b);CHECK(id);return id;
    };
    printf("ART instance field ID collision: %s\n",env->GetFieldID(int_class,"value","I")==env->GetFieldID(text_class,"value","Ljava/lang/String;")?"yes":"no");
    const uint32_t int_field=field(int_type,"value","I"),text_field=field(text_type,"value","Ljava/lang/String;");CHECK(int_field!=text_field);
    CHECK(field(int_type,"value","I")==int_field);CHECK(field(text_type,"value","Ljava/lang/String;")==text_field);
    CHECK(Call(host,SLOT(GetIntField),{int_ref,int_field})==0x13572468);
    uint32_t text_value=Call(host,SLOT(GetObjectField),{text_ref,text_field});CHECK(Call(host,SLOT(GetStringLength),{text_value})==11);
    Call(host,SLOT(SetIntField),{int_ref,int_field,42});CHECK(env->GetIntField(int_object,env->GetFieldID(int_class,"value","I"))==42);
    Call(host,SLOT(SetObjectField),{text_ref,text_field,text_value});CHECK(Call(host,SLOT(GetIntField),{int_ref,int_field})==42);
    const uint32_t static_int=field(int_type,"staticValue","I",true),static_text=field(text_type,"staticValue","Ljava/lang/String;",true);CHECK(static_int!=static_text);
    CHECK(Call(host,SLOT(GetStaticIntField),{int_type,static_int})==71);
    CHECK(Call(host,SLOT(GetStringLength),{Call(host,SLOT(GetStaticObjectField),{text_type,static_text})})==12);
    Call(host,SLOT(SetStaticIntField),{int_type,static_int,73});CHECK(Call(host,SLOT(GetStaticIntField),{int_type,static_int})==73);
    env->DeleteLocalRef(int_object);env->DeleteLocalRef(text_object);env->DeleteLocalRef(int_class);env->DeleteLocalRef(text_class);
    uint32_t utf=Text(host,"hello JNI"),string=Call(host,SLOT(NewStringUTF),{utf});CHECK(string);
    CHECK(Call(host,SLOT(GetStringLength),{string})==9);
    uint32_t copied=Call(host,SLOT(GetStringUTFChars),{string,0});CHECK(copied);
    CHECK(!strcmp(reinterpret_cast<char*>(host.GetGuestMemoryBase()+copied),"hello JNI"));
    Call(host,SLOT(ReleaseStringUTFChars),{string,copied});
    uint32_t global=Call(host,SLOT(NewGlobalRef),{string}),weak=Call(host,SLOT(NewWeakGlobalRef),{string});CHECK(global&&weak);
    CHECK(Call(host,SLOT(IsSameObject),{global,weak})==1);
    CHECK(Call(host,SLOT(GetObjectRefType),{global})==JNIGlobalRefType);
    // Recycle more than the old LRU capacity; a still-live global must survive.
    for(unsigned i=0;i<9000;++i) {
        uint32_t local=Call(host,SLOT(NewLocalRef),{global});CHECK(local);
        Call(host,SLOT(DeleteLocalRef),{local});
    }
    CHECK(Call(host,SLOT(GetStringLength),{global})==9);
    CHECK(Call(host,SLOT(PushLocalFrame),{8})==0);
    uint32_t inner=Call(host,SLOT(NewLocalRef),{global});CHECK(inner);
    uint32_t survivor=Call(host,SLOT(PopLocalFrame),{inner});CHECK(survivor);
    CHECK(Call(host,SLOT(IsSameObject),{survivor,global})==1);
    uint32_t array=Call(host,SLOT(NewIntArray),{4});CHECK(array);host.MemoryWrite32(values,42);
    Call(host,SLOT(SetIntArrayRegion),{array,2,1,values});host.MemoryWrite32(values,0);
    Call(host,SLOT(GetIntArrayRegion),{array,2,1,values});CHECK(host.MemoryRead32(values)==42);
    const uint32_t main_env=jni.EnvTableGuestAddr();uint32_t worker_env=0;
    std::thread worker([&] {
        JNIEnv* current=jni.GetEnv();CHECK(current);CHECK(jni.BeginNativeCall(current));worker_env=jni.EnvTableGuestAddr();
        uint32_t class_name=Text(host,"BridgeJniRegression");
        CHECK(Call(host,SLOT(FindClass),{class_name}));host.GuestFree(class_name);
        CHECK(Call(host,SLOT(GetStringLength),{global})==9);
        jni.EndNativeCall();host.ReleaseCurrentThread();jni.ReleaseCurrentThread();
    });worker.join();CHECK(worker_env&&worker_env!=main_env);
    const uint32_t key_slot=host.GuestAlloc(4),counter=host.GuestAlloc(4);
    uint32_t key=0;
    auto posix=[&](const char* name,std::vector<uint32_t> args){return host.RunFunction(host.GetThunkManager().FindRegisteredSymbol(name),args);};
    const uint32_t destructor=host.GetThunkManager().RegisterThunk("test_natural_jni_tls_destructor",[&](auto& jit,auto& h){
        CHECK(jit.Regs()[0]==counter);CHECK(posix("pthread_getspecific",{key})==0);
        JNIEnv* actual=nullptr;CHECK(test_vm->GetEnv(reinterpret_cast<void**>(&actual),JNI_VERSION_1_6)==JNI_OK);
        CHECK(jni.GetEnv()==actual);
        uint32_t local=Call(h,SLOT(NewLocalRef),{global});CHECK(local);
        CHECK(Call(h,SLOT(GetStringLength),{local})==9);Call(h,SLOT(DeleteLocalRef),{local});
        h.MemoryWrite32(counter,h.MemoryRead32(counter)+1);jit.Regs()[0]=0;
    });
    CHECK(posix("pthread_key_create",{key_slot,destructor})==0);key=host.MemoryRead32(key_slot);
    CHECK(posix("pthread_setspecific",{key,0x222})==0);
    for(bool native_first:{false,true}) {
        host.MemoryWrite32(counter,0);
        std::thread automatic([&]{
            if(native_first)CHECK(host.GuestErrnoAddress());
            JNIEnv* current=jni.GetEnv();CHECK(current);CHECK(jni.BeginNativeCall(current));worker_env=jni.EnvTableGuestAddr();
            CHECK(posix("pthread_setspecific",{key,counter})==0);jni.EndNativeCall();
        });automatic.join();
        CHECK(host.MemoryRead32(counter)==1);CHECK(host.GuestAllocSize(worker_env)==0);
        CHECK(posix("pthread_getspecific",{key})==0x222);CHECK(jni.EnvTableGuestAddr()==main_env);
    }
    CHECK(posix("pthread_key_delete",{key})==0);host.GuestFree(key_slot);host.GuestFree(counter);
    printf("PASS automatic TLS callbacks retain ART/JNI references for JNI-first and native-first initialization\n");
    Call(host,SLOT(DeleteWeakGlobalRef),{weak});Call(host,SLOT(DeleteGlobalRef),{global});
    jni.EndNativeCall();host.ReleaseCurrentThread();jni.ReleaseCurrentThread();
    CHECK(!env->ExceptionCheck());printf("PASS %u JNI checks: typed returns, A/V/varargs, references, arrays, worker class loader\n",checks);
}
