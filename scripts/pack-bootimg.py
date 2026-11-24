#!/usr/bin/env python3
"""Packa en Android boot image (header v2) utan AOSP-verktyg.

Anvands av 09-pack-boot.sh. AOSP:s mkbootimg.py kraver sitt gki/-paket, som
inte foljer med nar bara filen laddas ner. Layout for v2, allt little endian:

  header (1660 B, paddad till page_size)
  kernel, ramdisk, second (0), recovery_dtbo (0), dtb
"""
import argparse
import hashlib
import struct
import sys

MAGIC = b"ANDROID!"
HEADER_V2 = 1660


def pad(data, page):
    rem = len(data) % page
    return data + b"\0" * (page - rem) if rem else data


def build(kernel, ramdisk, dtb, page, cmdline, name, base,
          kernel_offset, ramdisk_offset, tags_offset, dtb_offset, os_version=0):
    hdr = bytearray(HEADER_V2)
    struct.pack_into("8s", hdr, 0, MAGIC)
    struct.pack_into("<10I", hdr, 8,
                     len(kernel), base + kernel_offset,
                     len(ramdisk), base + ramdisk_offset,
                     0, base + ramdisk_offset,
                     base + tags_offset, page, 2, os_version)
    struct.pack_into("16s", hdr, 48, name.encode()[:16])
    struct.pack_into("512s", hdr, 64, cmdline.encode()[:511])
    sha = hashlib.sha1()
    sha.update(kernel)
    sha.update(struct.pack("<I", len(kernel)))
    sha.update(ramdisk)
    sha.update(struct.pack("<I", len(ramdisk)))
    sha.update(struct.pack("<I", 0))
    struct.pack_into("32s", hdr, 576, sha.digest())
    struct.pack_into("<IQI", hdr, 1632, 0, 0, HEADER_V2)
    struct.pack_into("<IQ", hdr, 1648, len(dtb), base + dtb_offset)
    return b"".join([pad(bytes(hdr), page), pad(kernel, page),
                     pad(ramdisk, page), pad(dtb, page)])


def main():
    ap = argparse.ArgumentParser()
    for f in ("kernel", "ramdisk", "dtb", "output"):
        ap.add_argument(f"--{f}", required=True)
    ap.add_argument("--cmdline", default="")
    ap.add_argument("--name", default="")
    ap.add_argument("--pagesize", type=int, default=4096)
    ap.add_argument("--base", type=lambda v: int(v, 0), default=0)
    ap.add_argument("--kernel_offset", type=lambda v: int(v, 0), default=0x8000)
    ap.add_argument("--ramdisk_offset", type=lambda v: int(v, 0), default=0x1000000)
    ap.add_argument("--tags_offset", type=lambda v: int(v, 0), default=0x100)
    ap.add_argument("--dtb_offset", type=lambda v: int(v, 0), default=0x1F00000)
    ap.add_argument("--os_version", type=lambda v: int(v, 0), default=0)
    a = ap.parse_args()

    def read(p):
        with open(p, "rb") as fh:
            return fh.read()

    img = build(read(a.kernel), read(a.ramdisk), read(a.dtb), a.pagesize,
                a.cmdline, a.name, a.base, a.kernel_offset, a.ramdisk_offset,
                a.tags_offset, a.dtb_offset, a.os_version)
    with open(a.output, "wb") as fh:
        fh.write(img)
    print(f"    {a.output}: {len(img)} byte, header v2, sida {a.pagesize}")


if __name__ == "__main__":
    sys.exit(main())
