// Native regression: real bridge thunks with a deterministic OpenSL queue backend.
#include "dynarmic_host.h"
#include "thunk_manager.h"
#include "thunks_opensles.h"
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <vector>

namespace {
unsigned checks = 0;
#define CHECK(expr) do { ++checks; if (!(expr)) { std::fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #expr); std::abort(); } } while (0)

struct Buffer { const void* data; SLuint32 size; };
std::deque<Buffer> queued;
slAndroidSimpleBufferQueueCallback completion = nullptr;
void* completion_context = nullptr;
SLuint32 native_index = 0;
SLuint32 native_capacity = 0;
bool realized = false;
bool destroyed = false;

SLObjectItf_ engine_object{}, mix_object{}, player_object{};
SLEngineItf_ engine{};
SLPlayItf_ play{};
SLVolumeItf_ volume{};
SLAndroidSimpleBufferQueueItf_ queue{};
SLAndroidConfigurationItf_ configuration{};
const SLObjectItf_* engine_object_pointer = &engine_object;
const SLObjectItf_* mix_object_pointer = &mix_object;
const SLObjectItf_* player_object_pointer = &player_object;
const SLEngineItf_* engine_pointer = &engine;
const SLPlayItf_* play_pointer = &play;
const SLVolumeItf_* volume_pointer = &volume;
const SLAndroidSimpleBufferQueueItf_* queue_pointer = &queue;
const SLAndroidConfigurationItf_* configuration_pointer = &configuration;

bool IsIid(SLInterfaceID a, SLInterfaceID b) {
    return a && b && std::memcmp(a, b, sizeof(SLInterfaceID_)) == 0;
}

void InitializeBackend() {
    engine_object.Realize = mix_object.Realize = player_object.Realize =
        [](SLObjectItf self, SLboolean) -> SLresult {
            if (self == &player_object_pointer) realized = true;
            return SL_RESULT_SUCCESS;
        };
    engine_object.GetInterface = [](SLObjectItf, SLInterfaceID iid, void* output) -> SLresult {
        CHECK(IsIid(iid, SL_IID_ENGINE));
        *static_cast<SLEngineItf*>(output) = &engine_pointer;
        return SL_RESULT_SUCCESS;
    };
    engine.CreateOutputMix = [](SLEngineItf, SLObjectItf* output, SLuint32,
                               const SLInterfaceID*, const SLboolean*) -> SLresult {
        *output = &mix_object_pointer;
        return SL_RESULT_SUCCESS;
    };
    engine.CreateAudioPlayer = [](SLEngineItf, SLObjectItf* output, SLDataSource* source,
                                 SLDataSink*, SLuint32, const SLInterfaceID*,
                                 const SLboolean*) -> SLresult {
        native_capacity = static_cast<SLDataLocator_AndroidSimpleBufferQueue*>(source->pLocator)->numBuffers;
        CHECK(static_cast<SLDataFormat_PCM*>(source->pFormat)->samplesPerSec == 24000000);
        *output = &player_object_pointer;
        return SL_RESULT_SUCCESS;
    };
    configuration.SetConfiguration = [](SLAndroidConfigurationItf, const SLchar*,
                                        const void*, SLuint32) -> SLresult {
        return SL_RESULT_SUCCESS;
    };
    player_object.GetInterface = [](SLObjectItf, SLInterfaceID iid, void* output) -> SLresult {
        if (IsIid(iid, SL_IID_ANDROIDCONFIGURATION))
            *static_cast<SLAndroidConfigurationItf*>(output) = &configuration_pointer;
        else if (IsIid(iid, SL_IID_PLAY))
            *static_cast<SLPlayItf*>(output) = &play_pointer;
        else if (IsIid(iid, SL_IID_VOLUME))
            *static_cast<SLVolumeItf*>(output) = &volume_pointer;
        else if (IsIid(iid, SL_IID_ANDROIDSIMPLEBUFFERQUEUE))
            *static_cast<SLAndroidSimpleBufferQueueItf*>(output) = &queue_pointer;
        else
            return SL_RESULT_FEATURE_UNSUPPORTED;
        return SL_RESULT_SUCCESS;
    };
    player_object.GetState = [](SLObjectItf, SLuint32* output) -> SLresult {
        *output = realized ? SL_OBJECT_STATE_REALIZED : SL_OBJECT_STATE_UNREALIZED;
        return SL_RESULT_SUCCESS;
    };
    play.SetPlayState = [](SLPlayItf, SLuint32) -> SLresult { return SL_RESULT_SUCCESS; };
    queue.RegisterCallback = [](SLAndroidSimpleBufferQueueItf,
                                slAndroidSimpleBufferQueueCallback callback,
                                void* context) -> SLresult {
        completion = callback;
        completion_context = context;
        return SL_RESULT_SUCCESS;
    };
    queue.Enqueue = [](SLAndroidSimpleBufferQueueItf, const void* buffer,
                       SLuint32 size) -> SLresult {
        CHECK(!destroyed && buffer && size);
        if (queued.size() >= native_capacity) return SL_RESULT_BUFFER_INSUFFICIENT;
        queued.push_back({buffer, size});
        return SL_RESULT_SUCCESS;
    };
    queue.GetState = [](SLAndroidSimpleBufferQueueItf,
                        SLAndroidSimpleBufferQueueState* output) -> SLresult {
        *output = {static_cast<SLuint32>(queued.size()), native_index};
        return SL_RESULT_SUCCESS;
    };
    queue.Clear = [](SLAndroidSimpleBufferQueueItf) -> SLresult {
        queued.clear();
        native_index = 0;
        return SL_RESULT_SUCCESS;
    };
    player_object.Destroy = [](SLObjectItf) {
        CHECK(queued.empty());
        destroyed = true;
        completion = nullptr;
        completion_context = nullptr;
    };
}

uint32_t Call(DynarmicHost& host, const char* name,
              const std::vector<uint32_t>& arguments = {}) {
    const uint32_t address = host.GetThunkManager().FindRegisteredSymbol(name);
    CHECK(address);
    const uint32_t result = host.RunFunction(address, arguments);
    CHECK(!host.HasFailed());
    return result;
}

void ConsumeBuffer() {
    CHECK(!queued.empty() && completion && completion_context);
    queued.pop_front();
    ++native_index;
    completion(&queue_pointer, completion_context);
}
}

// This executable supplies the backend; libOpenSLES still supplies the standard IID data.
extern "C" SL_API SLresult SLAPIENTRY slCreateEngine(SLObjectItf* output, SLuint32,
        const SLEngineOption*, SLuint32, const SLInterfaceID*, const SLboolean*) {
    InitializeBackend();
    *output = &engine_object_pointer;
    return SL_RESULT_SUCCESS;
}

int main() {
    DynarmicHost host;
    CHECK(host.Initialize());
    const uint32_t output = host.GuestAlloc(32), source = host.GuestAlloc(64),
        sink = host.GuestAlloc(16), pcm = host.GuestAlloc(1024 * 6 * 4);
    CHECK(output && source && sink && pcm);
    CHECK(Call(host, "slCreateEngine", {output, 0, 0, 0, 0, 0}) == SL_RESULT_SUCCESS);
    auto iid = [&](const char* name) {
        return host.MemoryRead32(host.GetThunkManager().FindRegisteredSymbol(name));
    };
    CHECK(Call(host, "SLEngine_GetInterface", {host.MemoryRead32(output), iid("SL_IID_ENGINE"), output + 4}) == SL_RESULT_SUCCESS);
    const uint32_t guest_engine = host.MemoryRead32(output + 4);
    CHECK(Call(host, "SLEngine_CreateOutputMix", {guest_engine, output + 8, 0, 0, 0}) == SL_RESULT_SUCCESS);
    uint32_t src[] = {source + 8, source + 16, SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE,
        6, SL_DATAFORMAT_PCM, 2, 24000000, 16, 16,
        SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT, SL_BYTEORDER_LITTLEENDIAN};
    std::memcpy(host.GetGuestMemoryBase() + source, src, sizeof(src));
    uint32_t snk[] = {sink + 8, 0, SL_DATALOCATOR_OUTPUTMIX, host.MemoryRead32(output + 8)};
    std::memcpy(host.GetGuestMemoryBase() + sink, snk, sizeof(snk));
    CHECK(Call(host, "SLEngine_CreateAudioPlayer", {guest_engine, output + 12, source, sink, 0, 0, 0}) == SL_RESULT_SUCCESS);
    const uint32_t player = host.MemoryRead32(output + 12);
    CHECK(Call(host, "SLObject_Realize", {player, 0}) == SL_RESULT_SUCCESS);
    CHECK(Call(host, "SLPlayer_GetInterface", {player, iid("SL_IID_ANDROIDSIMPLEBUFFERQUEUE"), output + 16}) == SL_RESULT_SUCCESS);
    const uint32_t guest_queue = host.MemoryRead32(output + 16);
    CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, pcm, 0}) == SL_RESULT_PARAMETER_INVALID);
    CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, UINT32_MAX - 1, 8}) == SL_RESULT_PARAMETER_INVALID);
    CHECK(queued.empty());
    // FMOD queues its ring before its mixer writes newly rendered PCM into that ring.
    for (unsigned i = 0; i < 6; ++i) {
        CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, pcm + i * 4096, 4096}) == SL_RESULT_SUCCESS);
        CHECK(queued[i].data == host.GetGuestMemoryBase() + pcm + i * 4096);
        CHECK(queued[i].size == 4096);
    }
    for (unsigned i = 0; i < 6; ++i) {
        host.MemoryWrite32(pcm + i * 4096, 0x12340000 + i);
        uint32_t actual = 0;
        std::memcpy(&actual, queued[i].data, sizeof(actual));
        CHECK(actual == 0x12340000 + i);
    }
    ConsumeBuffer();
    CHECK(HasPendingAudioCallbacks());
    CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, pcm, 4096}) == SL_RESULT_SUCCESS);
    CHECK(queued.back().data == host.GetGuestMemoryBase() + pcm);
    CHECK(Call(host, "SLBufferQueue_GetState", {guest_queue, output + 20}) == SL_RESULT_SUCCESS);
    CHECK(host.MemoryRead32(output + 20) == 6 && host.MemoryRead32(output + 24) == 1);
    CHECK(Call(host, "SLBufferQueue_Clear", {guest_queue}) == SL_RESULT_SUCCESS);
    CHECK(queued.empty() && !HasPendingAudioCallbacks());
    CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, pcm, 4096}) == SL_RESULT_SUCCESS);
    ConsumeBuffer();
    CHECK(HasPendingAudioCallbacks());
    CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, pcm, 4096}) == SL_RESULT_SUCCESS);
    Call(host, "SLObject_Destroy", {player});
    CHECK(destroyed && queued.empty() && !HasPendingAudioCallbacks());
    CHECK(Call(host, "SLBufferQueue_Enqueue", {guest_queue, pcm, 4096}) == SL_RESULT_PRECONDITIONS_VIOLATED);
    host.GuestFree(pcm);
    std::printf("PASS native OpenSL PCM identity, post-enqueue mixer writes, completion/refill, bounds, Clear/Destroy; %u checks\n", checks);
}
