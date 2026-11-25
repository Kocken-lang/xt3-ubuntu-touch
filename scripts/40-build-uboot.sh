#!/usr/bin/env bash
# Bygger U-Boot (sdm660-mainline, main-sdm660) for Janam XT3 och packar den
# som en Android boot image enligt projektets eget CI-recept:
#   gzip(u-boot-nodtb.bin) + pahangd DTB  ->  "kernel"-faltet
#   tom initramfs, cmdline "uboot2nd", v0-header, sdm660-adresser.
#
# Resultat: out/boot-uboot-xt3.img
# Ger: bootmeny pa skarmen, fastboot, UMS (eMMC som USB-lagring) och
#      "fastboot oem log" - en loggkanal utan UART.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/out/uboot-src"
OUT="$ROOT/out"
BRANCH="${UBOOT_BRANCH:-main-sdm660}"
DTS_SRC="$ROOT/dts/uboot/sdm660-janam-xt3.dts"
DTB_NAME="sdm660-janam-xt3"

need() { command -v "$1" >/dev/null || { echo "saknar $1"; exit 1; }; }
need git; need make; need gcc; need gzip; need python3
need aarch64-linux-gnu-gcc

if [ ! -d "$SRC/.git" ]; then
  echo "==> klonar u-boot ($BRANCH)"
  git clone --depth 1 --single-branch -b "$BRANCH" \
    https://github.com/sdm660-mainline/u-boot.git "$SRC" || exit 1
fi

cp "$DTS_SRC" "$SRC/dts/upstream/src/arm64/qcom/$DTB_NAME.dts" || exit 1

cd "$SRC" || exit 1
export CROSS_COMPILE=aarch64-linux-gnu-
make O=.output qcom_defconfig >/dev/null 2>&1 || { echo "defconfig fel"; exit 1; }
sed -i "s|^CONFIG_DEFAULT_DEVICE_TREE=.*|CONFIG_DEFAULT_DEVICE_TREE=\"qcom/$DTB_NAME\"|" .output/.config
make O=.output olddefconfig >/dev/null 2>&1

echo "==> bygger"
make O=.output -j"$(nproc)" >/tmp/uboot-build.log 2>&1
rc=$?
[ $rc -ne 0 ] && { echo "BYGGFEL, se /tmp/uboot-build.log"; tail -15 /tmp/uboot-build.log; exit $rc; }

NODTB="$SRC/.output/u-boot-nodtb.bin"
DTB="$SRC/.output/dts/upstream/src/arm64/qcom/$DTB_NAME.dtb"
[ -s "$NODTB" ] || { echo "saknar $NODTB"; exit 1; }
[ -s "$DTB" ]   || { echo "saknar $DTB"; exit 1; }

echo "==> packar boot image"
python3 - "$NODTB" "$DTB" "$OUT/boot-uboot-xt3.img" <<'PY'
import sys, gzip, struct, hashlib, pathlib
nodtb, dtb, out = sys.argv[1:4]
kernel = gzip.compress(pathlib.Path(nodtb).read_bytes(), 9) + pathlib.Path(dtb).read_bytes()
ramdisk = gzip.compress(b"1", 9)
PAGE = 4096
cmdline = b"uboot2nd"; name = b"Janam XT3 U-Boot"
def pad(b):
    r = len(b) % PAGE
    return b + b"\0" * (PAGE - r if r else 0)
h = b"ANDROID!"
h += struct.pack("<I", len(kernel)) + struct.pack("<I", 0x8000)
h += struct.pack("<I", len(ramdisk)) + struct.pack("<I", 0x1000000)
h += struct.pack("<I", 0) + struct.pack("<I", 0xf00000)
h += struct.pack("<I", 0x100) + struct.pack("<I", PAGE)
h += struct.pack("<I", 0) + struct.pack("<I", 0)
h += name.ljust(16, b"\0") + cmdline.ljust(512, b"\0")
h += hashlib.sha1(kernel + struct.pack("<I", len(kernel)) + ramdisk +
                  struct.pack("<I", len(ramdisk)) + struct.pack("<I", 0) + name + cmdline).digest()
h += b"\0" * 8
img = h.ljust(PAGE, b"\0") + pad(kernel) + pad(ramdisk)
pathlib.Path(out).write_bytes(img)
print(f"kernel={len(kernel)} ramdisk={len(ramdisk)} image={len(img)}")
PY

echo "Klart -> $OUT/boot-uboot-xt3.img"
