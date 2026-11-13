# arm64-bridge-tbs

Unreleased, unfinished ARM64 compatibility port of **The Banner Saga 1.5.16**
for modern Android, using Dynarmic.

**This project has not been released and is not finished.** This is a development
snapshot for reproducing and continuing the port, not a supported public game
release. No APKs, game assets, original game libraries or signing keys are supplied.

Project URL: <https://github.com/phys-winner/arm64-bridge-tbs>

## How it works

The ARM64 bridge loads the original ARM32 Adobe AIR and FMOD libraries inside a
64-bit Android process. Dynarmic translates ARMv7 instructions to ARM64; the bridge
implements the required JNI, libc/POSIX, Android, OpenGL ES, EGL, OpenSL ES and ZIP
interfaces. The APK exposes only `arm64-v8a`; the original guest libraries are
stored as assets. Root is not required to run the game.

The port includes startup/lifecycle fixes, application-specific storage and data
migration, input fixes, menu adjustments and direct reading of the original OBB
from the APK without extracting it on first launch. The current configuration is
minimum Android API 24, target API 37.

## Status and limitations

- Earlier snapshots ran on an ARM64-only Pixel 10. The latest local snapshot was
  exercised on a Realme RMX3371, Android 15, with 4 KiB runtime pages. These are
  separate results: the latest snapshot has not been accepted on ARM64-only hardware.
- Native ELF segments have 16 KiB alignment. **Execution with real 16 KiB runtime
  pages has not been verified.** Alignment alone does not establish compatibility.
- Startup, options, tutorial battles, returning to the menu and normal exit were
  tested in earlier local sessions. The full campaign, all scenes and broad device
  compatibility have not been tested.
- Repeated New Game runs showed residual native/unknown memory growth; a stable
  plateau and the absence of a leak have not been established.
- Loading remains slow on weaker devices. Image decoding changes improved the
  measured tutorial load on one device but may increase memory use.
- Physical audio latency has not been measured. After video playback, system UI
  can occasionally intercept the settings button; backgrounding and resuming the
  application restored access in the tested case.
- The recipe supports one exact original APK/OBB pair, specified below.

## Contents

| Path | Purpose |
| --- | --- |
| `arm64_bridge/src/` | Native bridge and generated JNI bindings |
| `arm64_bridge/tests/` | Native, audio, ART/JNI, surface and symbol regressions |
| `arm64_bridge/patches/` | Local Dynarmic backend fixes applied to the external dependency |
| `tools/prepare_port.py` | Guarded source preparation from your original APK |
| `tools/port-patches.json` | Copy/insert patch instructions, removals and SHA-256 checks; SWFs are patched after decompression |
| `tools/android/` | New Android integration code and configuration written for the port |
| `work/research_cache/` | Streaming whole-OBB packer, bounded reader checks and payload fingerprints |

Original APKs, OBBs, decoded game trees, SWFs, guest ELF libraries, screenshots,
local notes, build outputs and keys are excluded from Git. The recipe copies
unchanged bytes from your original files and checks every reconstructed file.

## Inputs and tools

Supply your own original game files:

| Input | Bytes | SHA-256 |
| --- | ---: | --- |
| `air_com_stoicstudio_BannerSaga-1005016.apk` | 35,733,725 | `0dcb08fd2ebb34f890da2d8ac34857d740cdb28b92d7c62f3e205bb9b36214d2` |
| `main.1005016.air.com.stoicstudio.BannerSaga.obb` | 1,902,742,603 | `9adc35cd9b5d9f3f041672d612b34f2ba6dd486118215e07489607e384d4f8c6` |

The documented build uses Windows/PowerShell, Python 3.11+ (standard library only),
JDK 24, Git, Apktool **3.0.3**, Android NDK **27.2.12479018**, and SDK CMake **3.22.1**.
SDK build-tools **36.1.0** provide `zipalign`, `apksigner` and `d8` below. Install
the Android API 37 platform for the package's current target SDK; the native
bridge builds against API 24.

Dependency source code is not included in this repository. On the first build,
pass `-AllowNetwork` to download Boost **1.83.0** and Dynarmic revision
`e77b1ba0b7da7cbe93021b01a663acfe7c4dd516`, including its pinned fmt, mcl, oaknut
and robin-map submodules. The Boost archive is verified against the
[official SHA-256](https://archives.boost.io/release/1.83.0/source/boost_1_83_0.tar.bz2.json).
CMake applies [the local Dynarmic patch](arm64_bridge/patches/dynarmic.patch)
automatically. Downloaded sources and their licenses stay under the ignored
`arm64_bridge/build_arm64/_deps/` directory. Subsequent builds work from this
cache without `-AllowNetwork`; a clean checkout needs network access once.

If using `-DynarmicSourceDirectory` to supply a local tree instead, it must already
contain the pinned submodules and the local patch. CMake source overrides bypass
the download/patch step. Boost must still be present in the build cache.

## Prepare and build

Run from the repository root. Adjust tool and input paths for your machine.
The preparation output must not already exist; existing projects are never
overwritten.

```powershell
$Sdk = "$env:LOCALAPPDATA/Android/Sdk"
$Java = 'C:/Portable/jdk-24.0.1/bin/java.exe'
$Apktool = 'D:/tools/apktool-3.0.3.jar'
$OriginalApk = 'D:/games/air_com_stoicstudio_BannerSaga-1005016.apk'
$BuildTools = "$Sdk/build-tools/36.1.0"

python -B tools/prepare_port.py --self-check
python -B tools/prepare_port.py --apk $OriginalApk --apktool $Apktool --java $Java
python -B arm64_bridge/generate_air_natives.py --check `
  --original work/reproduction/original/smali `
  --current work/reproduction/app/smali

powershell -NoProfile -File arm64_bridge/build_arm64.ps1 -SdkRoot $Sdk -BuildTests -AllowNetwork
New-Item -ItemType Directory -Force work/reproduction/app/lib/arm64-v8a | Out-Null
Copy-Item arm64_bridge/dist/libCore.so work/reproduction/app/lib/arm64-v8a/libCore.so

& $Java -jar $Apktool b -p work/reproduction/framework `
  -o work/reproduction/base-unaligned.apk work/reproduction/app
& "$BuildTools/zipalign.exe" -P 16 -f 4 `
  work/reproduction/base-unaligned.apk work/reproduction/base.apk
```

`work/reproduction/original/` contains the untouched decoded input;
`work/reproduction/app/` contains prepared sources, including the nine original
ARM32 libraries copied into `assets/guest_libs/`. Both remain ignored. The bridge
library is compiled separately. The prepared manifest's `uniqueappversionid`
matches the reconstructed AIR assets; update it if you change assets later to
invalidate AIR's cache.

## Embed the OBB and sign locally

Place your original OBB at
`original/air.com.stoicstudio.BannerSaga/main.1005016.air.com.stoicstudio.BannerSaga.obb`.
The packer checks its identity/content, streams it into the APK as an uncompressed
aligned entry, and verifies that base entries were preserved. It refuses existing
output files. The full APK is approximately 1.95 GB.

```powershell
python -B work/research_cache/embed_whole_obb.py --self-check
python -B work/research_cache/check_direct_readers.py --self-check
$BaseSha = (Get-FileHash work/reproduction/base.apk -Algorithm SHA256).Hash.ToLowerInvariant()
$SwfSha = (Get-FileHash work/reproduction/app/assets/GameMainAndroidMobile.swf -Algorithm SHA256).Hash.ToLowerInvariant()
python -B work/research_cache/embed_whole_obb.py --pack `
  --base work/reproduction/base.apk --base-sha $BaseSha --swf-sha $SwfSha `
  --output work/research_cache/port-unsigned.apk

& "$BuildTools/zipalign.exe" -c -P 16 4 work/research_cache/port-unsigned.apk
& "$BuildTools/apksigner.bat" sign --ks 'D:/keys/your-key.jks' `
  --out work/reproduction/port.apk work/research_cache/port-unsigned.apk
& "$BuildTools/apksigner.bat" verify --verbose --print-certs work/reproduction/port.apk
& "$BuildTools/zipalign.exe" -c -P 16 4 work/reproduction/port.apk
$ApkSha = (Get-FileHash work/reproduction/port.apk -Algorithm SHA256).Hash.ToLowerInvariant()
python -B work/research_cache/embed_whole_obb.py --check `
  --base work/reproduction/base.apk --base-sha $BaseSha --swf-sha $SwfSha `
  --apk work/reproduction/port.apk --apk-sha $ApkSha
```

Use your own signing key. Your signature differs from the original game and any
local build signed with another key. Back up saves before replacing an existing
installation. The goal is to reproduce the sources and build process; a
byte-identical signed APK is not promised.

## Checks

These host checks need neither a phone nor game files:

```powershell
python -B tools/prepare_port.py --self-check
python -B arm64_bridge/tests/test_check_symbols.py
python -B work/research_cache/embed_whole_obb.py --self-check
python -B work/research_cache/check_direct_readers.py --self-check
```

After building with `-BuildTests`, run native/audio/ART tests on a selected Android
device. This pushes regression executables and a test DEX to `/data/local/tmp`;
it does not establish full game compatibility.

```powershell
powershell -NoProfile -File arm64_bridge/tests/run_android_tests.ps1 `
  -Serial '<your-device-serial>' -SdkRoot $Sdk `
  -JdkRoot 'C:/Portable/jdk-24.0.1' -BuildToolsVersion '36.1.0'
```

Game startup, saves, audio, campaign progression, memory behavior and actual
16 KiB runtime execution still require device testing.

## License

Original project code is licensed under **GPL-3.0-or-later**, a strong copyleft
license; see [LICENSE](LICENSE). Dependencies retain their upstream licenses;
see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). This grants no rights to
proprietary game data, Adobe AIR or FMOD. The Banner Saga belongs to its rights
holders. This is an unofficial project with no affiliation or endorsement.
