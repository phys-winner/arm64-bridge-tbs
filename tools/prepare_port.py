"""Recreate the unfinished port sources from a user-supplied original APK."""
import argparse
import hashlib
import json
import lzma
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import zlib

HERE = Path(__file__).resolve().parent
APK_SHA256 = "0dcb08fd2ebb34f890da2d8ac34857d740cdb28b92d7c62f3e205bb9b36214d2"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def checked_path(root, name):
    path = (root / name).resolve()
    if not path.is_relative_to(root.resolve()) or path == root.resolve():
        raise ValueError("Recipe path escapes its root: " + name)
    return path


def unpack_swf(data):
    if len(data) < 8 or not 8 <= int.from_bytes(data[4:8], "little") <= 64 * 1024 * 1024:
        raise ValueError("Invalid SWF length")
    if data[:3] == b"FWS":
        raw = data
    elif data[:3] == b"CWS":
        raw = b"FWS" + data[3:8] + zlib.decompress(data[8:])
    elif data[:3] == b"ZWS" and len(data) >= 17:
        if int.from_bytes(data[8:12], "little") != len(data) - 17:
            raise ValueError("Invalid compressed SWF length")
        prop = data[12]
        filters = [dict(id=lzma.FILTER_LZMA1, lc=prop % 9, lp=prop // 9 % 5,
                        pb=prop // 45, dict_size=int.from_bytes(data[13:17], "little"))]
        raw = b"FWS" + data[3:8] + lzma.decompress(data[17:], format=lzma.FORMAT_RAW, filters=filters)
    else:
        raise ValueError("Unsupported SWF compression")
    if len(raw) != int.from_bytes(raw[4:8], "little"):
        raise ValueError("SWF length mismatch")
    return raw


def pack_swf(raw, header):
    if header[:3] == b"CWS":
        return b"CWS" + raw[3:8] + zlib.compress(raw[8:])
    if header[:3] == b"ZWS":
        prop = header[12]
        filters = [dict(id=lzma.FILTER_LZMA1, lc=prop % 9, lp=prop // 9 % 5,
                        pb=prop // 45, dict_size=int.from_bytes(header[13:17], "little"))]
        body = lzma.compress(raw[8:], format=lzma.FORMAT_RAW, filters=filters)
        return b"ZWS" + raw[3:8] + struct.pack("<I", len(body)) + header[12:17] + body
    if header[:3] == b"FWS":
        return raw
    raise ValueError("Unsupported target SWF compression")


def apply_delta(source, patch):
    if sha(source) != patch["source_sha256"]:
        raise ValueError("Patch source SHA-256 mismatch")
    decoded = unpack_swf(source) if "swf_header" in patch else source
    if patch.get("normalize_lf"):
        decoded = decoded.replace(b"\r\n", b"\n")
    result = bytearray()
    for operation in patch["ops"]:
        if len(operation) == 2:
            start, size = operation
            if not isinstance(start, int) or not isinstance(size, int) or start < 0 or size < 0 or start + size > len(decoded):
                raise ValueError("Patch copy range is out of bounds")
            result.extend(decoded[start:start + size])
        elif len(operation) == 1 and isinstance(operation[0], str):
            result.extend(bytes.fromhex(operation[0]))
        else:
            raise ValueError("Invalid patch operation")
        if len(result) > patch["decoded_size"]:
            raise ValueError("Patch output exceeds its declared size")
    if len(result) != patch["decoded_size"]:
        raise ValueError("Patch output length mismatch")
    result = bytes(result)
    if "swf_header" in patch:
        result = pack_swf(result, bytes.fromhex(patch["swf_header"]))
    if sha(result) != patch["target_sha256"]:
        raise ValueError("Patch target SHA-256 mismatch")
    return result


def self_check():
    source = b"hello original world"
    target = b"hello port world"
    patch = dict(source_sha256=sha(source), target_sha256=sha(target),
                 decoded_size=len(target), ops=[[0, 6], [b"port".hex()], [14, 6]])
    assert apply_delta(source, patch) == target
    crlf = source.replace(b" ", b"\r\n")
    normalized = crlf.replace(b"\r\n", b"\n")
    assert apply_delta(crlf, dict(source_sha256=sha(crlf), target_sha256=sha(normalized),
                                 decoded_size=len(normalized), normalize_lf=True,
                                 ops=[[0, len(normalized)]])) == normalized
    for bad in (dict(patch, source_sha256="0" * 64), dict(patch, target_sha256="0" * 64),
                dict(patch, ops=[[-1, 6]]), dict(patch, ops=[[0, 100]]),
                dict(patch, decoded_size=1), dict(patch, ops=[[0, 1, 2]])):
        try:
            apply_delta(source, bad)
        except ValueError:
            pass
        else:
            raise AssertionError("Invalid delta accepted")
    raw = b"FWS\x23" + struct.pack("<I", 24) + b"synthetic fixture"
    raw = raw[:4] + struct.pack("<I", len(raw)) + raw[8:]
    for header in (raw[:8], b"CWS" + raw[3:8], b"ZWS" + raw[3:8] + b"\0" * 4 + bytes.fromhex("5d00002000")):
        packed = pack_swf(raw, header)
        assert unpack_swf(packed) == raw
        same = dict(source_sha256=sha(packed), target_sha256=sha(packed),
                    decoded_size=len(raw), swf_header=packed[:17].hex(), ops=[[0, len(raw)]])
        assert apply_delta(packed, same) == packed
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        assert checked_path(root, "app/file").is_relative_to(root)
        for name in ("../escape", str(root.parent / "escape"), "."):
            try:
                checked_path(root, name)
            except ValueError:
                pass
            else:
                raise AssertionError("Escaping path accepted")
    print("PASS: delta hashes, bounds, malformed operations, three SWF formats and path confinement")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-check", action="store_true")
    parser.add_argument("--apk", type=Path)
    parser.add_argument("--apktool", type=Path)
    parser.add_argument("--java", default="java")
    parser.add_argument("--output", type=Path, default=HERE.parent / "work/reproduction")
    args = parser.parse_args()
    if args.self_check:
        self_check()
        return
    if not args.apk or not args.apktool:
        parser.error("--apk and --apktool are required")
    with args.apk.open("rb") as stream:
        if hashlib.file_digest(stream, "sha256").hexdigest() != APK_SHA256:
            raise ValueError("Original APK SHA-256 mismatch; only version 1.5.16 / 1005016 is supported")
    recipe = json.loads((HERE / "port-patches.json").read_text("utf-8"))
    output = args.output.resolve()
    if output.exists():
        raise ValueError("Output already exists; choose a new directory: " + str(output))
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".port-", dir=output.parent) as temporary:
        stage = Path(temporary)
        original = stage / "original"
        subprocess.run([args.java, "-jar", str(args.apktool.resolve()), "d", "-p", str(stage / "framework"),
                        "-o", str(original), str(args.apk.resolve())], check=True)
        app = stage / "app"
        shutil.copytree(original, app)
        for name, patch in recipe["patches"].items():
            path = checked_path(app, name)
            path.write_bytes(apply_delta(path.read_bytes(), patch))
        for destination, source in recipe["copies"].items():
            path = checked_path(app, destination)
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(checked_path(original, source), path)
        for destination, source in recipe["additions"].items():
            path = checked_path(app, destination)
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(checked_path(HERE / "android", source), path)
        for name in recipe["removed"]:
            checked_path(app, name).unlink()
        for name, expected in recipe["target_sha256"].items():
            if sha(checked_path(app, name).read_bytes()) != expected:
                raise ValueError("Prepared source SHA-256 mismatch: " + name)
        os.rename(stage, output)
    print("Prepared sources: " + str(output / "app"))
    print("Build libCore.so separately; no game binaries or signing keys are supplied by this repository.")


if __name__ == "__main__":
    main()
