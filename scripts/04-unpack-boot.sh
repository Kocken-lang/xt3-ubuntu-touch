#!/usr/bin/env bash
# Unpack an Android boot image (v0-v4) into kernel / ramdisk / dtb and split dtbo images.
#   usage: 04-unpack-boot.sh <boot.img|dtbo.img> [outdir]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMG="${1:?användning: $0 <boot.img|dtbo.img> [outdir]}"
OUT="${2:-$ROOT/out/boot}"
mkdir -p "$OUT"

UNPACK="$ROOT/tools/unpack_bootimg.py"
[ -f "$UNPACK" ] || { echo "saknar $UNPACK – kör 00-bootstrap.sh"; exit 1; }

magic="$(head -c 8 "$IMG" | tr -d '\0')"
echo "==> $IMG (magic: ${magic:-<binärt>})"

if [ "$magic" = "ANDROID!" ]; then
  python3 "$UNPACK" --boot_img "$IMG" --out "$OUT" --format=mkbootimg
  ls -l "$OUT"
  echo "--- kernel: $(file "$OUT/kernel")"
  # v0/v1-v2: DTB may sit inside kernel or as separate file
  if [ -f "$OUT/dtb" ]; then
    cp -f "$OUT/dtb" "$OUT/dtb-from-boot.img"
  fi
  if [ -f "$OUT/second" ]; then
    file "$OUT/second" || true
  fi
else
  # dtbo.img (Android DTBO) or a raw FDT
  if [ "$(head -c 4 "$IMG" | xxd -p)" = "d7b7ab1e" ]; then
    echo "    DTBO-format, delar upp..."
    mkdir -p "$OUT/dtb"
    python3 "$ROOT/tools/mkdtboimg.py" dump "$IMG" -b "$OUT/dtb" >/dev/null
  else
    mkdir -p "$OUT/dtb"
    cp -f "$IMG" "$OUT/dtb/$(basename "${IMG%.img}").dtb"
  fi
  for d in "$OUT"/dtb/*.dtb; do
    [ -e "$d" ] || continue
    echo "--- $(basename "$d")"
    dtc -I dtb -O dts -o "${d%.dtb}.dts" "$d" 2>/dev/null \
      && echo "    $(grep -m1 -o 'model = "[^"]*"' "${d%.dtb}.dts" || true)" \
      && grep -m1 -o 'qcom,mdss-dsi-panel-name = "[^"]*"' "${d%.dtb}.dts" \
         | sed 's/^/    panel: /' || true
  done
fi

echo "Klart -> $OUT"
