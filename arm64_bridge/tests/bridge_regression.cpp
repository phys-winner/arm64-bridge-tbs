#include "dynarmic_host.h"
#include "thunk_manager.h"
#include "thunk_types.h"
#include "elf_loader.h"
#include "thunks_opensles.h"
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/system_properties.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <zlib.h>
#include <algorithm>
#include <atomic>
#include <bit>
#include <cerrno>
#include <cstdio>
#include <cstring>
#include <dlfcn.h>
#include <thread>
#include <vector>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>

void GuestSyncForget(uint32_t address, uint32_t size);
size_t GuestJumpContextCountForTesting();
void TrackGlBufferBinding(GLenum target, GLuint buffer);
GLuint GetBoundGlBuffer(GLenum target);

static bool force_legacy_condition=false;
static std::atomic<unsigned> masked_condition_lookups=0;
extern "C" void* __real_dlsym(void*,const char*);
extern "C" void* __wrap_dlsym(void* handle,const char* name) {
    if(force_legacy_condition&&handle==RTLD_DEFAULT&&name&&
       (strcmp(name,"pthread_cond_clockwait")==0||strcmp(name,"pthread_cond_timedwait_monotonic_np")==0)) {
        ++masked_condition_lookups;return nullptr;
    }
    return __real_dlsym(handle,name);
}

namespace {
unsigned checks=0;
#define CHECK(expr) do { ++checks; if(!(expr)) { fprintf(stderr,"FAIL %s:%d: %s\n",__FILE__,__LINE__,#expr);std::abort(); } } while(0)
uint32_t Text(DynarmicHost& h,const char* text) {
    uint32_t p=h.GuestAlloc(strlen(text)+1);CHECK(p);memcpy(h.GetGuestMemoryBase()+p,text,strlen(text)+1);return p;
}
uint32_t Call(DynarmicHost& h,const char* name,const std::vector<uint32_t>& args={}) {
    uint32_t fn=h.GetThunkManager().FindRegisteredSymbol(name);
    CHECK(fn);uint32_t value=h.RunFunction(fn,args);CHECK(!h.HasFailed());return value;
}
void AbiAndDispatch(DynarmicHost& h) {
    CHECK(h.RunSelfChecks());
    CHECK(!GuestRangeValid(h.GetGuestMemorySize(),UINT32_MAX,SIZE_MAX));
    auto& m=h.GetThunkManager();
    CHECK(m.GetOrCreateThunkAddress("missing_symbol_must_not_succeed")==0);
    CHECK(m.ResolveSymbol("malloc",1)==0);
    CHECK(m.ResolveSymbol("__stack_chk_guard",2)==0);
    uint32_t p=m.RegisterThunk("test_replace",[](auto& j,auto&) { j.Regs()[0]=17; });
    CHECK(h.RunFunction(p)==17);
    CHECK(m.RegisterThunk("test_replace",[](auto& j,auto&) { j.Regs()[0]=42; })==p);
    CHECK(h.RunFunction(p)==42);
    // MRC TPIDRURO and TPIDRURW, independently mutable, bound to current thread.
    uint32_t code=h.GuestAlloc(16);h.AddExecutableRange(code,16);
    h.MemoryWrite32(code,0xee1d0f70);h.MemoryWrite32(code+4,0xe12fff1e);
    h.MemoryWrite32(code+8,0xee1d0f50);h.MemoryWrite32(code+12,0xe12fff1e);
    CHECK(h.RunFunction(code)==h.GuestTlsAddress());h.SetGuestTlsWritable(0x12345678);
    CHECK(h.RunFunction(code+8)==0x12345678);
    CHECK(h.RunFunction(code)==h.GuestTlsAddress());
    // Real ARM SVC 0 getpid path: PUSH preserves r7, POP returns to exit trap.
    uint32_t svc=h.GuestAlloc(16);h.AddExecutableRange(svc,16);
    uint32_t words[]={0xe92d4080,0xe3a07014,0xef000000,0xe8bd8080};
    memcpy(h.GetGuestMemoryBase()+svc,words,sizeof(words));
    CHECK(h.RunFunction(svc)==static_cast<uint32_t>(getpid()));
    uint32_t atomic=h.GuestAlloc(4);h.MemoryWrite32(atomic,5);
    CHECK(Call(h,"__atomic_inc",{atomic})==5&&h.MemoryRead32(atomic)==6);
    CHECK(Call(h,"__atomic_dec",{atomic})==6&&h.MemoryRead32(atomic)==5);
    CHECK(Call(h,"__atomic_cmpxchg",{5,9,atomic})==0&&h.MemoryRead32(atomic)==9);
    CHECK(Call(h,"__atomic_cmpxchg",{5,7,atomic})!=0&&h.MemoryRead32(atomic)==9);
    // Execute the original fixed kernel entries, including both CAS results and CPSR.C.
    CHECK(h.MemoryRead32(0xffff0ffc)==5);
    CHECK(h.RunFunction(0xffff0fe0)==h.GuestTlsAddress());
    CHECK(h.RunFunction(0xffff0fa0,{0x12345678})==0x12345678);
    CHECK(h.RunFunction(0xffff0fc0,{9,11,atomic})==0&&h.MemoryRead32(atomic)==11);
    CHECK(h.CurrentJit().Cpsr()&(1u<<29));
    CHECK(h.RunFunction(0xffff0fc0,{9,13,atomic})!=0&&h.MemoryRead32(atomic)==11);
    CHECK(!(h.CurrentJit().Cpsr()&(1u<<29)));
    uint32_t wide=h.GuestAlloc(24,8);h.MemoryWrite64(wide,0x123456789abcdef0ULL);
    h.MemoryWrite64(wide+8,0x23456789abcdef01ULL);h.MemoryWrite64(wide+16,h.MemoryRead64(wide));
    CHECK(h.RunFunction(0xffff0f60,{wide,wide+8,wide+16})==0&&h.MemoryRead64(wide+16)==h.MemoryRead64(wide+8));
    CHECK(h.CurrentJit().Cpsr()&(1u<<29));
    CHECK(h.RunFunction(0xffff0f60,{wide,wide+8,wide+16})!=0&&h.MemoryRead64(wide+16)==h.MemoryRead64(wide+8));
    CHECK(!(h.CurrentJit().Cpsr()&(1u<<29)));
    printf("PASS ABI, nested calls, thread contexts, dispatch, CP15, ARM syscalls\n");
}
void FastDispatch(DynarmicHost& h) {
    uint32_t code=h.GuestAlloc(8256,4);CHECK(code);h.AddExecutableRange(code,8256);
    const uint32_t a=code+32,b=a+8192,thumb=code+48;
    h.MemoryWrite32(code,0xe12fff11); // BX r1, an indirect guest branch.
    h.MemoryWrite32(a,0xe3a00011);h.MemoryWrite32(a+4,0xe12fff1e);
    h.MemoryWrite32(b,0xe3a0002a);h.MemoryWrite32(b+4,0xe12fff1e);
    h.MemoryWrite16(thumb,0x2007);h.MemoryWrite16(thumb+2,0x4770);
    for(unsigned i=0;i<16;++i) {
        CHECK(h.RunFunction(code,{0,a})==17);
        CHECK(h.RunFunction(code,{0,b})==42); // Same table index, different complete descriptor.
        CHECK(h.RunFunction(code,{0,thumb|1})==7);
    }
    h.MemoryWrite32(a,0xe3a00021);h.InvalidateGuestCode(a,8);
    CHECK(h.RunFunction(code,{0,a})==33&&h.RunFunction(code,{0,b})==42);
    auto& jit=h.CurrentJit();jit.ClearCache();
    CHECK(h.RunFunction(code,{0,a})==33&&h.RunFunction(code,{0,thumb|1})==7);
    jit.SetCpsr(0x10);jit.Regs()[0]=0;jit.Regs()[15]=a;
    CHECK(Dynarmic::Has(jit.Step(),Dynarmic::HaltReason::Step));
    CHECK(jit.Regs()[0]==33&&jit.Regs()[15]==a+4);
    jit.SetCpsr(0x10);jit.Regs()[1]=code;jit.Regs()[15]=code;
    std::thread stop([&jit] { std::this_thread::sleep_for(std::chrono::milliseconds(10));jit.HaltExecution(Dynarmic::HaltReason::UserDefined3); });
    auto reason=jit.Run();stop.join();
    CHECK(Dynarmic::Has(reason,Dynarmic::HaltReason::UserDefined3));
    CHECK(h.RunFunction(code,{0,a})==33);
    printf("PASS native fast dispatch collisions, ARM/Thumb, range/full invalidation, single step and halt\n");
}
void CodeCachePressure(DynarmicHost& h,bool thumb=false) {
    constexpr uint32_t blocks=600000;
    const uint32_t code=h.GuestAlloc(32+blocks*8+4,4);CHECK(code);
    h.AddExecutableRange(code,32+blocks*8+4);
    // Warm a real BL return, then evict its compiled block while that return remains live.
    const uint32_t caller[]={0xe92d4010,0xeb000001,0xe3a0002a,0xe8bd8010,
                             0xe3500000,0x012fff1e,0xea000000,0xe1a00000};
    memcpy(h.GetGuestMemoryBase()+code,caller,sizeof(caller));
    const uint16_t thumb_caller[]={0xb510,0x4798,0x202a,0xbd10,0x2800,0xd001,0x4710,0xbf00,0x4770};
    if(thumb)memcpy(h.GetGuestMemoryBase()+code,thumb_caller,sizeof(thumb_caller));
    for(uint32_t i=0;i<blocks;++i) {
        h.MemoryWrite32(code+32+i*8,0xe2811001);
        h.MemoryWrite32(code+36+i*8,0xeaffffff);
    }
    h.MemoryWrite32(code+32+blocks*8,0xe12fff1e);
    const uint32_t entry=code|(thumb?1u:0u);
    CHECK(h.RunFunction(entry,{0,0,code+32,(code+8)|1})==42&&!h.HasFailed());
    CHECK(h.RunFunction(entry,{0,0,code+32,(code+8)|1})==42&&!h.HasFailed());
    auto& jit=h.CurrentJit();std::atomic<bool> finished=false;
    std::thread watchdog([&] {
        const auto deadline=std::chrono::steady_clock::now()+std::chrono::seconds(60);
        while(!finished.load()&&std::chrono::steady_clock::now()<deadline)
            std::this_thread::sleep_for(std::chrono::milliseconds(20));
        if(!finished.load())jit.HaltExecution(Dynarmic::HaltReason::UserDefined3);
    });
    const uint32_t result=h.RunFunction(entry,{1,0,code+32,(code+8)|1});finished=true;watchdog.join();
    printf("Cache pressure thumb=%u result=%u r1=%u expected=%u failed=%u\n",thumb,result,jit.Regs()[1],blocks,h.HasFailed());
    CHECK(!h.HasFailed()&&result==42&&jit.Regs()[1]==blocks);
    printf("PASS live guest return after automatic native code-cache eviction\n");
}
void OriginalAirLookup(DynarmicHost& h) {
    // Original AIR lookup/caller around cold044 LR; isolate its Thumb loop and saved-register contract.
    const uint8_t caller_bytes[]={
        0x2d, 0xe9, 0xf0, 0x41, 0x0d, 0x46, 0x16, 0x46, 0x60, 0xb1, 0x07, 0x4f, 0x04, 0x46, 0x7f, 0x44,
        0x3f, 0x68, 0x01, 0xe0, 0xe4, 0x68, 0x2c, 0xb1, 0x20, 0x69, 0x29, 0x46, 0x32, 0x46, 0xb8, 0x47,
        0x00, 0x28, 0xf7, 0xd0, 0xbd, 0xe8, 0xf0, 0x81, 0x82, 0xfb, 0xdf, 0x00
    };
    const uint8_t lookup_bytes[]={
        0x2d, 0xe9, 0xf0, 0x03, 0xc7, 0x68, 0xd0, 0xf8, 0x04, 0xc0, 0xc1, 0xf3, 0xdb, 0x00, 0x01, 0x3f,
        0x07, 0x24, 0x38, 0x40, 0x0c, 0xf1, 0x08, 0x05, 0x03, 0x01, 0xee, 0x18, 0xeb, 0x58, 0x99, 0x42,
        0x09, 0xd0, 0xdb, 0xb1, 0x26, 0x18, 0x01, 0x34, 0x06, 0xea, 0x07, 0x00, 0x03, 0x01, 0xee, 0x18,
        0xeb, 0x58, 0x99, 0x42, 0xf5, 0xd1, 0xd6, 0xf8, 0x04, 0x80, 0x42, 0x45, 0x0e, 0xd0, 0xd8, 0xf8,
        0x0c, 0x80, 0xd2, 0xf8, 0x0c, 0x90, 0xc8, 0x45, 0xeb, 0xd1, 0x18, 0xf0, 0x07, 0x0f, 0xe8, 0xd1,
        0xd6, 0xf8, 0x0c, 0x80, 0x16, 0x69, 0xb6, 0xeb, 0x58, 0x0f, 0xe2, 0xdb, 0x0c, 0xeb, 0x00, 0x13,
        0x9a, 0x68, 0x8a, 0x42, 0x03, 0xd0, 0x00, 0x20, 0xbd, 0xe8, 0xf0, 0x03, 0x70, 0x47, 0x0c, 0xeb,
        0x00, 0x11, 0x08, 0x69, 0xf8, 0xe7, 0x00, 0xbf
    };
    const uint32_t caller=h.GuestAlloc(48,4),lookup=h.GuestAlloc(sizeof(lookup_bytes),4);
    const uint32_t table=h.GuestAlloc(1024*16+8),map=h.GuestAlloc(16),node=h.GuestAlloc(20),query=h.GuestAlloc(24),other=h.GuestAlloc(24);
    CHECK(caller&&lookup&&table&&map&&node&&query&&other);
    memcpy(h.GetGuestMemoryBase()+caller,caller_bytes,sizeof(caller_bytes));
    memcpy(h.GetGuestMemoryBase()+lookup,lookup_bytes,sizeof(lookup_bytes));
    h.AddExecutableRange(caller,40);h.AddExecutableRange(lookup,sizeof(lookup_bytes));
    // Rebase only the original caller's relative GOT literal to a local slot.
    h.MemoryWrite32(caller+40,26);h.MemoryWrite32(caller+44,lookup|1);
    h.MemoryWrite32(map+4,table);h.MemoryWrite32(map+12,1024);h.MemoryWrite32(node+16,map);
    const uint32_t key=0xa002b020,value=0x12345678;uint32_t slot=(key>>3)&1023;
    for(unsigned step=7;step<23;++step) { h.MemoryWrite32(table+8+slot*16,key+2+step*8);slot=(slot+step)&1023; }
    h.MemoryWrite32(table+8+slot*16,key);h.MemoryWrite32(table+12+slot*16,query);h.MemoryWrite32(table+16+slot*16,value);
    for(unsigned i=0;i<128;++i) {
        CHECK(h.RunFunction(caller|1,{node,key,query})==value&&!h.HasFailed());
        CHECK(h.CurrentJit().Regs()[7]==0&&h.CurrentJit().Regs()[4]==0);
        CHECK(h.RunFunction(caller|1,{node,key+1,query})==0&&!h.HasFailed());
    }
    std::array<bool,4> valid{};std::vector<std::thread> workers;
    for(size_t i=0;i<valid.size();++i)workers.emplace_back([&,i] {
        valid[i]=true;
        for(unsigned n=0;n<128;++n)valid[i]&=h.RunFunction(caller|1,{node,key,query})==value&&h.CurrentJit().Regs()[7]==0&&h.RunFunction(caller|1,{node,key+1,query})==0&&!h.HasFailed();
        h.ReleaseCurrentThread();
    });
    for(auto& worker:workers)worker.join();for(bool result:valid)CHECK(result);
    h.MemoryWrite32(table+20+slot*16,20);
    h.MemoryWrite32(query+12,0x12345678);h.MemoryWrite32(other+12,0x12345678);h.MemoryWrite32(other+16,10);
    CHECK(h.RunFunction(caller|1,{node,key,other})==value&&!h.HasFailed());
    CHECK(h.CurrentJit().Regs()[7]==0&&h.CurrentJit().Regs()[4]==0);
    h.MemoryWrite32(other+16,9);
    CHECK(h.RunFunction(caller|1,{node,key,other})==0&&!h.HasFailed());
    h.MemoryWrite32(other+16,10);h.MemoryWrite32(other+12,0x12345670);
    CHECK(h.RunFunction(caller|1,{node,key,other})==0&&!h.HasFailed());
    h.MemoryWrite32(query+12,0x12345679);h.MemoryWrite32(other+12,0x12345679);
    CHECK(h.RunFunction(caller|1,{node,key,other})==0&&!h.HasFailed());
    CHECK(h.CurrentJit().Regs()[7]==0&&h.CurrentJit().Regs()[4]==0);
    for(uint32_t allocation:{table,map,node,query,other})h.GuestFree(allocation);
    printf("PASS original AIR Thumb lookup: 16 collisions, hit/miss, saved registers, five thread contexts\n");
}
void LargeHeapReuse(DynarmicHost& h) {
    const uint32_t mb = 1u << 20;
    const uint32_t a = h.GuestAlloc(12 * mb + 31, 16), b = h.GuestAlloc(16 * mb + 17, 16);
    const uint32_t guard = h.GuestAlloc(20 * mb + 1, 16);
    CHECK(a && b && guard);
    const uint32_t base = h.MemoryRead32(a - 12), capacity = h.MemoryRead32(a - 8);
    CHECK(h.MemoryRead32(b - 12) == base + capacity);
    h.MemoryWrite32(guard, 0xfeedbeef);
    h.GuestFree(b); h.GuestFree(a); // Merge with the next range.
    const uint32_t joined = h.GuestAlloc(24 * mb + 1, 16);
    CHECK(joined == a && h.GuestAllocSize(joined) == 24 * mb + 1);
    const uint32_t split = h.GuestAlloc(mb + 19, 16);
    CHECK(split > joined && uint64_t(split) + mb + 19 < guard);
    CHECK(h.MemoryRead32(joined) == 0 && h.MemoryRead32(joined + 24 * mb - 4) == 0);
    h.GuestFree(joined); h.GuestFree(split); // Merge with both previous and next ranges.
    const uint32_t aligned = h.GuestAlloc(27 * mb + 47, 0x10000);
    CHECK(aligned && !(aligned & 0xffff) && h.MemoryRead32(aligned - 12) == base);
    CHECK(h.GuestAllocSize(aligned) == 27 * mb + 47 && h.MemoryRead32(guard) == 0xfeedbeef);
    h.GuestFree(aligned); h.GuestFree(guard);
    CHECK(h.GuestAllocSize(aligned) == 0 && h.GuestAllocSize(guard) == 0);
    printf("PASS large heap best-fit, split, coalescence, alignment and live-neighbor preservation\n");
}
void AirImports(DynarmicHost& h) {
    uint32_t buffer=h.GuestAlloc(272),out=h.GuestAlloc(112);
    h.MemoryWrite32(buffer+256,0xabcdef01);
    CHECK(Call(h,"_setjmp",{buffer,0xdeadbeef})==0);
    CHECK((h.MemoryRead32(buffer)&1)==0&&h.MemoryRead32(buffer+256)==0xabcdef01);
    CHECK(Call(h,"_longjmp",{buffer,7})==7);
    CHECK(Call(h,"setjmp",{buffer,0})==0&&(h.MemoryRead32(buffer)&1)==1);
    CHECK(Call(h,"longjmp",{buffer,0})==1);
    // A real guest frame must resume after BLX setjmp, including Thumb interworking.
    const uint32_t save=h.GetThunkManager().FindRegisteredSymbol("_setjmp");
    const uint32_t restore=h.GetThunkManager().FindRegisteredSymbol("_longjmp");
    const uint32_t jump=h.GuestAlloc(80);CHECK(save&&restore&&jump);h.AddExecutableRange(jump,80);
    const uint32_t arm[]={0xe92d4070,0xe1a04000,0xe1a05002,0xe1a06003,0xe12fff31,0xe3500000,0x1a000003,0xe1a00004,0xe1a01006,0xe12fff35,0xe3a000ee,0xe8bd8070};
    const uint16_t thumb[]={0xb570,0x4604,0x4615,0x461e,0x4788,0x2800,0xd103,0x4620,0x4631,0x47a8,0x20ee,0xbd70};
    memcpy(h.GetGuestMemoryBase()+jump,arm,sizeof(arm));memcpy(h.GetGuestMemoryBase()+jump+48,thumb,sizeof(thumb));
    for(uint32_t entry:{jump,(jump+48)|1u}) {
        CHECK(h.RunFunction(entry,{buffer,save,restore,160})==160);
        CHECK(h.RunFunction(entry,{buffer,save,restore,0})==1);
    }
    CHECK(!h.HasFailed()&&h.MemoryRead32(buffer+256)==0xabcdef01);
    uint32_t thread=Call(h,"pthread_self"),attr=h.GuestAlloc(32);
    h.MemoryWrite32(attr+24,0x12345678);
    CHECK(Call(h,"pthread_getattr_np",{thread,attr})==0);
    auto bounds=h.GuestStackBounds();CHECK(h.MemoryRead32(attr+4)==bounds.first&&h.MemoryRead32(attr+8)==bounds.second-bounds.first&&h.MemoryRead32(attr+24)==0x12345678);
    uint32_t file=Call(h,"tmpfile"),line=Text(h,"alpha beta");
    CHECK(Call(h,"fwrite",{line,1,10,file})==10&&Call(h,"fseek",{file,0,SEEK_SET})==0);
    CHECK(Call(h,"fgetpos",{file,out+80})==0&&h.MemoryRead32(out+80)==0);
    CHECK(Call(h,"fscanf",{file,Text(h,"%5s"),out})==1&&std::string(reinterpret_cast<char*>(h.GetGuestMemoryBase()+out))=="alpha");
    CHECK(Call(h,"ftell",{file})==5&&Call(h,"fsetpos",{file,out+80})==0&&Call(h,"fclose",{file})==0);
    CHECK(Call(h,"strnlen",{0,0})==0);
    uint32_t service=Call(h,"getservbyname",{Text(h,"http"),Text(h,"tcp")});
    CHECK(service&&h.MemoryRead32(service+8)==0x5000);
    CHECK(Call(h,"statfs",{Text(h,"/data/local/tmp"),out})==0&&h.MemoryRead32(out+4)>0);
    h.MemoryWrite32(out+72,0xcafebabe);
    CHECK(Call(h,"getrusage",{0,out})==0&&h.MemoryRead32(out+72)==0xcafebabe);
    uint32_t code=h.GuestAllocMapping(4096,4096);h.MemoryWrite32(code,0xe12fff1e);
    CHECK(Call(h,"mprotect",{code,4096,5})==0&&Call(h,"cacheflush",{code,code+4,0})==0&&h.RunFunction(code,{19})==19);
    CHECK(Call(h,"mprotect",{code,4096,3})==0&&!h.IsExecutableAddress(code));
    h.MemoryWrite32(code,0xe3a00021);h.MemoryWrite32(code+4,0xe12fff1e);
    CHECK(Call(h,"mprotect",{code,4096,5})==0&&h.RunFunction(code)==33);
    CHECK(Call(h,"munmap",{code,4096})==0&&!h.IsExecutableAddress(code));
    CHECK(h.MemoryRead32(code)==0);
    h.MemoryWrite32(code,0xe3a00022);h.MemoryWrite32(code+4,0xe12fff1e);
    CHECK(Call(h,"mprotect",{code,4096,5})==0&&h.RunFunction(code)==34);
    CHECK(Call(h,"munmap",{code,4096})==0&&!h.IsExecutableAddress(code));
    CHECK(Call(h,"sigaction",{SIGPIPE,0,buffer})==0);
    h.MemoryWrite32(buffer+16,1);h.MemoryWrite32(buffer+20,0);h.MemoryWrite32(buffer+24,0);h.MemoryWrite32(buffer+28,0);
    CHECK(Call(h,"sigaction",{SIGPIPE,buffer+16,0})==0&&Call(h,"sigaction",{SIGPIPE,buffer,0})==0);
    CHECK(Call(h,"bsd_signal",{SIGWINCH,0})!=UINT32_MAX);
    uint32_t reserved=Call(h,"mmap",{0,8192,0,0x22,UINT32_MAX,0});CHECK(reserved!=UINT32_MAX);
    h.MemoryWrite32(reserved,0xdeadbeef);h.MemoryWrite32(reserved+4096,0xaabbccdd);
    CHECK(Call(h,"mmap",{reserved,4096,3,0x32,UINT32_MAX,0})==reserved);
    CHECK(h.MemoryRead32(reserved)==0&&h.MemoryRead32(reserved+4096)==0xaabbccdd);
    uint32_t first=Call(h,"mmap",{0,4096,3,0x22,UINT32_MAX,0}),second=Call(h,"mmap",{0,4096,3,0x22,UINT32_MAX,0});
    CHECK(first!=UINT32_MAX&&second-first==sysconf(_SC_PAGESIZE));
    CHECK(Call(h,"mmap",{second-4096,8192,0,0x32,UINT32_MAX,0})==second-4096);
    printf("PASS AIR ARM32 jump buffers, guest stacks, FILE positions/scanf, service/struct widths, dynamic code, signal dispositions\n");
}
void JumpThreadCleanup(DynarmicHost& h) {
    const uint32_t parent=h.GuestAlloc(256),worker=h.GuestAlloc(256);
    CHECK(parent&&worker&&Call(h,"_setjmp",{parent})==0);
    const size_t baseline=GuestJumpContextCountForTesting();
    std::thread thread([&]{
        CHECK(Call(h,"_setjmp",{worker})==0);
        CHECK(GuestJumpContextCountForTesting()==baseline+1);
        h.ReleaseCurrentThread();
    });
    thread.join();
    CHECK(GuestJumpContextCountForTesting()==baseline);
    std::thread automatic([&]{
        CHECK(Call(h,"_setjmp",{worker})==0);
        CHECK(GuestJumpContextCountForTesting()==baseline+1);
    });
    automatic.join();
    CHECK(GuestJumpContextCountForTesting()==baseline);
    CHECK(Call(h,"_longjmp",{parent,42})==42);
    CHECK(Call(h,"alarm",{60})==0);
    h.ReleaseCurrentThread();
    CHECK(GuestJumpContextCountForTesting()==0);
    CHECK(Call(h,"alarm",{0})==0);
    h.GuestFree(parent);h.GuestFree(worker);
    printf("PASS explicit/automatic thread exit retires jump contexts, preserves live owners, and cancels alarms\n");
}
void NaturalTlsCleanup(DynarmicHost& h) {
    const uint32_t key_slot=h.GuestAlloc(4),counter=h.GuestAlloc(4);
    uint32_t key=0,cache=0;
    const uint32_t destructor=h.GetThunkManager().RegisterThunk("test_natural_tls_destructor",[&](auto& j,auto& host){
        CHECK(j.Regs()[0]==counter);
        CHECK(Call(host,"pthread_getspecific",{key})==0);
        CHECK(GetBoundGlBuffer(GL_COPY_READ_BUFFER)==23);
        CHECK(host.GuestAllocSize(cache)>0);
        host.MemoryWrite32(counter,host.MemoryRead32(counter)+1);
        CHECK(Call(host,"pthread_setspecific",{key,counter})==0);
        j.Regs()[0]=0;
    });
    CHECK(Call(h,"pthread_key_create",{key_slot,destructor})==0);
    key=h.MemoryRead32(key_slot);
    CHECK(Call(h,"pthread_setspecific",{key,0x222})==0);
    std::thread thread([&]{
        CHECK(Call(h,"pthread_setspecific",{key,counter})==0);
        cache=Call(h,"strerror",{ENOENT});CHECK(cache);
        TrackGlBufferBinding(GL_COPY_READ_BUFFER,23);
    });
    thread.join();
    CHECK(h.MemoryRead32(counter)==4);
    CHECK(h.GuestAllocSize(cache)==0);
    CHECK(Call(h,"pthread_getspecific",{key})==0x222);
    CHECK(Call(h,"pthread_key_delete",{key})==0);
    h.GuestFree(key_slot);h.GuestFree(counter);
    printf("PASS automatic TLS destructors run four rounds before caches/GL state retire and preserve other threads\n");
}
void TlsKeyDeletion(DynarmicHost& h) {
    unsigned native_calls=0;
    pthread_key_t native_survivor=0;
    struct NativeKey { pthread_key_t self,other;unsigned* calls;pthread_key_t* survivor; } native[2]{};
    auto destroy=[](void* opaque){
        auto& key=*static_cast<NativeKey*>(opaque);++*key.calls;*key.survivor=key.self;
        CHECK(pthread_getspecific(key.self)==nullptr);CHECK(pthread_key_delete(key.other)==0);
    };
    for(auto& key:native){key.calls=&native_calls;key.survivor=&native_survivor;CHECK(pthread_key_create(&key.self,destroy)==0);}
    native[0].other=native[1].self;native[1].other=native[0].self;
    std::thread reference([&]{for(auto& key:native)CHECK(pthread_setspecific(key.self,&key)==0);});reference.join();
    CHECK(native_calls==1);CHECK(pthread_key_delete(native_survivor)==0);
    printf("PASS native Bionic skips a key deleted by another TLS destructor\n");
    const uint32_t slots=h.GuestAlloc(8);
    uint32_t keys[2]{},survivor=0;unsigned guest_calls=0;
    const uint32_t destructor=h.GetThunkManager().RegisterThunk("test_tls_delete_peer",[&](auto& jit,auto& host){
        const uint32_t index=jit.Regs()[0]-1;CHECK(index<2);++guest_calls;survivor=keys[index];
        CHECK(Call(host,"pthread_getspecific",{keys[index]})==0);
        CHECK(Call(host,"pthread_key_delete",{keys[index^1]})==0);jit.Regs()[0]=0;
    });
    for(bool explicit_release:{false,true}) {
        guest_calls=0;
        for(unsigned i=0;i<2;++i){CHECK(Call(h,"pthread_key_create",{slots+i*4,destructor})==0);keys[i]=h.MemoryRead32(slots+i*4);}
        std::thread worker([&]{
            for(unsigned i=0;i<2;++i)CHECK(Call(h,"pthread_setspecific",{keys[i],i+1})==0);
            if(explicit_release)h.ReleaseCurrentThread();
        });worker.join();
        printf("TLS peer deletion: native=%u guest=%u explicit_release=%u\n",native_calls,guest_calls,unsigned(explicit_release));
        CHECK(guest_calls==native_calls);CHECK(Call(h,"pthread_key_delete",{survivor})==0);
    }
    h.GuestFree(slots);
    printf("PASS explicit/automatic TLS teardown matches native Bionic peer-key deletion\n");
}
void StringsAndStdio(DynarmicHost& h) {
    const uint32_t text=Text(h,"beta:alpha:gamma"),delim=Text(h,":"),save=h.GuestAlloc(4);
    CHECK(Call(h,"strtok_r",{text,delim,save})==text);
    CHECK(Call(h,"strtok_r",{0,delim,save})==text+5);
    uint32_t input=Text(h,"4294967296!"),end=h.GuestAlloc(8);
    h.MemoryWrite32(end+4,0xfeedbeef);
    CHECK(Call(h,"strtoul",{input,end,10})==UINT32_MAX);
    CHECK(h.MemoryRead32(h.GuestErrnoAddress())==ERANGE);
    CHECK(h.MemoryRead32(end)==input+10&&h.MemoryRead32(end+4)==0xfeedbeef);
    CHECK(Call(h,"strtoull",{input,end,10})==0&&h.GetResultHigh()==1);
    uint32_t format=Text(h,"%s %lld %.2f"),out=h.GuestAlloc(80),str=Text(h,"ok");
    // snprintf: r3 is %s; long long and double begin at even spilled words.
    const uint64_t bits=std::bit_cast<uint64_t>(1.25);
    CHECK(Call(h,"snprintf",{out,80,format,str,0x55667788,0x11223344,uint32_t(bits),uint32_t(bits>>32)})>0);
    CHECK(std::string(reinterpret_cast<char*>(h.GetGuestMemoryBase()+out))=="ok 1234605616436508552 1.25");
    uint32_t file=Call(h,"tmpfile");CHECK(file);
    uint32_t line=Text(h,"hello bridge\n");
    CHECK(Call(h,"fwrite",{line,1,13,file})==13);
    CHECK(Call(h,"fseeko",{file,0,SEEK_SET})==0);
    CHECK(Call(h,"fgets",{out,80,file})==out);
    CHECK(strcmp(reinterpret_cast<char*>(h.GetGuestMemoryBase()+out),"hello bridge\n")==0);
    CHECK(Call(h,"ftello",{file})==13);
    uint32_t stat=h.GuestAlloc(112);h.MemoryWrite64(stat+104,0x123456789abcdef0ULL);
    uint32_t fd=Call(h,"fileno",{file});CHECK(fd!=UINT32_MAX);
    CHECK(Call(h,"fstat",{fd,stat})==0);CHECK(h.MemoryRead64(stat+48)==13);
    CHECK(h.MemoryRead64(stat+104)==0x123456789abcdef0ULL);
    CHECK(Call(h,"fclose",{file})==0);
    // UTF-8 state is exactly four guest bytes, even though host mbstate_t is eight.
    uint32_t utf=Text(h,"\xe2\x82\xac"),state=h.GuestAlloc(8),wide=h.GuestAlloc(8);
    h.MemoryWrite32(state+4,0xdeadbeef);
    CHECK(Call(h,"mbrtowc",{wide,utf,1,state})==UINT32_MAX-1);
    CHECK(Call(h,"mbrtowc",{wide,utf+1,2,state})==2);
    CHECK(h.MemoryRead32(wide)==0x20ac&&h.MemoryRead32(state+4)==0xdeadbeef);
    uint32_t wc=Call(h,"wctype",{Text(h,"alpha")});CHECK(wc&&Call(h,"iswctype",{'A',wc}));
    uint32_t time=h.GuestAlloc(4),tm=h.GuestAlloc(52);h.MemoryWrite32(time,0);h.MemoryWrite64(tm+44,0x123456789abcdef0ULL);
    CHECK(Call(h,"gmtime_r",{time,tm})==tm);CHECK(h.MemoryRead32(tm+20)==70);
    CHECK(h.MemoryRead64(tm+44)==0x123456789abcdef0ULL);
    printf("PASS libc strings, varargs, FILE handles, stat32, UTF-8 state, tm32\n");
}
void ScansetParsing(DynarmicHost& h) {
    const uint32_t output=h.GuestAlloc(32),count=h.GuestAlloc(4);
    const uint32_t tag_format=Text(h,"<%[^>]>");
    auto result=[&]{return reinterpret_cast<const char*>(h.GetGuestMemoryBase()+output);};
    CHECK(Call(h,"sscanf",{Text(h,"<mass>"),tag_format,output})==1);
    CHECK(strcmp(result(),"mass")==0);
    CHECK(Call(h,"sscanf",{Text(h,"<shape>"),tag_format,output})==1);
    CHECK(strcmp(result(),"shape")==0);
    CHECK(Call(h,"sscanf",{Text(h,"abcdef"),Text(h,"%3[a-z]"),output})==1);
    CHECK(strcmp(result(),"abc")==0);
    CHECK(Call(h,"sscanf",{Text(h,"]abcz"),Text(h,"%[]a-c]"),output})==1);
    CHECK(strcmp(result(),"]abc")==0);
    CHECK(Call(h,"sscanf",{Text(h,"12 abc"),Text(h,"%[^a-z]"),output})==1);
    CHECK(strcmp(result(),"12 ")==0);
    CHECK(Call(h,"sscanf",{Text(h,"<solid>17"),Text(h,"<%*[^>]>%d"),count})==1);
    CHECK(h.MemoryRead32(count)==17);
    h.MemoryWrite32(count,UINT32_MAX);
    CHECK(Call(h,"sscanf",{Text(h,"<mass>"),Text(h,"<%[^>]>%n"),output,count})==1);
    CHECK(strcmp(result(),"mass")==0&&h.MemoryRead32(count)==6);
    CHECK(Call(h,"sscanf",{Text(h,">"),Text(h,"%[^>]"),output})==0);
    CHECK(Call(h,"sscanf",{Text(h,""),Text(h,"%[^>]"),output})==static_cast<uint32_t>(EOF));
    const uint32_t list=h.GuestAlloc(4);h.MemoryWrite32(list,output);
    CHECK(Call(h,"vsscanf",{Text(h,"<solid>"),tag_format,list})==1);
    CHECK(strcmp(result(),"solid")==0);
    printf("PASS ARM32 sscanf/vsscanf scansets, width, ranges, suppression, EOF\n");
}
void CallbacksAndThreads(DynarmicHost& h) {
    uint32_t values=h.GuestAlloc(32),cmp=h.GuestAlloc(16);
    int32_t data[]={8,1,7,2,6,3,5,4};memcpy(h.GetGuestMemoryBase()+values,data,sizeof(data));
    uint32_t instructions[]={0xe5900000,0xe5911000,0xe0400001,0xe12fff1e};
    memcpy(h.GetGuestMemoryBase()+cmp,instructions,sizeof(instructions));h.AddExecutableRange(cmp,16);
    Call(h,"qsort",{values,8,4,cmp});
    for(uint32_t i=0;i<8;++i)CHECK(h.MemoryRead32(values+i*4)==i+1);
    // Carmageddon's checkpoints are 0xA4-byte records ordered by the value at
    // offset 52. Exercise guest callbacks and movement of the complete record.
    constexpr uint32_t gate_size=0xA4;
    const uint32_t gates=h.GuestAlloc(gate_size*3),gate_cmp=h.GuestAlloc(16);
    const uint32_t gate_code[]={0xe5900034,0xe5911034,0xe0400001,0xe12fff1e};
    memcpy(h.GetGuestMemoryBase()+gate_cmp,gate_code,sizeof(gate_code));
    h.AddExecutableRange(gate_cmp,sizeof(gate_code));
    const float gate_distances[]={30.0f,10.0f,20.0f};
    for(uint32_t i=0;i<3;++i) {
        memset(h.GetGuestMemoryBase()+gates+i*gate_size,0x40+i,gate_size);
        h.MemoryWrite32(gates+i*gate_size+52,std::bit_cast<uint32_t>(gate_distances[i]));
    }
    Call(h,"qsort",{gates,3,gate_size,gate_cmp});
    for(uint32_t i=0;i<3;++i) {
        CHECK(h.MemoryRead32(gates+i*gate_size+52)==std::bit_cast<uint32_t>(gate_distances[i==0?1:i==1?2:0]));
        CHECK(h.GetGuestMemoryBase()[gates+i*gate_size]==0x40+(i==0?1:i==1?2:0));
        CHECK(h.GetGuestMemoryBase()[gates+(i+1)*gate_size-1]==0x40+(i==0?1:i==1?2:0));
    }
    uint32_t key=h.GuestAlloc(4);h.MemoryWrite32(key,5);
    CHECK(Call(h,"bsearch",{key,values,8,4,cmp})==values+16);
    const uint32_t mutex=h.GuestAlloc(4),counter=h.GuestAlloc(4),ids=h.GuestAlloc(16),result=h.GuestAlloc(4);
    CHECK(Call(h,"pthread_mutex_init",{mutex,0})==0);
    const uint32_t lock=h.FindSymbol("pthread_mutex_lock"),unlock=h.FindSymbol("pthread_mutex_unlock");
    auto worker=h.GetThunkManager().RegisterThunk("test_thread_worker",[=](auto& j,auto& host) {
        for(unsigned i=0;i<200;++i) {
            if(host.RunFunction(lock,{mutex})) { host.Fail("Worker mutex lock");return; }
            host.MemoryWrite32(counter,host.MemoryRead32(counter)+1);
            if(host.RunFunction(unlock,{mutex})) { host.Fail("Worker mutex unlock");return; }
        }
        j.Regs()[0]=0xabcdef;
    });
    for(unsigned i=0;i<4;++i)CHECK(Call(h,"pthread_create",{ids+4*i,0,worker,0})==0);
    for(unsigned i=0;i<4;++i) { CHECK(Call(h,"pthread_join",{h.MemoryRead32(ids+4*i),result})==0);CHECK(h.MemoryRead32(result)==0xabcdef); }
    CHECK(h.MemoryRead32(counter)==800);CHECK(Call(h,"pthread_mutex_destroy",{mutex})==0);
    uint32_t sem=h.GuestAlloc(16);CHECK(Call(h,"sem_init",{sem,0,0})==0);
    CHECK(Call(h,"sem_trywait",{sem})==UINT32_MAX&&h.MemoryRead32(h.GuestErrnoAddress())==EAGAIN);
    CHECK(Call(h,"sem_post",{sem})==0&&Call(h,"sem_wait",{sem})==0&&Call(h,"sem_destroy",{sem})==0);
    // Retire only objects inside the freed range; keep its lower/end neighbors.
    const uint32_t sync=h.GuestAlloc(64);
    CHECK(Call(h,"pthread_mutex_init",{sync,0})==0);
    CHECK(Call(h,"pthread_cond_init",{sync+16,0})==0);
    CHECK(Call(h,"sem_init",{sync+32,0,1})==0);
    GuestSyncForget(sync+16,16);
    CHECK(Call(h,"pthread_cond_init",{sync+16,0})==0);
    CHECK(Call(h,"pthread_mutex_init",{sync,0})==EBUSY);
    CHECK(Call(h,"sem_init",{sync+32,0,1})==UINT32_MAX && h.MemoryRead32(h.GuestErrnoAddress())==EBUSY);
    h.GuestFree(sync);
    const uint32_t recycled=h.GuestAlloc(64);
    CHECK(recycled==sync);
    CHECK(Call(h,"pthread_mutex_init",{recycled,0})==0);
    CHECK(Call(h,"pthread_cond_init",{recycled+16,0})==0);
    CHECK(Call(h,"sem_init",{recycled+32,0,1})==0);
    h.GuestFree(recycled);
    // A range ending at 4 GiB must not wrap to zero.
    CHECK(Call(h,"sem_init",{0xfffffff0,0,1})==0);
    GuestSyncForget(0xfffffff0,16);
    CHECK(Call(h,"sem_init",{0xfffffff0,0,1})==0);
    CHECK(Call(h,"sem_destroy",{0xfffffff0})==0);
    uint32_t guard=h.GuestAlloc(8);CHECK(Call(h,"__cxa_guard_acquire",{guard})==1);
    Call(h,"__cxa_guard_abort",{guard});CHECK(Call(h,"__cxa_guard_acquire",{guard})==1);
    Call(h,"__cxa_guard_release",{guard});CHECK(Call(h,"__cxa_guard_acquire",{guard})==0);
    printf("PASS guest qsort/bsearch callbacks, concurrent pthreads, semaphore, C++ guards\n");
}
void Zlib(DynarmicHost& h) {
    uint32_t source=Text(h,"compress this text, compress this text, compress this text"),packed=h.GuestAlloc(256),out=h.GuestAlloc(256),length=h.GuestAlloc(8);
    const uint32_t size=strlen(reinterpret_cast<char*>(h.GetGuestMemoryBase()+source))+1;
    h.MemoryWrite32(length,256);h.MemoryWrite32(length+4,0xdeadbeef);
    CHECK(Call(h,"compress2",{packed,length,source,size,9})==Z_OK);const uint32_t compressed=h.MemoryRead32(length);
    CHECK(h.MemoryRead32(length+4)==0xdeadbeef);h.MemoryWrite32(length,256);
    CHECK(Call(h,"uncompress",{out,length,packed,compressed})==Z_OK);
    CHECK(h.MemoryRead32(length)==size&&!memcmp(h.GetGuestMemoryBase()+source,h.GetGuestMemoryBase()+out,size));
    uint32_t stream=h.GuestAlloc(64),version=Call(h,"zlibVersion");h.MemoryWrite64(stream+56,0x123456789abcdef0ULL);
    CHECK(static_cast<int32_t>(Call(h,"inflateInit2_",{stream,15,version,112}))==Z_VERSION_ERROR);
    CHECK(Call(h,"inflateInit2_",{stream,15,version,56})==Z_OK);
    h.MemoryWrite32(stream,packed);h.MemoryWrite32(stream+4,compressed);h.MemoryWrite32(stream+12,out);h.MemoryWrite32(stream+16,256);
    CHECK(Call(h,"inflate",{stream,Z_FINISH})==Z_STREAM_END);CHECK(h.MemoryRead32(stream+20)==size);
    CHECK(Call(h,"inflateReset",{stream})==Z_OK&&h.MemoryRead32(stream+20)==0);
    CHECK(Call(h,"inflateEnd",{stream})==Z_OK&&h.MemoryRead32(stream+28)==0);
    CHECK(h.MemoryRead64(stream+56)==0x123456789abcdef0ULL);
    CHECK(Call(h,"deflateInit2_",{stream,6,Z_DEFLATED,15,8,Z_DEFAULT_STRATEGY,version,56})==Z_OK);
    h.MemoryWrite32(stream,source);h.MemoryWrite32(stream+4,size);h.MemoryWrite32(stream+12,packed);h.MemoryWrite32(stream+16,256);
    CHECK(Call(h,"deflate",{stream,Z_FINISH})==Z_STREAM_END);CHECK(Call(h,"deflateEnd",{stream})==Z_OK);
    CHECK(Call(h,"crc32",{0,source,size})==crc32(0,h.GetGuestMemoryBase()+source,size));
    printf("PASS zlib roundtrip, z_stream32, stack args, versions, reset/end, canaries\n");
}
void Graphics(DynarmicHost& h) {
    const uint32_t display=Call(h,"eglGetDisplay",{0});
    if(!Call(h,"eglInitialize",{display,0,0})) { printf("SKIP EGL: device did not allow shell display initialization\n");return; }
    uint32_t attributes=h.GuestAlloc(48),config=h.GuestAlloc(4),count=h.GuestAlloc(4);
    uint32_t attrs[]={EGL_SURFACE_TYPE,EGL_PBUFFER_BIT,EGL_RENDERABLE_TYPE,EGL_OPENGL_ES3_BIT,EGL_RED_SIZE,8,EGL_NONE};
    memcpy(h.GetGuestMemoryBase()+attributes,attrs,sizeof(attrs));
    CHECK(Call(h,"eglChooseConfig",{display,attributes,config,1,count}));CHECK(h.MemoryRead32(count)>0);
    h.MemoryWrite32(attributes,EGL_CONTEXT_CLIENT_VERSION);h.MemoryWrite32(attributes+4,3);h.MemoryWrite32(attributes+8,EGL_NONE);
    uint32_t context=Call(h,"eglCreateContext",{display,h.MemoryRead32(config),0,attributes});CHECK(context);
    uint32_t pbuffer[]={EGL_WIDTH,16,EGL_HEIGHT,16,EGL_NONE};memcpy(h.GetGuestMemoryBase()+attributes,pbuffer,sizeof(pbuffer));
    uint32_t surface=Call(h,"eglCreatePbufferSurface",{display,h.MemoryRead32(config),attributes});CHECK(surface);
    CHECK(Call(h,"eglMakeCurrent",{display,surface,surface,context}));
    CHECK(Call(h,"eglGetCurrentContext")==context);
    CHECK(Call(h,"eglQueryString",{display,EGL_VENDOR})==Call(h,"eglQueryString",{display,EGL_VENDOR}));
    uint32_t buffer=h.GuestAlloc(4);Call(h,"glGenBuffers",{1,buffer});CHECK(h.MemoryRead32(buffer));
    Call(h,"glBindBuffer",{GL_ARRAY_BUFFER,h.MemoryRead32(buffer)});Call(h,"glBufferData",{GL_ARRAY_BUFFER,64,0,GL_DYNAMIC_DRAW});
    uint32_t mapped=Call(h,"glMapBufferRange",{GL_ARRAY_BUFFER,0,64,GL_MAP_WRITE_BIT|GL_MAP_INVALIDATE_BUFFER_BIT});CHECK(mapped);
    memset(h.GetGuestMemoryBase()+mapped,0x45,64);CHECK(Call(h,"glUnmapBuffer",{GL_ARRAY_BUFFER}));
    // Two unshared contexts can both name their first buffer 1. Their live
    // guest mappings must survive context switches without aliasing each other.
    mapped=Call(h,"glMapBufferRange",{GL_ARRAY_BUFFER,0,64,GL_MAP_WRITE_BIT});CHECK(mapped);
    memset(h.GetGuestMemoryBase()+mapped,0x5a,64);
    uint32_t pointer_out=h.GuestAlloc(8);h.MemoryWrite32(pointer_out+4,0xfeedbeef);
    Call(h,"glGetBufferPointerv",{GL_ARRAY_BUFFER,GL_BUFFER_MAP_POINTER,pointer_out});
    CHECK(h.MemoryRead32(pointer_out)==mapped&&h.MemoryRead32(pointer_out+4)==0xfeedbeef);
    h.MemoryWrite32(attributes,EGL_CONTEXT_CLIENT_VERSION);h.MemoryWrite32(attributes+4,3);h.MemoryWrite32(attributes+8,EGL_NONE);
    uint32_t second=Call(h,"eglCreateContext",{display,h.MemoryRead32(config),0,attributes});CHECK(second);
    CHECK(Call(h,"eglMakeCurrent",{display,surface,surface,second}));
    uint32_t buffer2=h.GuestAlloc(4);Call(h,"glGenBuffers",{1,buffer2});
    Call(h,"glBindBuffer",{GL_ARRAY_BUFFER,h.MemoryRead32(buffer2)});Call(h,"glBufferData",{GL_ARRAY_BUFFER,64,0,GL_DYNAMIC_DRAW});
    uint32_t mapped2=Call(h,"glMapBufferRange",{GL_ARRAY_BUFFER,0,64,GL_MAP_WRITE_BIT});CHECK(mapped2&&mapped2!=mapped);
    memset(h.GetGuestMemoryBase()+mapped2,0x7b,64);
    CHECK(Call(h,"eglMakeCurrent",{display,surface,surface,context}));CHECK(Call(h,"glUnmapBuffer",{GL_ARRAY_BUFFER}));
    mapped=Call(h,"glMapBufferRange",{GL_ARRAY_BUFFER,0,64,GL_MAP_READ_BIT});CHECK(mapped&&h.GetGuestMemoryBase()[mapped]==0x5a);
    CHECK(Call(h,"glUnmapBuffer",{GL_ARRAY_BUFFER}));
    CHECK(Call(h,"eglMakeCurrent",{display,surface,surface,second}));CHECK(Call(h,"glUnmapBuffer",{GL_ARRAY_BUFFER}));
    mapped2=Call(h,"glMapBufferRange",{GL_ARRAY_BUFFER,0,64,GL_MAP_READ_BIT});CHECK(mapped2&&h.GetGuestMemoryBase()[mapped2]==0x7b);
    CHECK(Call(h,"glUnmapBuffer",{GL_ARRAY_BUFFER}));Call(h,"glDeleteBuffers",{1,buffer2});
    CHECK(Call(h,"eglMakeCurrent",{display,surface,surface,context}));CHECK(Call(h,"eglDestroyContext",{display,second}));
    uint32_t sync=Call(h,"glFenceSync",{GL_SYNC_GPU_COMMANDS_COMPLETE,0});CHECK(sync);
    uint32_t wait=Call(h,"glClientWaitSync",{sync,GL_SYNC_FLUSH_COMMANDS_BIT,UINT32_MAX,UINT32_MAX});
    CHECK(wait==GL_ALREADY_SIGNALED||wait==GL_CONDITION_SATISFIED);Call(h,"glDeleteSync",{sync});
    Call(h,"glDeleteBuffers",{1,buffer});CHECK(Call(h,"glGetError")==GL_NO_ERROR);
    CHECK(Call(h,"eglMakeCurrent",{display,0,0,0}));CHECK(Call(h,"eglDestroySurface",{display,surface}));CHECK(Call(h,"eglDestroyContext",{display,context}));
    attrs[3]=EGL_OPENGL_ES2_BIT;memcpy(h.GetGuestMemoryBase()+attributes,attrs,sizeof(attrs));
    CHECK(Call(h,"eglChooseConfig",{display,attributes,config,1,count}));CHECK(h.MemoryRead32(count)>0);
    h.MemoryWrite32(attributes,EGL_CONTEXT_CLIENT_VERSION);h.MemoryWrite32(attributes+4,2);h.MemoryWrite32(attributes+8,EGL_NONE);
    context=Call(h,"eglCreateContext",{display,h.MemoryRead32(config),0,attributes});CHECK(context);
    memcpy(h.GetGuestMemoryBase()+attributes,pbuffer,sizeof(pbuffer));surface=Call(h,"eglCreatePbufferSurface",{display,h.MemoryRead32(config),attributes});CHECK(surface);
    CHECK(Call(h,"eglMakeCurrent",{display,surface,surface,context}));CHECK(Call(h,"glGetError")==GL_NO_ERROR);
    uint32_t texture=h.GuestAlloc(4),pixel=h.GuestAlloc(4);h.MemoryWrite32(pixel,UINT32_MAX);
    Call(h,"glGenTextures",{1,texture});Call(h,"glBindTexture",{GL_TEXTURE_2D,h.MemoryRead32(texture)});
    Call(h,"glTexImage2D",{GL_TEXTURE_2D,0,GL_RGBA,1,1,0,GL_RGBA,GL_UNSIGNED_BYTE,pixel});CHECK(Call(h,"glGetError")==GL_NO_ERROR);
    Call(h,"glDeleteTextures",{1,texture});CHECK(Call(h,"eglMakeCurrent",{display,0,0,0}));CHECK(Call(h,"eglDestroySurface",{display,surface}));CHECK(Call(h,"eglDestroyContext",{display,context}));CHECK(Call(h,"eglTerminate",{display}));
    printf("PASS EGL handles/cache, GLES2 textures, GLES3 context-isolated mapped buffers and GLsync\n");
}
void ElfFixtures(DynarmicHost& h) {
    std::vector<uint8_t> bytes(0x500);
    auto put=[&](size_t at,const auto& object) { memcpy(bytes.data()+at,&object,sizeof(object)); };
    Elf32_Ehdr eh{};memcpy(eh.e_ident,ELFMAG,SELFMAG);eh.e_ident[EI_CLASS]=ELFCLASS32;
    eh.e_ident[EI_DATA]=ELFDATA2LSB;eh.e_ident[EI_VERSION]=EV_CURRENT;
    eh.e_machine=EM_ARM;eh.e_type=ET_DYN;eh.e_version=EV_CURRENT;eh.e_ehsize=sizeof(eh);
    eh.e_phoff=sizeof(eh);eh.e_phnum=2;eh.e_phentsize=sizeof(Elf32_Phdr);put(0,eh);
    Elf32_Phdr load{PT_LOAD,0,0,0,0x500,0x500,PF_R|PF_W|PF_X,0x1000};put(sizeof(eh),load);
    std::vector<Elf32_Dyn> dynamic;
    auto tag=[&](int32_t t,uint32_t value) { Elf32_Dyn d{};d.d_tag=t;d.d_un.d_val=value;dynamic.push_back(d); };
    tag(DT_STRTAB,0x120);tag(DT_STRSZ,40);tag(DT_SYMTAB,0x180);tag(DT_SYMENT,16);
    tag(DT_GNU_HASH,0x200);tag(DT_REL,0x340);tag(DT_RELSZ,24);tag(DT_INIT,0x400);
    tag(DT_INIT_ARRAY,0x388);tag(DT_INIT_ARRAYSZ,4);tag(DT_NULL,0);
    Elf32_Phdr dyn{PT_DYNAMIC,0x280,0x280,0,uint32_t(dynamic.size()*8),uint32_t(dynamic.size()*8),PF_R|PF_W,4};put(sizeof(eh)+sizeof(load),dyn);
    memcpy(bytes.data()+0x280,dynamic.data(),dynamic.size()*8);
    const char names[]="\0optional\0absolute\0entry\0";memcpy(bytes.data()+0x120,names,sizeof(names));
    Elf32_Sym weak{1,0,0,ELF32_ST_INFO(STB_WEAK,STT_FUNC),0,SHN_UNDEF};put(0x190,weak);
    Elf32_Sym absolute{10,0x12345678,0,ELF32_ST_INFO(STB_GLOBAL,STT_OBJECT),0,SHN_ABS};put(0x1a0,absolute);
    Elf32_Sym entry{19,0x400,8,ELF32_ST_INFO(STB_GLOBAL,STT_FUNC),0,1};put(0x1b0,entry);
    uint32_t hash[]={1,3,1,0,0,3,1};memcpy(bytes.data()+0x200,hash,sizeof(hash));
    Elf32_Rel rels[]={{0x380,ELF32_R_INFO(1,R_ARM_ABS32)},{0x384,ELF32_R_INFO(2,R_ARM_ABS32)},{0x388,ELF32_R_INFO(0,R_ARM_RELATIVE)}};
    memcpy(bytes.data()+0x340,rels,sizeof(rels));put(0x380,uint32_t(0x11));put(0x388,uint32_t(0x404));
    put(0x400,uint32_t(0xe12fff1e));put(0x404,uint32_t(0xe12fff1e));
    constexpr uint32_t base=0x40000000;
    ElfLoader loader(h.GetGuestMemoryBase(),h.GetGuestMemorySize(),base,base+0x10000);
    CHECK(loader.LoadFromMemory(bytes.data(),bytes.size()));CHECK(loader.Relocate([](const auto&,uint8_t){return 0;}));
    CHECK(h.MemoryRead32(base+0x380)==0x11);CHECK(h.MemoryRead32(base+0x384)==0x12345678);
    CHECK(loader.GetSymbolAddress("absolute")==0x12345678);CHECK(loader.GetSymbolAddress("entry")==base+0x400);
    CHECK(loader.GetInitArray()==std::vector<uint32_t>({base+0x400,base+0x404}));
    CHECK(h.LoadModulesFromMemory({{"fixture",bytes.data(),bytes.size(),base+0x100000,base+0x110000}}));
    std::string module,symbol;uint32_t module_base=0,symbol_address=0;
    CHECK(h.DescribeAddress(base+0x100400,module,module_base,symbol,symbol_address));
    CHECK(module=="fixture"&&module_base==base+0x100000&&symbol=="entry"&&symbol_address==base+0x100400);
    weak.st_info=ELF32_ST_INFO(STB_GLOBAL,STT_FUNC);put(0x190,weak);
    ElfLoader strong(h.GetGuestMemoryBase(),h.GetGuestMemorySize(),base,base+0x10000);
    CHECK(strong.LoadFromMemory(bytes.data(),bytes.size()));CHECK(!strong.Relocate([](const auto&,uint8_t){return 0;}));
    CHECK(h.MemoryRead32(base+0x384)==0&&h.MemoryRead32(base+0x388)==0x404);
    CHECK(strong.Relocate([](const auto& name,uint8_t type){return name=="optional"&&type==STT_FUNC?0x2222:0;}));
    CHECK(h.MemoryRead32(base+0x380)==0x2233);
    put(0x214,uint32_t(UINT32_MAX));
    ElfLoader bad(h.GetGuestMemoryBase(),h.GetGuestMemorySize(),base,base+0x10000);
    CHECK(!bad.LoadFromMemory(bytes.data(),bytes.size()));
    put(0x214,uint32_t(3));
    auto packed=dynamic;packed.back().d_tag=DT_ANDROID_REL;packed.back().d_un.d_val=0x340;
    packed.push_back({});memcpy(bytes.data()+0x280,packed.data(),packed.size()*8);
    dyn.p_filesz=dyn.p_memsz=packed.size()*8;put(sizeof(eh)+sizeof(load),dyn);
    ElfLoader packed_loader(h.GetGuestMemoryBase(),h.GetGuestMemorySize(),base,base+0x10000);
    CHECK(!packed_loader.LoadFromMemory(bytes.data(),bytes.size()));
    eh.e_phnum=3;put(0,eh);Elf32_Phdr tls{};tls.p_type=PT_TLS;put(sizeof(eh)+2*sizeof(load),tls);
    ElfLoader tls_loader(h.GetGuestMemoryBase(),h.GetGuestMemorySize(),base,base+0x10000);
    CHECK(!tls_loader.LoadFromMemory(bytes.data(),bytes.size()));
    printf("PASS stripped GNU hash ELF, weak/strong imports, atomic relocation validation, DT_INIT/init_array, SHN_ABS\n");
}
void ConditionClockDomains(DynarmicHost& h) {
    const uint32_t cond=h.GuestAlloc(4),mutex=h.GuestAlloc(4);
    const uint32_t realtime=h.GuestAlloc(8),monotonic=h.GuestAlloc(8),invalid=h.GuestAlloc(8);
    CHECK(cond&&mutex&&realtime&&monotonic&&invalid);
    h.MemoryWrite32(cond,0);h.MemoryWrite32(mutex,0x8000); // Error-check mutex.
    h.MemoryWrite32(invalid,0);h.MemoryWrite32(invalid+4,1000000000);
    auto deadline=[&](uint32_t p,clockid_t clock,long milliseconds) {
        timespec now{};CHECK(clock_gettime(clock,&now)==0);
        now.tv_nsec+=milliseconds*1000000L;
        now.tv_sec+=now.tv_nsec/1000000000;now.tv_nsec%=1000000000;
        h.MemoryWrite32(p,uint32_t(now.tv_sec));h.MemoryWrite32(p+4,uint32_t(now.tv_nsec));
    };
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==0);
    CHECK(Call(h,"pthread_cond_timedwait_monotonic_np",{cond,mutex,invalid})==EINVAL);
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==EDEADLK);
    // A MONOTONIC deadline must work on the same default REALTIME condition.
    deadline(monotonic,CLOCK_MONOTONIC,80);
    auto start=std::chrono::steady_clock::now();
    uint32_t rc;
    do { rc=Call(h,"pthread_cond_timedwait_monotonic_np",{cond,mutex,monotonic}); } while(rc==0);
    CHECK(rc==ETIMEDOUT);
    CHECK(std::chrono::steady_clock::now()-start>=std::chrono::milliseconds(60));
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==EDEADLK);
    deadline(realtime,CLOCK_REALTIME,80);
    start=std::chrono::steady_clock::now();
    do { rc=Call(h,"pthread_cond_timedwait",{cond,mutex,realtime}); } while(rc==0);
    CHECK(rc==ETIMEDOUT);
    CHECK(std::chrono::steady_clock::now()-start>=std::chrono::milliseconds(60));
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==EDEADLK);
    CHECK(Call(h,"pthread_mutex_unlock",{mutex})==0);

    // Thread calls bypass the non-atomic CHECK counter; only the coordinator
    // counts assertions. Each wait is bounded even if notification is broken.
    auto invoke=[&](const char* name,const std::vector<uint32_t>& args) {
        uint32_t target=h.GetThunkManager().FindRegisteredSymbol(name);
        if(!target) { fprintf(stderr,"FAIL condition worker symbol %s\n",name);std::abort(); }
        uint32_t result=h.RunFunction(target,args);
        if(h.HasFailed()) { fprintf(stderr,"FAIL condition worker %s\n",name);std::abort(); }
        return result;
    };
    auto exercise=[&](bool mixed,bool broadcast) {
        deadline(realtime,CLOCK_REALTIME,5000);deadline(monotonic,CLOCK_MONOTONIC,5000);
        std::atomic<unsigned> waiting=0,finished=0,errors=0;
        std::atomic<bool> proceed=false;
        auto worker=[&](bool mono) {
            if(invoke("pthread_mutex_lock",{mutex})!=0)++errors;
            ++waiting;
            while(!proceed.load(std::memory_order_acquire)) {
                uint32_t result=invoke(mono?"pthread_cond_timedwait_monotonic_np":"pthread_cond_timedwait",
                                       {cond,mutex,mono?monotonic:realtime});
                if(result) { ++errors;break; }
            }
            // The wait must return with exactly the original mutex held.
            if(invoke("pthread_mutex_lock",{mutex})!=EDEADLK)++errors;
            if(invoke("pthread_mutex_unlock",{mutex})!=0)++errors;
            ++finished;h.ReleaseCurrentThread();
        };
        std::thread aux(worker,true);
        std::thread primary;
        if(mixed)primary=std::thread(worker,false);
        const unsigned expected=mixed?2:1;
        const auto limit=std::chrono::steady_clock::now()+std::chrono::seconds(5);
        while(waiting.load(std::memory_order_acquire)!=expected&&std::chrono::steady_clock::now()<limit)
            std::this_thread::yield();
        CHECK(waiting.load(std::memory_order_acquire)==expected);
        // The last waiter incremented while holding the guest mutex. Acquiring
        // it here establishes that the native wait has released that mutex.
        CHECK(Call(h,"pthread_mutex_lock",{mutex})==0);
        CHECK(Call(h,"pthread_cond_destroy",{cond})==EBUSY);
        proceed.store(true,std::memory_order_release);
        CHECK(Call(h,broadcast?"pthread_cond_broadcast":"pthread_cond_signal",{cond})==0);
        CHECK(Call(h,"pthread_mutex_unlock",{mutex})==0);
        aux.join();if(mixed)primary.join();
        CHECK(finished.load()==expected&&errors.load()==0);
    };
    exercise(false,false); // Signal must reach an auxiliary-only waiter.
    exercise(true,true);   // Broadcast must reach primary and auxiliary waiters.
    CHECK(Call(h,"pthread_cond_destroy",{cond})==0);
    CHECK(Call(h,"pthread_cond_init",{cond,0})==0);
    h.MemoryWrite64(monotonic,0);
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==0);
    CHECK(Call(h,"pthread_cond_timedwait_monotonic_np",{cond,mutex,monotonic})==ETIMEDOUT);
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==EDEADLK);
    CHECK(Call(h,"pthread_mutex_unlock",{mutex})==0);
    GuestSyncForget(cond,4); // Exercise destruction through allocator retirement.
    h.MemoryWrite32(cond,0);
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==0);
    CHECK(Call(h,"pthread_cond_timedwait_monotonic_np",{cond,mutex,monotonic})==ETIMEDOUT);
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==EDEADLK);
    CHECK(Call(h,"pthread_mutex_unlock",{mutex})==0);
    CHECK(Call(h,"pthread_cond_destroy",{cond})==0);
    CHECK(Call(h,"pthread_mutex_destroy",{mutex})==0);
    for(uint32_t p:{cond,mutex,realtime,monotonic,invalid})h.GuestFree(p);
    printf("PASS condition clock domains, timeout/mutex ownership, auxiliary signal, mixed broadcast, busy destroy and reuse\n");
}

void PosixComplements(DynarmicHost& h) {
    uint32_t timeout=h.GuestAlloc(8);h.MemoryWrite64(timeout,0);
    CHECK(Call(h,"sysconf",{_SC_PAGESIZE})==4096);CHECK(Call(h,"getpagesize")==4096);
    CHECK(Call(h,"getauxval",{6})==4096);CHECK(Call(h,"getauxval",{16})&(1u<<12));
    uint32_t upper=h.MemoryRead32(h.GetThunkManager().FindRegisteredSymbol("_toupper_tab_"));
    CHECK(h.MemoryRead16(upper)==0xffff&&h.MemoryRead16(upper+('a'+1)*2)=='A');
    uint32_t sem=h.GuestAlloc(16),cond=h.GuestAlloc(4),mutex=h.GuestAlloc(4);
    h.MemoryWrite32(cond,0);h.MemoryWrite32(mutex,0);
    CHECK(Call(h,"sem_init",{sem,0,0})==0);
    CHECK(Call(h,"sem_timedwait",{sem,timeout})==UINT32_MAX&&h.MemoryRead32(h.GuestErrnoAddress())==ETIMEDOUT);
    CHECK(Call(h,"sem_post",{sem})==0);CHECK(Call(h,"sem_timedwait",{sem,timeout})==0);CHECK(Call(h,"sem_destroy",{sem})==0);
    CHECK(Call(h,"pthread_mutex_lock",{mutex})==0);
    CHECK(Call(h,"pthread_cond_timedwait_relative_np",{cond,mutex,timeout})==ETIMEDOUT);
    CHECK(Call(h,"pthread_cond_timedwait_monotonic_np",{cond,mutex,timeout})==ETIMEDOUT);
    CHECK(Call(h,"pthread_mutex_unlock",{mutex})==0);
    CHECK(Call(h,"pthread_cond_destroy",{cond})==0);CHECK(Call(h,"pthread_mutex_destroy",{mutex})==0);
    CHECK(Call(h,"select",{0,0,0,0,timeout})==0);
    uint32_t pair=h.GuestAlloc(8);CHECK(Call(h,"pipe",{pair})==0);
    int descriptors[]={int(h.MemoryRead32(pair)),int(h.MemoryRead32(pair+4))};
    uint32_t text=Text(h,"AB"),iov=h.GuestAlloc(16);
    uint32_t vectors[]={text,1,text+1,1};memcpy(h.GetGuestMemoryBase()+iov,vectors,sizeof(vectors));
    CHECK(Call(h,"writev",{uint32_t(descriptors[1]),iov,2})==2);
    uint32_t set=h.GuestAlloc(128);memset(h.GetGuestMemoryBase()+set,0,128);
    const uint32_t word=set+(descriptors[0]/32)*4;h.MemoryWrite32(word,1u<<(descriptors[0]%32));
    CHECK(Call(h,"select",{uint32_t(descriptors[0]+1),set,0,0,timeout})==1);
    CHECK(h.MemoryRead32(word)==1u<<(descriptors[0]%32));close(descriptors[0]);close(descriptors[1]);
    uint32_t name=Text(h,"localhost"),entry=Call(h,"gethostbyname",{name});CHECK(entry);
    CHECK(h.MemoryRead32(entry+8)==2&&h.MemoryRead32(entry+12)==4);
    uint32_t lib=Text(h,"libz.so"),symbol=Text(h,"inflate"),missing=Text(h,"lib_missing_bridge_fixture.so");
    CHECK(Call(h,"dlopen",{missing,2})==0);CHECK(Call(h,"dlerror"));CHECK(Call(h,"dlerror")==0);
    uint32_t handle=Call(h,"dlopen",{lib,2});CHECK(handle);
    CHECK(Call(h,"dlsym",{handle,symbol})==h.GetThunkManager().FindRegisteredSymbol("inflate"));
    CHECK(Call(h,"dlclose",{handle})==0);
    printf("PASS fd_set32/select, hostent32/localhost, dlopen/dlsym/dlerror\n");
}
void Audio(DynarmicHost& h) {
    char native_sdk[PROP_VALUE_MAX]{};
    int sdk_size=__system_property_get("ro.build.version.sdk",native_sdk);
    uint32_t property=h.GuestAlloc(PROP_VALUE_MAX+4);
    h.MemoryWrite32(property+PROP_VALUE_MAX,0xa55a1234);
    CHECK(Call(h,"__system_property_get",{Text(h,"ro.build.version.sdk"),property})==uint32_t(sdk_size));
    CHECK(strcmp(reinterpret_cast<char*>(h.GetGuestMemoryBase()+property),native_sdk)==0);
    CHECK(h.MemoryRead32(property+PROP_VALUE_MAX)==0xa55a1234);
    CHECK(Call(h,"__system_property_get",{Text(h,"ro.build.version.sdk"),0})==UINT32_MAX);
    uint32_t cpu_path=Text(h,"/proc/cpuinfo"),cpu_data=h.GuestAlloc(4097);
    uint32_t cpu=Call(h,"open",{cpu_path,O_RDONLY|O_CLOEXEC|O_NONBLOCK,0});CHECK(cpu!=UINT32_MAX);
    uint32_t cpu_flags=Call(h,"fcntl",{cpu,F_GETFL,0});CHECK(cpu_flags!=UINT32_MAX&&(cpu_flags&O_ACCMODE)==O_RDONLY&&(cpu_flags&O_NONBLOCK));
    CHECK(Call(h,"fcntl",{cpu,F_GETFD,0})==FD_CLOEXEC);
    struct stat cpu_stat{};CHECK(fstat(cpu,&cpu_stat)==0&&cpu_stat.st_nlink==0);
    uint32_t cpu_size=Call(h,"read",{cpu,cpu_data,4096});CHECK(cpu_size>0&&cpu_size<=4096);
    h.MemoryWrite8(cpu_data+cpu_size,0);
    const char* cpu_text=reinterpret_cast<const char*>(h.GetGuestMemoryBase()+cpu_data);
    CHECK(strstr(cpu_text,"CPU architecture\t: 7")&&strstr(cpu_text," neon ")&&strstr(cpu_text," vfpv3 "));
    CHECK(Call(h,"write",{cpu,cpu_data,1})==UINT32_MAX);
    CHECK(Call(h,"close",{cpu})==0);
    CHECK(Call(h,"open",{cpu_path,O_WRONLY,0})==UINT32_MAX);
    cpu=Call(h,"fopen",{cpu_path,Text(h,"r")});CHECK(cpu);
    CHECK(Call(h,"fread",{cpu_data,1,32,cpu})==32);CHECK(Call(h,"fclose",{cpu})==0);
    uint32_t output=h.GuestAlloc(32),source=h.GuestAlloc(64),sink=h.GuestAlloc(16),pcm=h.GuestAlloc(256);
    CHECK(Call(h,"slCreateEngine",{output,0,0,0,0,0})==SL_RESULT_SUCCESS);
    auto iid=[&](const char* name) { return h.MemoryRead32(h.GetThunkManager().FindRegisteredSymbol(name)); };
    CHECK(Call(h,"SLEngine_GetInterface",{h.MemoryRead32(output),iid("SL_IID_ENGINE"),output+4})==SL_RESULT_SUCCESS);
    uint32_t engine=h.MemoryRead32(output+4);
    CHECK(Call(h,"SLEngine_CreateOutputMix",{engine,output+8,0,0,0})==SL_RESULT_SUCCESS);
    uint32_t src[]={source+8,source+16,SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE,4,SL_DATAFORMAT_PCM,1,SL_SAMPLINGRATE_44_1,16,16,SL_SPEAKER_FRONT_CENTER,SL_BYTEORDER_LITTLEENDIAN};
    memcpy(h.GetGuestMemoryBase()+source,src,sizeof(src));
    uint32_t snk[]={sink+8,0,SL_DATALOCATOR_OUTPUTMIX,h.MemoryRead32(output+8)};memcpy(h.GetGuestMemoryBase()+sink,snk,sizeof(snk));
    std::vector<uint32_t> players;
    const uint32_t key=Text(h,"androidPlaybackStreamType"),value=h.GuestAlloc(8);
    h.MemoryWrite32(value,SL_ANDROID_STREAM_MEDIA);h.MemoryWrite32(value+4,0xa55a1234);
    CHECK(Call(h,"SLObject_Realize",{0,0})==SL_RESULT_PARAMETER_INVALID);
    for(int i=0;i<2;++i) {
        CHECK(Call(h,"SLEngine_CreateAudioPlayer",{engine,output+12,source,sink,0,0,0})==SL_RESULT_SUCCESS);
        uint32_t player=h.MemoryRead32(output+12);players.push_back(player);
        h.MemoryWrite32(output+28,0x1234a55a);
        CHECK(Call(h,"SLObject_GetState",{player,output+24})==SL_RESULT_SUCCESS);
        CHECK(h.MemoryRead32(output+24)==SL_OBJECT_STATE_UNREALIZED);
        CHECK(Call(h,"SLPlayer_GetInterface",{player,iid("SL_IID_ANDROIDSIMPLEBUFFERQUEUE"),output+16})==SL_RESULT_PRECONDITIONS_VIOLATED);
        CHECK(Call(h,"SLPlayer_GetInterface",{player,iid("SL_IID_ANDROIDCONFIGURATION"),output+16})==SL_RESULT_SUCCESS);
        uint32_t configuration=h.MemoryRead32(output+16);
        CHECK(Call(h,"SLConfig_SetConfiguration",{configuration,key,0,4})==SL_RESULT_PARAMETER_INVALID);
        CHECK(Call(h,"SLConfig_SetConfiguration",{configuration,key,value,4})==SL_RESULT_SUCCESS);
        h.MemoryWrite32(output+24,4);h.MemoryWrite32(value,UINT32_MAX);
        CHECK(Call(h,"SLConfig_GetConfiguration",{configuration,key,output+24,value})==SL_RESULT_SUCCESS);
        CHECK(h.MemoryRead32(output+24)==4&&h.MemoryRead32(value)==SL_ANDROID_STREAM_MEDIA);
        CHECK(h.MemoryRead32(value+4)==0xa55a1234&&h.MemoryRead32(output+28)==0x1234a55a);
        CHECK(Call(h,"SLObject_Realize",{player,0})==SL_RESULT_SUCCESS);
        CHECK(Call(h,"SLObject_GetState",{player,output+24})==SL_RESULT_SUCCESS);
        CHECK(h.MemoryRead32(output+24)==SL_OBJECT_STATE_REALIZED);
        CHECK(Call(h,"SLPlayer_GetInterface",{player,iid("SL_IID_ANDROIDSIMPLEBUFFERQUEUE"),output+16})==SL_RESULT_SUCCESS);
        uint32_t queue=h.MemoryRead32(output+16);CHECK(queue);
        CHECK(Call(h,"SLBufferQueue_Enqueue",{queue,pcm,256})==SL_RESULT_SUCCESS);
        CHECK(Call(h,"SLBufferQueue_Clear",{queue})==SL_RESULT_SUCCESS);
        CHECK(Call(h,"SLBufferQueue_GetState",{queue,output+20})==SL_RESULT_SUCCESS);
        CHECK(h.MemoryRead32(output+20)==0);
    }
    CHECK(players[0]!=players[1]);
    auto completed=std::make_shared<std::atomic<bool>>(false);
    const uint32_t destroy=h.GetThunkManager().FindRegisteredSymbol("SLObject_Destroy");
    uint32_t callback=h.GetThunkManager().RegisterThunk("test_audio_destroy",[completed,destroy,player=players[0]](auto&,auto& host) {
        host.RunFunction(destroy,{player});completed->store(true,std::memory_order_release);
    });
    CHECK(Call(h,"SLPlayer_GetInterface",{players[0],iid("SL_IID_ANDROIDSIMPLEBUFFERQUEUE"),output+16})==SL_RESULT_SUCCESS);
    uint32_t queue=h.MemoryRead32(output+16);
    CHECK(Call(h,"SLBufferQueue_RegisterCallback",{queue,callback,0})==SL_RESULT_SUCCESS);
    CHECK(Call(h,"SLPlayer_GetInterface",{players[0],iid("SL_IID_PLAY"),output+20})==SL_RESULT_SUCCESS);
    CHECK(Call(h,"SLBufferQueue_Enqueue",{queue,pcm,256})==SL_RESULT_SUCCESS);
    CHECK(Call(h,"SLPlay_SetPlayState",{h.MemoryRead32(output+20),SL_PLAYSTATE_PLAYING})==SL_RESULT_SUCCESS);
    for(int i=0;i<200&&!completed->load(std::memory_order_acquire);++i)std::this_thread::sleep_for(std::chrono::milliseconds(10));
    CHECK(completed->load(std::memory_order_acquire));
    Call(h,"SLObject_Destroy",{players[1]});
    CHECK(!HasPendingAudioCallbacks());StopAudioThread();
    printf("PASS OpenSL configuration before Realize, native state, two queues, worker callback, nested self-destruction\n");
}
void InvalidStackFetch() {
    DynarmicHost h;CHECK(h.Initialize());
    const auto [bottom,top]=h.GuestStackBounds();
    const uint32_t data=h.GuestAlloc(64),code=h.GuestAlloc(12);CHECK(data&&code);
    h.MemoryWrite32(data,0xa55a1234);h.MemoryWrite32(top-64,0x13579bdf);
    h.AddExecutableRange(code,12);
    // SUB sp,#64; MOV r7,sp; BLX r7, with guard-page and end-of-arena diagnostic pointers.
    const uint32_t words[]={0xe24dd040,0xe1a0700d,0xe12fff37};
    memcpy(h.GetGuestMemoryBase()+code,words,sizeof(words));
    const uint32_t guard=bottom-uint32_t(sysconf(_SC_PAGESIZE));
    h.RunFunction(code,{guard,UINT32_MAX-3,data});
    CHECK(h.HasFailed());CHECK(h.CurrentJit().Regs()[7]==top-64);
    CHECK(h.CurrentJit().Regs()[13]==top-64&&h.CurrentJit().Regs()[14]==code+12);
    CHECK(h.CurrentJit().Regs()[0]==guard&&h.CurrentJit().Regs()[1]==UINT32_MAX-3);
    CHECK(h.MemoryRead32(data)==0xa55a1234&&h.MemoryRead32(top-64)==0x13579bdf);
    h.ReleaseCurrentThread();
    printf("PASS non-executable stack target, guarded/arena-edge snapshots, unchanged guest state\n");
}
}
int main(int argc,char** argv) {
    setvbuf(stdout,nullptr,_IONBF,0);
    printf("Native regression pid=%d\n",getpid());
    if(argc==2&&strcmp(argv[1],"invalid-stack")==0) {
        InvalidStackFetch();printf("PASS all %u isolated stack checks\n",checks);return 0;
    }
    if(argc==2&&(strcmp(argv[1],"cache-pressure")==0||strcmp(argv[1],"cache-pressure-thumb")==0)) {
        DynarmicHost host;CHECK(host.Initialize());CodeCachePressure(host,strcmp(argv[1],"cache-pressure-thumb")==0);
        host.ReleaseCurrentThread();printf("PASS all %u cache-pressure checks\n",checks);return 0;
    }
    force_legacy_condition=argc==2&&strcmp(argv[1],"legacy-condition")==0;
    if(argc!=1&&!force_legacy_condition)return 2;
    DynarmicHost host;CHECK(host.Initialize());
    if(force_legacy_condition) {
        PosixComplements(host);ConditionClockDomains(host);
        CHECK(masked_condition_lookups.load()==2);
        host.ReleaseCurrentThread();
        printf("PASS all %u legacy condition checks; both native clock capabilities masked\n",checks);return 0;
    }
    AbiAndDispatch(host);FastDispatch(host);OriginalAirLookup(host);LargeHeapReuse(host);ElfFixtures(host);AirImports(host);JumpThreadCleanup(host);NaturalTlsCleanup(host);TlsKeyDeletion(host);StringsAndStdio(host);ScansetParsing(host);CallbacksAndThreads(host);PosixComplements(host);ConditionClockDomains(host);Zlib(host);Graphics(host);Audio(host);
    // An invalid indirect target must fail, preserving the caller for diagnosis.
    uint32_t invalid=host.GuestAlloc(8);CHECK(invalid);host.AddExecutableRange(invalid,8);
    host.MemoryWrite32(invalid,0xe3a030a0);host.MemoryWrite32(invalid+4,0xe12fff33);
    host.RunFunction(invalid);CHECK(host.HasFailed());CHECK(host.CurrentJit().Regs()[14]==invalid+8);
    printf("PASS all %u checks; %zu registered symbols; page size %ld\n",checks,host.GetThunkManager().GetThunkSymbolTable().size(),sysconf(_SC_PAGESIZE));
    host.ReleaseCurrentThread();return 0;
}
