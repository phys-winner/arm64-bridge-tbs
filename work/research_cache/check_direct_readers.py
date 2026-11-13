"""Read-only host model of the AS bounded STORED ZIP/FLV proposal. No extraction."""
import argparse
import collections
import hashlib
import io
import json
import struct
import zipfile
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OBB = ROOT / "original/air.com.stoicstudio.BannerSaga/main.1005016.air.com.stoicstudio.BannerSaga.obb"
EXPECTED = "9adc35cd9b5d9f3f041672d612b34f2ba6dd486118215e07489607e384d4f8c6"


class BoundedZip:
    def __init__(self, source, offset=0, length=None):
        self.source, self.offset = source, offset
        source.seek(0, 2)
        total = source.tell()
        self.length = total - offset if length is None else length
        if offset < 0 or self.length < 22 or offset + self.length > total or total >= 2**31:
            raise ValueError("container range")
        start = max(0, self.length - 65557)
        tail = self.read_at(start, self.length - start)
        eocd = None
        for pos in range(len(tail) - 22, -1, -1):
            if tail[pos:pos + 4] == b"PK\x05\x06" and pos + 22 + struct.unpack_from("<H", tail, pos + 20)[0] == len(tail):
                eocd = start + pos
                break
        if eocd is None:
            raise ValueError("end record")
        disk, cd_disk, on_disk, count, cd_size, cd_offset, comment = struct.unpack("<HHHHIIH", self.read_at(eocd + 4, 18))
        if disk or cd_disk or on_disk != count or count == 65535 or cd_offset == 0xffffffff or cd_size == 0xffffffff or cd_offset + cd_size != eocd:
            raise ValueError("central bounds")
        self.cd_offset, self.entries = cd_offset, {}
        pos = cd_offset
        for _ in range(count):
            if pos + 46 > eocd:
                raise ValueError("central record range")
            header = self.read_at(pos, 46)
            if header[:4] != b"PK\x01\x02":
                raise ValueError("central signature")
            flags, method = struct.unpack_from("<HH", header, 8)
            crc, packed, size = struct.unpack_from("<III", header, 16)
            nl, el, cl, entry_disk = struct.unpack_from("<HHHH", header, 28)
            local = struct.unpack_from("<I", header, 42)[0]
            if flags & 65 or entry_disk or 0xffffffff in (packed, size, local) or local + 30 > cd_offset or pos + 46 + nl + el + cl > eocd:
                raise ValueError("unsupported central entry")
            name = self.read_at(pos + 46, nl).decode("utf-8")
            if not name or name.startswith("/") or "\\" in name or "\x00" in name or ".." in name.split("/") or name in self.entries:
                raise ValueError("unsafe or duplicate name")
            if method == 0 and packed != size:
                raise ValueError("stored size")
            self.entries[name] = dict(local=local, flags=flags, method=method, crc=crc, packed=packed, size=size)
            pos += 46 + nl + el + cl
        if pos != eocd:
            raise ValueError("central count/size")

    def read_at(self, pos, count):
        if pos < 0 or count < 0 or pos > self.length or count > self.length - pos:
            raise ValueError("bounded read")
        self.source.seek(self.offset + pos)
        result = self.source.read(count)
        if len(result) != count:
            raise ValueError("truncated source")
        return result

    def entry(self, name):
        row = self.entries[name]
        header = self.read_at(row["local"], 30)
        if header[:4] != b"PK\x03\x04":
            raise ValueError("local signature")
        flags, method = struct.unpack_from("<HH", header, 6)
        crc, packed, size = struct.unpack_from("<III", header, 14)
        nl, el = struct.unpack_from("<HH", header, 26)
        offset = row["local"] + 30 + nl + el
        if flags != row["flags"] or method != row["method"] or offset > self.cd_offset or row["packed"] > self.cd_offset - offset:
            raise ValueError("local bounds/metadata")
        if not flags & 8 and (crc, packed, size) != (row["crc"], row["packed"], row["size"]):
            raise ValueError("local/central size/CRC")
        if self.read_at(row["local"] + 30, nl).decode("utf-8") != name:
            raise ValueError("local name")
        if method != 0:
            raise ValueError("direct stream requires STORED")
        return Entry(self, name, offset, row)


class Entry:
    def __init__(self, archive, name, offset, row):
        self.archive, self.name, self.offset, self.row = archive, name, offset, row
        self.position, self.crc = 0, 0

    @property
    def available(self):
        return self.row["size"] - self.position

    def read(self, count=0):
        count = self.available if count == 0 else count
        if count < 0 or count > self.available:
            raise ValueError("entry EOF")
        result = self.archive.read_at(self.offset + self.position, count)
        self.position += count
        self.crc = zlib.crc32(result, self.crc)
        if not self.available and self.crc != self.row["crc"]:
            raise ValueError("entry CRC")
        return result


def amf0(data, pos=0):
    tag = data[pos]
    pos += 1
    if tag == 0:
        return struct.unpack_from(">d", data, pos)[0], pos + 8
    if tag == 1:
        return bool(data[pos]), pos + 1
    if tag == 2:
        size = int.from_bytes(data[pos:pos + 2], "big")
        pos += 2
        return data[pos:pos + size].decode("utf-8"), pos + size
    if tag in (3, 8):
        if tag == 8:
            pos += 4
        result = {}
        while data[pos:pos + 3] != b"\x00\x00\x09":
            size = int.from_bytes(data[pos:pos + 2], "big")
            pos += 2
            key = data[pos:pos + size].decode("utf-8")
            pos += size
            result[key], pos = amf0(data, pos)
        return result, pos + 3
    if tag == 10:
        size = int.from_bytes(data[pos:pos + 4], "big")
        pos += 4
        result = []
        for _ in range(size):
            value, pos = amf0(data, pos)
            result.append(value)
        return result, pos
    if tag in (5, 6):
        return None, pos
    raise ValueError(f"unhandled AMF0 tag {tag}")


def scan_flv(entry):
    header = entry.read(9)
    data_start = int.from_bytes(header[5:9], "big")
    if header[:4] != b"FLV\x01" or not 9 <= data_start <= 65536:
        raise ValueError("FLV header")
    extended = entry.read(data_start - 9 + 4)
    if extended[-4:] != b"\x00" * 4:
        raise ValueError("FLV first previous-tag-size")
    counts, codec_ids, audio_ids, keyframes, tags, metadata = collections.Counter(), set(), set(), [], [], {}
    max_size, last_timestamp, regressions = 0, -1, 0
    stream_last, stream_regressions = {}, collections.Counter()
    while entry.available:
        offset = entry.position
        raw = entry.read(11)
        kind, size = raw[0], int.from_bytes(raw[1:4], "big")
        timestamp = int.from_bytes(raw[4:7], "big") + raw[7] * 2**24
        if kind not in (8, 9, 18) or raw[8:11] != b"\x00" * 3 or size + 4 > entry.available:
            raise ValueError("FLV tag bounds")
        counts[kind] += 1
        max_size = max(max_size, size)
        regressions += timestamp < last_timestamp
        last_timestamp = timestamp
        stream_regressions[kind] += timestamp < stream_last.get(kind, -1)
        stream_last[kind] = timestamp
        # Inspect one prefix, then consume the rest in bounded chunks. Metadata is the only small AMF decode.
        prefix = entry.read(min(size, 4096)) if size else b""
        left = size - len(prefix)
        if kind == 9 and prefix:
            codec_ids.add(prefix[0] & 15)
            if prefix[0] >> 4 == 1:
                keyframes.append(dict(time_ms=timestamp, offset=offset))
        if kind == 8 and prefix:
            audio_ids.add(prefix[0] >> 4)
        if kind == 18 and prefix:
            label, pos = amf0(prefix)
            value, _ = amf0(prefix, pos)
            metadata[label] = value
        while left:
            count = min(left, 262144)
            entry.read(count)
            left -= count
        if int.from_bytes(entry.read(4), "big") != size + 11:
            raise ValueError("FLV previous-tag-size")
        tags.append((timestamp, size + 15))
    # Upper bound of source bytes whose tag timestamps fit a five-second window (not measured AIR buffer memory).
    a = 0
    window = peak = 0
    tags.sort()
    for b, (timestamp, size) in enumerate(tags):
        window += size
        while a < b and timestamp - tags[a][0] > 5000:
            window -= tags[a][1]
            a += 1
        peak = max(peak, window)
    return dict(name=entry.name, bytes=entry.position, crc32=f"{entry.crc:08x}", data_offset=data_start,
                tag_counts=dict(counts), video_codec_ids=sorted(codec_ids), audio_format_ids=sorted(audio_ids),
                maximum_tag_payload=max_size, last_timestamp_ms=last_timestamp, timestamp_regressions=regressions,
                per_stream_timestamp_regressions=dict(stream_regressions),
                source_bytes_in_5s_window_max=peak, metadata=metadata, keyframes=keyframes)


def self_check():
    inner = io.BytesIO()
    with zipfile.ZipFile(inner, "w", compression=zipfile.ZIP_STORED) as archive:
        archive.writestr("common/sentinel", b"alpha")
        archive.writestr("video/flv", b"bravo")
    outer = io.BytesIO()
    with zipfile.ZipFile(outer, "w", compression=zipfile.ZIP_STORED) as archive:
        archive.writestr("prefix", b"nonzero offset")
        archive.writestr("assets/obb/main.obb", inner.getvalue())
    whole = outer.getvalue()
    apk = BoundedZip(io.BytesIO(whole))
    record = apk.entry("assets/obb/main.obb")
    nested = BoundedZip(io.BytesIO(whole), record.offset, record.row["size"])
    child = nested.entry("common/sentinel")
    assert record.offset > 0 and child.read(2) == b"al" and child.read() == b"pha" and child.read() == b""
    assert nested.entry("video/flv").read() == b"bravo"
    destination = bytearray(b"xx")
    destination[2:] = nested.entry("common/sentinel").read(2)
    assert destination == b"xxal"
    cases = []
    for name in ("container bound", "entry EOF", "payload CRC", "local signature", "EOCD comment", "central count"):
        data = bytearray(whole)
        if name == "payload CRC":
            data[record.offset + nested.entry("common/sentinel").offset] ^= 1
        elif name == "local signature":
            data[record.offset] ^= 1
        elif name == "EOCD comment":
            data[record.offset + record.row["size"] - 1] = 1
        elif name == "central count":
            data[record.offset + record.row["size"] - 22 + 10] = 1
        try:
            bad = BoundedZip(io.BytesIO(data), record.offset, record.row["size"] - (1 if name == "container bound" else 0))
            bad.entry("common/sentinel").read(6 if name == "entry EOF" else 0)
        except (ValueError, KeyError):
            cases.append(name)
        else:
            raise AssertionError("accepted corruption: " + name)
    assert len(cases) == 6
    payload = b"FLV\x01\x01\x00\x00\x00\x09" + b"\x00" * 4
    payload += b"\x09\x00\x00\x01" + b"\x00" * 7 + b"\x14" + (12).to_bytes(4, "big")
    clip = io.BytesIO()
    with zipfile.ZipFile(clip, "w", compression=zipfile.ZIP_STORED) as archive:
        archive.writestr("v", payload)
    assert scan_flv(BoundedZip(clip).entry("v"))["video_codec_ids"] == [4]
    print("SELF_CHECK_OK nested nonzero offsets, destination offset, EOF, CRC, signatures, comment/count corruption, FLV framing")


def audit():
    with OBB.open("rb") as source:
        digest = hashlib.file_digest(source, "sha256").hexdigest()
        if digest != EXPECTED:
            raise ValueError("unexpected immutable OBB hash: " + digest)
        archive = BoundedZip(source)
        sentinels = []
        for name in ("common/assets_config.json.z", "saga1/saga1.json.z"):
            entry = archive.entry(name)
            value = entry.read()
            sentinels.append(dict(name=name, size=len(value), crc32=f"{entry.crc:08x}", sha256=hashlib.sha256(value).hexdigest(), offset=entry.offset))
        videos = [scan_flv(archive.entry(name)) for name in archive.entries if name.endswith(".flv")]
        result = dict(obb_sha256=digest, length=archive.length, entries=len(archive.entries), central_offset=archive.cd_offset, sentinels=sentinels, videos=videos)
    output = Path(__file__).resolve().parent / "direct_reader_evidence.json"
    output.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps({**{k: result[k] for k in ("obb_sha256", "length", "entries", "central_offset", "sentinels")},
                      "videos": [{k: v[k] for k in v if k != "keyframes"} for v in videos]}, indent=2))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-check", action="store_true")
    self_check() if parser.parse_args().self_check else audit()
