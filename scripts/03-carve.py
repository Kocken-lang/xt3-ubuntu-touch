#!/usr/bin/env python3
"""Format-agnostic image carver + minimal lpunpack for Janam/Point Mobile PFU blobs.

The PFU container layout is undocumented, so instead of guessing headers we scan the
blob for magics that Android/Qualcomm/embedded images always carry, compute each
image's extent from its own header, and write the result out. Everything that is
found is recorded in manifest.json with sha256 so the result is auditable.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import struct
import sys

MIB = 1 << 20

# (name, magic, offset-of-magic-relative-to-image-start)
MAGICS = [
    ("android_sparse", b"\x3a\xff\x26\xed", 0),
    ("android_boot", b"ANDROID!", 0),
    ("dt_table", b"\xd7\xb7\xab\x1e", 0),
    ("fdt", b"\xd0\x0d\xfe\xed", 0),
    ("gzip", b"\x1f\x8b\x08", 0),
    ("xz", b"\xfd7zXZ\x00", 0),
    ("zstd", b"\x28\xb5\x2f\xfd", 0),
    ("bzip2", b"BZh", 0),
    ("lz4_legacy", b"\x02\x21\x4c\x18", 0),
    ("squashfs", b"hsqs", 0),
    ("cramfs", b"\x45\x3d\xcd\x28", 0),
    ("elf", b"\x7fELF", 0),
    ("ext4", b"\x53\xef", 0x438),
    ("super_lp", b"\x67\x44\x6c\x61", 0),  # LP_METADATA_GEOMETRY_MAGIC LE
]


def u32le(b, o):
    return struct.unpack_from("<I", b, o)[0]


def u64le(b, o):
    return struct.unpack_from("<Q", b, o)[0]


def sparse_size(buf, off):
    hdr = buf[off:off + 28]
    if len(hdr) < 28:
        return None
    blk_sz = u32le(hdr, 8)
    total_blks = u32le(hdr, 12)
    if not (512 <= blk_sz <= 1 << 20) or total_blks == 0:
        return None
    return blk_sz * total_blks


def ext4_size(buf, off):
    sb = buf[off + 0x400:off + 0x400 + 1024]
    if len(sb) < 1024 or struct.unpack_from("<H", sb, 56)[0] != 0xEF53:
        return None
    blocks = u32le(sb, 4)
    log_bs = u32le(sb, 24)
    if log_bs > 6 or blocks == 0:
        return None
    return blocks * (1024 << log_bs)


def boot_size(buf, off):
    if buf[off:off + 8] != b"ANDROID!":
        return None
    if off + 44 > len(buf):
        return None
    ksz, rsz, ssz = u32le(buf, off + 8), u32le(buf, off + 16), u32le(buf, off + 24)
    page = u32le(buf, off + 36) or 2048
    if page not in (2048, 4096, 8192, 16384):
        return None
    def al(n):
        return (n + page - 1) // page * page
    total = page + al(ksz) + al(rsz) + al(ssz)
    if off + 44 <= len(buf):
        total += al(u32le(buf, off + 40) if u32le(buf, off + 40) < 1 << 20 else 0)
    return total


def dt_table_size(buf, off):
    if len(buf) < off + 32:
        return None
    total = u32le(buf, off + 4)
    return total if 0 < total < 64 * MIB else None


def fdt_size(buf, off):
    if len(buf) < off + 8:
        return None
    total = struct.unpack_from(">I", buf, off + 4)[0]
    return total if 0 < total < 8 * MIB else None


SIZE_FN = {
    "android_sparse": sparse_size,
    "android_boot": boot_size,
    "dt_table": dt_table_size,
    "fdt": fdt_size,
    "ext4": ext4_size,
}


def scan(buf, min_size):
    hits = []
    for name, magic, delta in MAGICS:
        start = 0
        while True:
            i = buf.find(magic, start)
            if i < 0:
                break
            start = i + 1
            off = i - delta
            if off < 0:
                continue
            fn = SIZE_FN.get(name)
            size = fn(buf, off) if fn else None
            hits.append({"type": name, "offset": off, "size": size})
    hits.sort(key=lambda h: (h["offset"], -(h["size"] or 0)))
    return hits


def resolve(buf, hits, min_size):
    """Drop hits that are strictly inside a larger, known-size image."""
    out = []
    end = -1
    for h in hits:
        if h["offset"] < end:
            continue
        if h["size"] is None:
            nxt = next((x["offset"] for x in hits if x["offset"] > h["offset"]), len(buf))
            h["size"] = nxt - h["offset"]
            h["size_estimated"] = True
        if h["size"] < min_size:
            continue
        out.append(h)
        end = h["offset"] + h["size"]
    return out


def carve(path, outdir, min_size):
    with open(path, "rb") as f:
        buf = f.read()
    print(f"[carve] {path}  {len(buf)} bytes ({len(buf)/MIB:.1f} MiB)")
    print(f"[carve] första 64 byte: {buf[:64].hex(' ')}")

    hits = resolve(buf, scan(buf, min_size), min_size)
    if not hits:
        print("[carve] INGA kända magics hittades -> containern är troligen "
              "signerad/krypterad eller använder eget format.")
        return []

    os.makedirs(outdir, exist_ok=True)
    manifest, seen = [], {}
    for n, h in enumerate(hits):
        blob = buf[h["offset"]:h["offset"] + h["size"]]
        digest = hashlib.sha256(blob).hexdigest()
        if digest in seen:
            h["duplicate_of"] = seen[digest]
            continue
        seen[digest] = n
        ext = "img" if h["type"] in ("android_sparse", "ext4", "android_boot") else "bin"
        fname = f"{n:03d}_{h['offset']:012x}_{h['type']}.{ext}"
        with open(os.path.join(outdir, fname), "wb") as f:
            f.write(blob)
        h.update(file=fname, sha256=digest)
        manifest.append(h)
        flag = "~" if h.get("size_estimated") else " "
        print(f"  {flag} {fname:<44} {h['size']/MIB:9.1f} MiB")

    with open(os.path.join(outdir, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=2)
    return manifest


# ---------------------------------------------------------------- lpunpack

def lpunpack(path, outdir):
    """Extract logical partitions from an Android super image (liblp)."""
    size = os.path.getsize(path)
    with open(path, "rb") as f:
        head = f.read(64 * 1024)

    hdr_off = None
    for cand in range(0, len(head) - 4, 4096):
        if head[cand:cand + 4] == b"\x30\x50\x4c\x41":  # LP_METADATA_HEADER_MAGIC
            hdr_off = cand
            break
    if hdr_off is None:
        sys.exit("[lpunpack] hittar ingen LP-metadata-header (super.img?)")

    magic, major, minor, hdr_size, _hc, tables_size = struct.unpack_from("<IHHIII", head, hdr_off)
    if major != 10:
        sys.exit(f"[lpunpack] oväntad major-version {major}")

    parts = []
    p_off = hdr_off + 24
    for i in range(36):
        raw = head[p_off + i * 52:p_off + (i + 1) * 52]
        if len(raw) < 52:
            break
        name = raw[:36].split(b"\x00")[0].decode("ascii", "replace")
        if not name:
            continue
        attrs, first_ext, num_ext, group = struct.unpack_from("<IIII", raw, 36)
        parts.append(dict(name=name, attrs=attrs, first_extent_index=first_ext,
                          num_extents=num_ext, group_index=group))

    ext_off = hdr_off + hdr_size
    tables_end = ext_off + tables_size
    total_ext = sum(p["num_extents"] for p in parts)
    extents = [struct.unpack_from("<QIIQI", head, ext_off + i * 24) for i in range(total_ext)]

    bdev = None
    for n in (16, 32):
        cand = tables_end - n * 64
        if cand < ext_off:
            continue
        first_logical, _al, _alo, bsize = struct.unpack_from("<QIIQ", head, cand)
        bname = head[cand + 24:cand + 60].split(b"\x00")[0]
        if first_logical == 0 and 0 < bsize <= size + 4096 and all(32 <= c < 127 for c in bname or b"x"):
            bdev = cand
            break
    if bdev is None:
        sys.exit("[lpunpack] kan inte lokalisera block device-tabellen")

    os.makedirs(outdir, exist_ok=True)
    with open(path, "rb") as src:
        for p in parts:
            dst = os.path.join(outdir, f"{p['name']}.img")
            with open(dst, "wb") as out:
                for e in extents[p["first_extent_index"]:p["first_extent_index"] + p["num_extents"]]:
                    nsec, ttype, tdata, tsrc = e
                    if ttype == 1:  # LP_TARGET_TYPE_ZERO
                        out.write(b"\x00" * nsec * 512)
                        continue
                    src.seek(tdata * 512)
                    left = nsec * 512
                    while left:
                        chunk = src.read(min(left, 4 * MIB))
                        if not chunk:
                            break
                        out.write(chunk)
                        left -= len(chunk)
            print(f"  {p['name']:<20} {os.path.getsize(dst)/MIB:9.1f} MiB")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    c = sub.add_parser("carve", help="skanna och plocka ut images ur en blob")
    c.add_argument("blob")
    c.add_argument("-o", "--outdir", default="out/fota")
    c.add_argument("--min-size", type=int, default=64 * 1024)

    l = sub.add_parser("lpunpack", help="packa upp Android super.img")
    l.add_argument("image")
    l.add_argument("-o", "--outdir", default="out/super")

    a = ap.parse_args()
    if a.cmd == "carve":
        carve(a.blob, a.outdir, a.min_size)
    else:
        lpunpack(a.image, a.outdir)


if __name__ == "__main__":
    main()
