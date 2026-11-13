"""Owned, local KEEP_CONTAINER pack/check helper. No extraction and no Android.

Run --self-check first. A real --pack is a separate parent-authorized promotion
step. All writes are confined to this script's directory; inputs are read-only.
"""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import struct
import tempfile
import time
import zipfile
import zlib

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
ENTRY = "assets/obb/main.1005016.air.com.stoicstudio.BannerSaga.obb"
OBB = ROOT / "original/air.com.stoicstudio.BannerSaga/main.1005016.air.com.stoicstudio.BannerSaga.obb"
OBB_SIZE = 1902742603
OBB_SHA = "9adc35cd9b5d9f3f041672d612b34f2ba6dd486118215e07489607e384d4f8c6"
OBB_CRC = "2a4c5cfe"
INVENTORY_SHA = "ccccf738a0a808c13d815874d59662bab7f2d8911abc6738802d90ff3ed4ba4d"
FINGERPRINTS_SHA = "396b121280aad8b485dea3c7d6aec71815b8504993dafe35dbfd3aeb07702fe6"
READER_SHA = "e5c7e780d71d0edfd5a13a56fe8b183ff48c307bc95e3f31a3ec71cc47cdf56d"
CHUNK = 2 * 1024 * 1024
LIMIT = 2**31
SIGN_RESERVE = 16 * 1024 * 1024
CD_LIMIT = 16 * 1024 * 1024
APK_MAGIC = b"APK Sig Block 42"


def digest_range(source, offset, size):
    source.seek(offset)
    sha, crc, count = hashlib.sha256(), 0, 0
    while count < size:
        block = source.read(min(CHUNK, size - count))
        if not block:
            raise ValueError("truncated payload")
        sha.update(block)
        crc = zlib.crc32(block, crc)
        count += len(block)
    return dict(bytes=count, sha256=sha.hexdigest(), crc32=f"{crc:08x}")


def digest_file(path):
    with Path(path).open("rb") as source:
        size = os.fstat(source.fileno()).st_size
        result = digest_range(source, 0, size)
        if source.read(1) or os.fstat(source.fileno()).st_size != size:
            raise ValueError("file changed during fingerprint")
        return result


def hash_guard(path, expected):
    if not re.fullmatch(r"[0-9a-f]{64}", expected or ""):
        raise ValueError("explicit lowercase SHA256 required")
    result = digest_file(path)
    if result["sha256"] != expected:
        raise ValueError(f"SHA256 guard rejected {path}: {result['sha256']}")
    return result


def owned(path):
    path = Path(path).resolve()
    if not path.is_relative_to(HERE) or path == HERE:
        raise ValueError("output must stay in work/research_cache")
    return path


def save(path, result):
    path = owned(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def reader():
    hash_guard(HERE / "check_direct_readers.py", READER_SHA)
    from check_direct_readers import BoundedZip
    return BoundedZip


def extras(data, redundant_sizes=None):
    pos, zip64_seen = 0, False
    while pos < len(data):
        # Some aligners use an all-zero tail rather than a TLV.
        if not any(data[pos:]):
            return zip64_seen
        if pos + 4 > len(data):
            raise ValueError("truncated extra field")
        tag, size = struct.unpack_from("<HH", data, pos)
        if tag == 1:
            # Immutable OBB uses redundant local ZIP64-sized size copies without
            # sentinels. The reader still uses ZIP32 fields. Never rewrite them.
            if zip64_seen or redundant_sizes is None or size != 16 or pos + 20 > len(data):
                raise ValueError("ZIP64 extra field")
            values = struct.unpack_from("<QQ", data, pos + 4)
            if values != redundant_sizes or max(values) >= LIMIT:
                raise ValueError("redundant ZIP64 size mismatch/high words")
            zip64_seen = True
        pos += 4 + size
        if pos > len(data):
            raise ValueError("extra field range")
    return zip64_seen


def end_record(source, offset, length):
    start = max(0, length - 65557)
    source.seek(offset + start)
    tail = source.read(length - start)
    for pos in range(len(tail) - 22, -1, -1):
        if tail[pos:pos + 4] == b"PK\x05\x06" and pos + 22 + struct.unpack_from("<H", tail, pos + 20)[0] == len(tail):
            fields = struct.unpack_from("<HHHHIIH", tail, pos + 4)
            disk, cd_disk, on_disk, count, cd_size, cd_offset, _ = fields
            eocd = start + pos
            if disk or cd_disk or on_disk != count or count >= 65535 or cd_offset >= LIMIT or cd_size > CD_LIMIT or cd_offset + cd_size != eocd:
                raise ValueError("ZIP32 central directory bounds")
            source.seek(offset + max(0, eocd - 20))
            if source.read(4) == b"PK\x06\x07":
                raise ValueError("ZIP64 locator")
            return eocd, cd_offset, cd_size, count
    raise ValueError("ZIP32 end record")


def signing_block(source, cd_offset):
    if cd_offset < 24:
        return None
    source.seek(cd_offset - 24)
    footer = source.read(24)
    if footer[8:] != APK_MAGIC:
        return None
    size = struct.unpack_from("<Q", footer)[0]
    start = cd_offset - size - 8
    if size < 24 or start < 0:
        raise ValueError("APK Signing Block bounds")
    source.seek(start)
    if source.read(8) != footer[:8]:
        raise ValueError("APK Signing Block size pair")
    return start, size + 8


def strict_zip(source, offset=0, length=None, stored=False, apk=False):
    source.seek(0, 2)
    total = source.tell()
    length = total - offset if length is None else length
    if total >= LIMIT or offset < 0 or length < 22 or offset + length > total:
        raise ValueError("signed-int container bounds")
    eocd, cd_offset, cd_size, count = end_record(source, offset, length)
    archive = reader()(source, offset, length)
    archive.eocd = eocd
    archive.cd_size = cd_size
    block = signing_block(source, cd_offset) if apk and offset == 0 else None
    archive.signing_block = block
    data_end = block[0] if block else cd_offset
    pos, intervals = cd_offset, []
    for name, row in archive.entries.items():
        header = archive.read_at(pos, 46)
        version = struct.unpack_from("<H", header, 6)[0]
        nl, el, cl = struct.unpack_from("<HHH", header, 28)
        extras(archive.read_at(pos + 46 + nl, el))
        if version >= 45 or row["method"] not in (0, 8) or stored and row["method"] != 0 or max(row["local"], row["size"], row["packed"]) >= LIMIT:
            raise ValueError("unsupported ZIP64/version/method/size")
        local = archive.read_at(row["local"], 30)
        if local[:4] != b"PK\x03\x04":
            raise ValueError("local signature")
        lv, flags, method = struct.unpack_from("<HHH", local, 4)
        crc, packed, size = struct.unpack_from("<III", local, 14)
        lnl, lel = struct.unpack_from("<HH", local, 26)
        if lv >= 45 or 0xffffffff in (packed, size) or flags != row["flags"] or method != row["method"]:
            raise ValueError("local metadata/ZIP64")
        if archive.read_at(row["local"] + 30, lnl).decode("utf-8") != name:
            raise ValueError("local name mismatch")
        row["redundant_zip64_local_sizes"] = extras(archive.read_at(row["local"] + 30 + lnl, lel),
                                                    (row["size"], row["packed"]) if stored else None)
        payload = row["local"] + 30 + lnl + lel
        end = payload + row["packed"]
        if payload > data_end or end > data_end:
            raise ValueError("payload beyond central/signing boundary")
        if flags & 8:
            descriptor = archive.read_at(end, 4)
            prefix = 4 if descriptor == b"PK\x07\x08" else 0
            actual = struct.unpack("<III", archive.read_at(end + prefix, 12))
            if actual != (row["crc"], row["packed"], row["size"]):
                raise ValueError("data descriptor mismatch")
            end += prefix + 12
        elif (crc, packed, size) != (row["crc"], row["packed"], row["size"]):
            raise ValueError("local CRC/size mismatch")
        if end > data_end:
            raise ValueError("descriptor beyond data boundary")
        row["data_offset"] = payload
        intervals.append((row["local"], end))
        pos += 46 + nl + el + cl
    intervals.sort()
    if any(a[1] > b[0] for a, b in zip(intervals, intervals[1:])):
        raise ValueError("overlapping entry ranges")
    if pos != eocd or len(archive.entries) != count:
        raise ValueError("central directory count")
    return archive


def signature(name):
    return bool(re.fullmatch(r"META-INF/(?:MANIFEST\.MF|[^/]+\.(?:SF|RSA|DSA|EC))", name, re.I))


def swf_guard(path, expected):
    with zipfile.ZipFile(path) as archive:
        with archive.open("assets/GameMainAndroidMobile.swf") as stream:
            sha = hashlib.sha256()
            for block in iter(lambda: stream.read(CHUNK), b""):
                sha.update(block)
    if sha.hexdigest() != expected:
        raise ValueError("ready APK SWF guard")


def fingerprints():
    path = HERE / "obb_entry_fingerprints.json"
    hash_guard(path, FINGERPRINTS_SHA)
    data = json.loads(path.read_text(encoding="utf-8"))
    rows = data["files"]
    if data["source_inventory_sha256"] != INVENTORY_SHA or len(rows) != 8126 or len({row[0] for row in rows}) != 8126:
        raise ValueError("original payload fingerprint census")
    return {row[0]: tuple(row[1:]) for row in rows}


def full_nested(source, offset, size, expected_size, expected_sha, expected_rows=None):
    if size != expected_size:
        raise ValueError("whole OBB length")
    whole = digest_range(source, offset, size)
    if whole["sha256"] != expected_sha:
        raise ValueError("whole OBB SHA256")
    nested = strict_zip(source, offset, size, stored=True)
    files = dirs = payload_bytes = 0
    found = set()
    for name, row in sorted(nested.entries.items(), key=lambda item: item[1]["local"]):
        result = digest_range(source, offset + row["data_offset"], row["size"])
        if result["crc32"] != f"{row['crc']:08x}":
            raise ValueError("inner payload CRC32: " + name)
        if name.endswith("/"):
            dirs += 1
            if row["size"] or row["crc"]:
                raise ValueError("nonempty directory entry")
        else:
            files += 1
            payload_bytes += row["size"]
            found.add(name)
            if expected_rows is not None and expected_rows.get(name) != (row["size"], result["crc32"], result["sha256"]):
                raise ValueError("original inner fingerprint: " + name)
    if expected_rows is not None and (found != set(expected_rows) or len(nested.entries) != 8429 or dirs != 303):
        raise ValueError("original OBB membership")
    return dict(**whole, entries=len(nested.entries), files=files, directories=dirs,
                payload_bytes=payload_bytes, cd_offset=nested.cd_offset, cd_bytes=nested.cd_size,
                zip32_eocd_and_cd=True,
                redundant_zip64_local_size_fields=sum(bool(r["redundant_zip64_local_sizes"]) for r in nested.entries.values()))


def align_guard(archive):
    for name, row in archive.entries.items():
        if row["method"] == 0 and not name.endswith("/"):
            alignment = 16384 if name.endswith(".so") else 4
            if row["data_offset"] % alignment:
                raise ValueError("unaligned STORED entry: " + name)


def compare_base(base, candidate):
    with open(base, "rb") as a, open(candidate, "rb") as b, zipfile.ZipFile(base) as za, zipfile.ZipFile(candidate) as zb:
        old, new = strict_zip(a, apk=True), strict_zip(b, apk=True)
        old_names = {n for n in old.entries if not signature(n)}
        new_names = {n for n in new.entries if not signature(n)}
        if ENTRY in old_names or new_names != old_names | {ENTRY}:
            raise ValueError("base membership changed")
        checked, native, resources = 0, [], []
        for name in sorted(old_names):
            left, right = old.entries[name], new.entries[name]
            keys = ("method", "size", "packed", "crc", "flags")
            if any(left[k] != right[k] for k in keys):
                raise ValueError("base entry metadata changed: " + name)
            lh = digest_range(a, left["data_offset"], left["packed"])["sha256"]
            rh = digest_range(b, right["data_offset"], right["packed"])["sha256"]
            if lh != rh:
                raise ValueError("base compressed payload changed: " + name)
            # ZipExtFile checks uncompressed CRC at EOF; SHA covers every base entry.
            hashes = []
            for z in (za, zb):
                sha = hashlib.sha256()
                with z.open(name) as stream:
                    for block in iter(lambda: stream.read(CHUNK), b""):
                        sha.update(block)
                hashes.append(sha.hexdigest())
            if hashes[0] != hashes[1]:
                raise ValueError("base uncompressed payload changed: " + name)
            checked += 1
            if name.startswith("lib/"): native.append(name)
            if name.startswith("res/") or name == "resources.arsc": resources.append(name)
        align_guard(new)
        return dict(unchanged_non_signature_entries=checked, unchanged_native_entries=native,
                    unchanged_resource_entries=resources,
                    excluded_only_resigning_entries=[n for n in old.entries if signature(n)])


def stripped_copy(base, destination):
    with open(base, "rb") as source, open(destination, "xb") as target:
        archive = strict_zip(source, apk=True)
        block = archive.signing_block
        prefix_end = block[0] if block else archive.cd_offset
        source.seek(0)
        left = prefix_end
        while left:
            chunk = source.read(min(CHUNK, left))
            if not chunk: raise ValueError("base truncated")
            target.write(chunk)
            left -= len(chunk)
        source.seek(archive.cd_offset)
        # CD + EOCD + comment are bounded by CD_LIMIT + 65557, not a payload.
        tail = bytearray(source.read(archive.length - archive.cd_offset))
        struct.pack_into("<I", tail, archive.eocd - archive.cd_offset + 16, prefix_end)
        target.write(tail)
    return dict(removed_signing_block_bytes=block[1] if block else 0,
                preserved_local_offsets=True)


def append_container(path, source_path, expected_size, expected_sha):
    if expected_size * 1.05 > zipfile.ZIP64_LIMIT:
        raise ValueError("stdlib ZIP64 safety threshold")
    with zipfile.ZipFile(path, "a", allowZip64=False) as archive, open(source_path, "rb") as source:
        info = zipfile.ZipInfo(ENTRY, (2026, 1, 1, 0, 0, 0))
        info.compress_type, info.file_size = zipfile.ZIP_STORED, expected_size
        info.external_attr = 0o100644 << 16
        # stdlib writes at start_dir; tiny fixture asserts this pinned behavior.
        padding = -(archive.start_dir + 30 + len(ENTRY.encode("ascii"))) % 4
        if padding:
            info.extra = struct.pack("<HH", 0xcafe, padding) + b"\0" * padding
        sha, crc, count = hashlib.sha256(), 0, 0
        with archive.open(info, "w", force_zip64=False) as target:
            while count < expected_size:
                chunk = source.read(min(CHUNK, expected_size - count))
                if not chunk: raise ValueError("OBB truncated while packing")
                target.write(chunk)
                sha.update(chunk)
                crc = zlib.crc32(chunk, crc)
                count += len(chunk)
            if source.read(1): raise ValueError("OBB grew while packing")
        if sha.hexdigest() != expected_sha or info.CRC != crc:
            raise ValueError("OBB stream hash/CRC")
    return dict(bytes=count, sha256=sha.hexdigest(), crc32=f"{crc:08x}")


def plan(base, base_sha, swf_sha):
    result = hash_guard(base, base_sha)
    if not re.fullmatch(r"[0-9a-f]{64}", swf_sha or ""):
        raise ValueError("explicit ready SWF SHA256 required")
    swf_guard(base, swf_sha)
    with open(base, "rb") as source:
        archive = strict_zip(source, apk=True)
        align_guard(archive)
        if ENTRY in archive.entries or "assets/asset_manifest.csv" in archive.entries or "assets/assets.zip" in archive.entries:
            raise ValueError("ready base already has container/legacy assets")
        if len(archive.entries) + 4 >= 65535:
            raise ValueError("ZIP32 count capacity")
        removed = archive.signing_block[1] if archive.signing_block else 0
    # Maximum two names, headers, padding; reserve signing separately.
    projected = result["bytes"] - removed + OBB_SIZE + 2 * len(ENTRY) + 30 + 46 + 16
    if projected + SIGN_RESERVE >= LIMIT or OBB.stat().st_size != OBB_SIZE:
        raise ValueError("projected signed APK/immutable OBB size gate")
    return dict(base=str(Path(base).resolve()), base_sha256=base_sha, swf_sha256=swf_sha,
                base_bytes=result["bytes"], obb_bytes=OBB_SIZE, obb_sha256=OBB_SHA, obb_crc32=OBB_CRC,
                projected_unsigned_upper_bytes=projected, signing_reserve_bytes=SIGN_RESERVE,
                signed_int_headroom_bytes=LIMIT - projected - SIGN_RESERVE,
                standalone_obb_copies=0, chunk_bytes=CHUNK,
                status="HOST_PLAN_ONLY_PARENT_PROMOTION_REQUIRED")


def check(base, candidate, base_sha, swf_sha, expected_apk_sha=None):
    started = time.monotonic()
    plan(base, base_sha, swf_sha)
    candidate = Path(candidate)
    if candidate.stat().st_size >= LIMIT:
        raise ValueError("final APK exceeds signed-int limit")
    outer_hash = hash_guard(candidate, expected_apk_sha) if expected_apk_sha else digest_file(candidate)
    unchanged = compare_base(base, candidate)
    swf_guard(candidate, swf_sha)
    with candidate.open("rb") as source:
        archive = strict_zip(source, apk=True)
        row = archive.entries[ENTRY]
        if row["method"] != 0 or row["packed"] != row["size"] or row["data_offset"] % 4:
            raise ValueError("outer direct STORED/alignment contract")
        nested = full_nested(source, row["data_offset"], row["size"], OBB_SIZE, OBB_SHA, fingerprints())
        if nested["crc32"] != OBB_CRC or nested["crc32"] != f"{row['crc']:08x}":
            raise ValueError("outer OBB CRC32")
    return dict(status="HOST_CONTENT_GATE_PASS_NOT_RUNTIME_ACCEPTANCE", apk=str(candidate.resolve()),
                apk_fingerprint=outer_hash, container_offset=row["data_offset"], nested=nested,
                unchanged=unchanged, elapsed_seconds=round(time.monotonic() - started, 3),
                chunk_bytes=CHUNK, central_directory_cap_bytes=CD_LIMIT,
                signature_verification="REQUIRED_SEPARATE_PINNED_APKSIGNER", android_access=False)


def self_check():
    with tempfile.TemporaryDirectory(prefix="embed-fixture-", dir=HERE) as tmp:
        tmp = Path(tmp)
        inner = tmp / "tiny.obb"
        with zipfile.ZipFile(inner, "w") as z:
            z.writestr("dir/", b"")
            z.writestr("dir/a", b"small immutable payload")
            z.writestr("video.flv", b"FLV\x01\0\0\0\0\x09" + b"\0" * 4)
        base = tmp / "base.apk"
        with zipfile.ZipFile(base, "w") as z:
            for name, data, method in (("assets/GameMainAndroidMobile.swf", b"fixture SWF", 0),
                                       ("lib/armeabi-v7a/libtest.so", b"fixture native", 0),
                                       ("resources.arsc", b"fixture resources", 0),
                                       ("res/xml/test.xml", b"fixture compressed", 8)):
                info = zipfile.ZipInfo(name)
                info.compress_type = method
                alignment = 16384 if name.endswith(".so") else 4
                header_end = z.fp.tell() + 30 + len(name)
                if header_end % alignment:
                    padding = -(header_end + 4) % alignment
                    info.extra = struct.pack("<HH", 0xcafe, padding) + b"\0" * padding
                z.writestr(info, data)
        with base.open("rb") as f:
            parsed = strict_zip(f, apk=True)
            align_guard(parsed)
            cd, eocd = parsed.cd_offset, parsed.eocd
        data = bytearray(base.read_bytes())
        fake_block = struct.pack("<Q", 24) * 2 + APK_MAGIC
        data[cd:cd] = fake_block
        struct.pack_into("<I", data, eocd + len(fake_block) + 16, cd + len(fake_block))
        base.write_bytes(data)
        candidate = tmp / "embedded.apk"
        stripped = stripped_copy(base, candidate)
        assert stripped["removed_signing_block_bytes"] == 32
        append_container(candidate, inner, inner.stat().st_size, digest_file(inner)["sha256"])
        compare_base(base, candidate)
        with candidate.open("rb") as f:
            outer = strict_zip(f, apk=True)
            row = outer.entries[ENTRY]
            assert row["data_offset"] % 4 == 0 and row["data_offset"] > 0
            report = full_nested(f, row["data_offset"], row["size"], inner.stat().st_size, digest_file(inner)["sha256"])
            assert (report["files"], report["directories"]) == (2, 1)
        cases = []
        bad = tmp / "bad.apk"
        for kind in ("whole_hash", "nested_crc", "native_bytes", "resource_bytes", "ZIP64_local_version", "ZIP64_version", "duplicate_name", "container_truncated", "offset_sentinel", "size_sentinel", "count_sentinel"):
            altered = bytearray(candidate.read_bytes())
            if kind in ("native_bytes", "resource_bytes"):
                name = "lib/armeabi-v7a/libtest.so" if kind == "native_bytes" else "resources.arsc"
                altered[outer.entries[name]["data_offset"]] ^= 1
            elif kind in ("whole_hash", "nested_crc"):
                with candidate.open("rb") as f:
                    nested = strict_zip(f, row["data_offset"], row["size"], stored=True)
                altered[row["data_offset"] + nested.entries["dir/a"]["data_offset"]] ^= 1
            elif kind == "ZIP64_local_version":
                local = outer.entries[ENTRY]["local"]
                # A real small ZIP64 local record is tested independently below.
                extras(struct.pack("<HH", 0x9999, 0))
                struct.pack_into("<H", altered, local + 4, 45)
            elif kind == "ZIP64_version": struct.pack_into("<H", altered, outer.cd_offset + 6, 45)
            elif kind == "duplicate_name":
                bad.write_bytes(altered)
                with zipfile.ZipFile(bad, "a") as z: z.writestr("resources.arsc", b"duplicate")
                altered = bytearray(bad.read_bytes())
            elif kind == "container_truncated": altered = altered[:-1]
            elif kind == "offset_sentinel": struct.pack_into("<I", altered, outer.cd_offset + 42, 0xffffffff)
            elif kind == "size_sentinel": struct.pack_into("<I", altered, outer.cd_offset + 24, 0xffffffff)
            elif kind == "count_sentinel": struct.pack_into("<HH", altered, outer.eocd + 8, 65535, 65535)
            bad.write_bytes(altered)
            try:
                if kind in ("whole_hash", "nested_crc"):
                    with bad.open("rb") as f:
                        expected = digest_file(inner)["sha256"] if kind == "whole_hash" else digest_range(f, row["data_offset"], row["size"])["sha256"]
                        full_nested(f, row["data_offset"], row["size"], row["size"], expected)
                else: compare_base(base, bad)
            except (ValueError, zipfile.BadZipFile): cases.append(kind)
            else: raise AssertionError("accepted corruption: " + kind)
        extras(struct.pack("<HHQQ", 1, 16, 7, 7), (7, 7))
        try: extras(struct.pack("<HHQQ", 1, 16, 7, 8), (7, 7))
        except ValueError: cases.append("redundant_ZIP64_mismatch")
        else: raise AssertionError("accepted inconsistent redundant sizes")
        try: extras(struct.pack("<HHQ", 1, 8, 7))
        except ValueError: cases.append("ZIP64_TLV")
        else: raise AssertionError("accepted ZIP64 TLV")
        tiny64 = io.BytesIO()
        with zipfile.ZipFile(tiny64, "w") as z:
            with z.open("small", "w", force_zip64=True) as out: out.write(b"tiny")
        try: strict_zip(io.BytesIO(tiny64.getvalue()))
        except ValueError: cases.append("real_small_ZIP64_local")
        else: raise AssertionError("accepted ZIP64 local")
        assert len(cases) == 14
    return dict(status="SELF_CHECK_PASS", tiny_fixtures_only=True, negative_cases=cases,
                real_obb_packed=False, source_hash_guards=True, chunk_bytes=CHUNK)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    mode = p.add_mutually_exclusive_group(required=True)
    mode.add_argument("--self-check", action="store_true")
    mode.add_argument("--audit-original", action="store_true")
    mode.add_argument("--plan", action="store_true")
    mode.add_argument("--pack", action="store_true")
    mode.add_argument("--check", action="store_true")
    p.add_argument("--base", type=Path)
    p.add_argument("--base-sha")
    p.add_argument("--swf-sha")
    p.add_argument("--apk", type=Path)
    p.add_argument("--apk-sha")
    p.add_argument("--output", type=Path)
    p.add_argument("--report", type=Path)
    args = p.parse_args()
    started = time.monotonic()
    if args.self_check:
        result = self_check()
    elif args.audit_original:
        if OBB.stat().st_size != OBB_SIZE: raise ValueError("original physical length")
        with OBB.open("rb") as source:
            result = full_nested(source, 0, OBB_SIZE, OBB_SIZE, OBB_SHA, fingerprints())
        if result["crc32"] != OBB_CRC: raise ValueError("original whole CRC32")
        result.update(status="ORIGINAL_WHOLE_AND_ALL_PAYLOADS_HOST_PASS", source=str(OBB),
                      elapsed_seconds=round(time.monotonic() - started, 3), chunk_bytes=CHUNK)
    else:
        if not args.base or not args.base_sha or not args.swf_sha:
            p.error("--base, --base-sha and --swf-sha required")
        if args.plan:
            result = plan(args.base, args.base_sha, args.swf_sha)
        elif args.check:
            if not args.apk or not args.apk_sha: p.error("--apk and --apk-sha required for final check")
            result = check(args.base, args.apk, args.base_sha, args.swf_sha, args.apk_sha)
        else:
            if not args.output: p.error("--output required")
            plan(args.base, args.base_sha, args.swf_sha)
            destination = owned(args.output)
            partial = owned(str(destination) + ".partial")
            if destination.exists() or partial.exists(): raise ValueError("exclusive output already exists")
            destination.parent.mkdir(parents=True, exist_ok=True)
            stripped_copy(args.base, partial)
            append_container(partial, OBB, OBB_SIZE, OBB_SHA)
            result = check(args.base, partial, args.base_sha, args.swf_sha)
            # Windows rename fails if destination appeared since the preflight.
            os.rename(partial, destination)
            result.update(apk=str(destination), status="UNSIGNED_HOST_CONTENT_GATE_PASS_SIGNING_REQUIRED")
    if args.report: save(args.report, result)
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
