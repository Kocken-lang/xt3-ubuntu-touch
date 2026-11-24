#!/usr/bin/env bash
# Bygg en DTB-variant for att isolera vilken nod som far karnan att doda.
#
#   ./scripts/24-dtb-variant.sh no-panel    # panelnoden avstangd
#   ./scripts/24-dtb-variant.sh no-mdss     # mdss/dsi/phy avstangda
#   ./scripts/24-dtb-variant.sh no-touch    # touchnoden avstangd
#
# Skriver out/boot-<variant>.img (samma Image.gz, initramfs och padding som
# 09), redo att flasha.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
V="${1:-}"
K="$ROOT/out/src/linux"
[ -d "$K" ] || { echo "saknar karnkalla - kor make kernel forst"; exit 1; }

case "$V" in
  no-panel) OVERRIDE='&panel { status = "disabled"; };' ;;
  no-mdss)  OVERRIDE='&mdss { status = "disabled"; };' ;;
  no-touch) OVERRIDE='&touchscreen { status = "disabled"; };' ;;
  *) echo "usage: $0 no-panel|no-mdss|no-touch"; exit 1 ;;
esac

TMP=$(mktemp -d)
cat "$ROOT/dts/sdm660-janam-xt3.dts" > "$TMP/board.dts"
printf '\n/* variant: %s */\n%s\n' "$V" "$OVERRIDE" >> "$TMP/board.dts"

cpp -nostdinc -undef -x assembler-with-cpp \
  -I "$ROOT/dts" -I "$K/include" \
  -I "$K/arch/arm64/boot/dts" -I "$K/arch/arm64/boot/dts/qcom" \
  "$TMP/board.dts" -o "$TMP/board.pp.dts"
dtc -I dts -O dtb -o "$TMP/board.dtb" "$TMP/board.pp.dts" 2>/dev/null

echo "==> dtb: $V, $(stat -c%s "$TMP/board.dtb") byte"

OSV=0
STOCK="$ROOT/out/fota/partitions/boot.img"
[ -f "$STOCK" ] && OSV=$(python3 -c "
import struct,sys
d=open('$STOCK','rb').read(64)
print(struct.unpack_from('<I',d,44)[0] if d[:8]==b'ANDROID!' else 0)")

python3 "$ROOT/scripts/pack-bootimg.py" \
  --kernel "$ROOT/out/kernel/Image.gz" \
  --ramdisk "$ROOT/out/initramfs.img" \
  --dtb "$TMP/board.dtb" \
  --output "$ROOT/out/boot-$V.img" \
  --cmdline "console=tty0 console=ttyMSM0,115200n8 earlycon root=LABEL=ut-rootfs rootwait rw loglevel=7" \
  --os_version "$OSV" --pad_to 67108864
echo "==> out/boot-$V.img"
rm -rf "$TMP"
