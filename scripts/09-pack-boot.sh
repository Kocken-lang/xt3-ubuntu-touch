#!/usr/bin/env bash
# Pack kernel + DTB + initramfs into an Android boot image the XT3 bootloader accepts.
#
#   usage: 09-pack-boot.sh [--initrd <file|dir>] [--cmdline "..."]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL="${KERNEL:-$ROOT/out/kernel/Image.gz}"
DTB="${DTB:-$(ls "$ROOT"/out/kernel/*.dtb 2>/dev/null | head -1)}"
INITRD="${INITRD:-}"
CMDLINE="${CMDLINE:-console=ttyMSM0,115200n8 earlycon root=LABEL=ut-rootfs rootwait rw loglevel=7}"
OUTIMG="${OUTIMG:-$ROOT/out/boot.img}"

while [ $# -gt 0 ]; do
  case "$1" in
    --initrd) INITRD="$2"; shift 2 ;;
    --cmdline) CMDLINE="$2"; shift 2 ;;
    *) echo "okant argument: $1"; exit 1 ;;
  esac
done

[ -f "$KERNEL" ] || { echo "saknar kernel: $KERNEL (kor 07-build-kernel.sh)"; exit 1; }
[ -n "$DTB" ] && [ -f "$DTB" ] || { echo "saknar dtb i out/kernel/"; exit 1; }

if [ -z "$INITRD" ]; then
  if [ -d "$ROOT/out/initramfs" ]; then
    echo "==> bygger initramfs fran out/initramfs/"
    INITRD="$ROOT/out/initramfs.cpio.gz"
    ( cd "$ROOT/out/initramfs" && find . -print0 \
        | cpio --null -o -H newc --quiet | gzip -9 ) > "$INITRD"
  elif [ -f "$ROOT/out/initramfs.img" ]; then
    INITRD="$ROOT/out/initramfs.img"
  else
    cat <<EOF
Saknar initramfs. Tre vagar:
  a) lagg en katalog i out/initramfs/ (t.ex. fran Ubuntu Touch mainline-initramfs)
  b) lagg en fardig bild i out/initramfs.img
  c) kor med --initrd <fil>
EOF
    exit 1
  fi
fi

echo "==> mkbootimg"
# XT3:s boot_a/boot_b ar 64 MB (67108864 byte). Ett for stort image flashar
# "lyckat" men startar inte, sa vi kontrollerar det har i stallet.
BOOT_MAX=$((64 * 1024 * 1024))
# scripts/pack-bootimg.py ar sjalvstandig (header v2). AOSP:s mkbootimg.py kraver
# sitt gki/-paket, som inte foljer med nar bara filen laddas ner - darfor
# anvands den bara om den faktiskt ar komplett.
PACKER="$ROOT/scripts/pack-bootimg.py"
if [ -f "$ROOT/tools/mkbootimg.py" ] && \
   python3 -c "import sys; sys.path.insert(0,'$ROOT/tools'); import gki" 2>/dev/null; then
  PACKER="$ROOT/tools/mkbootimg.py"
fi
# os_version i stock-headern (offset 44). ABL ser den; vi ateranvander
# enhetens eget varde i stallet for att skriva 0.
OSV=0
STOCK="$ROOT/out/fota/partitions/boot.img"
if [ -f "$STOCK" ]; then
  OSV=$(python3 - "$STOCK" <<'PYEOF'
import struct, sys
d = open(sys.argv[1], "rb").read(64)
print(struct.unpack_from("<I", d, 44)[0] if d[:8] == b"ANDROID!" else 0)
PYEOF
)
fi

# Stock ar padad till hela partitionen (64 MB). Qualcomm-ABL laser en fast
# region, sa vi fyller ut till samma storlek.
BOOT_PAD=67108864
[ -f "$STOCK" ] && BOOT_PAD=$(stat -c%s "$STOCK")

python3 "$PACKER" \
  --os_version "$OSV" --pad_to "$BOOT_PAD" \
  --kernel "$KERNEL" \
  --ramdisk "$INITRD" \
  --dtb "$DTB" \
  --cmdline "$CMDLINE" \
  --base 0x00000000 \
  --kernel_offset 0x00008000 \
  --ramdisk_offset 0x01000000 \
  --tags_offset 0x00000100 \
  --pagesize 4096 \
  --header_version 2 \
  --output "$OUTIMG"

ls -lh "$OUTIMG"
BOOT_SIZE=$(stat -c%s "$OUTIMG")
if [ "$BOOT_SIZE" -gt "$BOOT_MAX" ]; then
  echo "FEL: boot.img ar $((BOOT_SIZE / 1024 / 1024)) MB, partitionen ar 64 MB."
  echo "     Minsta initramfs: MODULES=dep i /etc/initramfs-tools/initramfs.conf"
  echo "     bygg om med: sudo make rootfs && make image"
  exit 1
fi
echo "    $((BOOT_SIZE / 1024 / 1024)) MB av 64 MB"
echo "Klart -> $OUTIMG"
