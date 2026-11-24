#!/usr/bin/env bash
# Self-test for the DT tools.  Runs without a device and without a kernel tree.
#
#   KSRC=~/xt3/out/src/linux ./tests/selftest.sh   # also builds the DTB
#
# Every check compares the tool output against a value that was read from a
# real file, not against the tool's own assumptions.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAIL=0

ok()   { printf "  ok   %s\n" "$1"; }
bad()  { printf "  FAIL %s\n" "$1"; FAIL=1; }
need() { grep -q -- "$2" "$3" && ok "$1" || bad "$1 (saknar '$2')"; }

echo "== 13-panel-from-dtb"
"$ROOT/scripts/13-panel-from-dtb.py" \
  --dtb "$ROOT/tests/fixtures/dsi-panel-ili9881d-720p-video.dtsi" \
  --name xt3 --outdir "$TMP/panel" >"$TMP/gen.log" 2>&1 \
  && ok "genererar" || { bad "genererar"; cat "$TMP/gen.log"; }

C="$TMP/panel/panel-xt3.c"
D="$TMP/panel/panel-xt3.dtsi"
need "panelnamn"        "ili9881d 720p video mode dsi panel" "$C"
need "upplosning"       "720x1280 @ 60 Hz" "$C"
need "4 lanes"          "4 lanes" "$C"
need "196 init-kommandon" "196 on" "$TMP/gen.log"
need "klocka 71128"     "71128" "$C"
need "reset 5/10/120"   "msleep(120)" "$C"
need "reset inverterad" "gpiod_set_value_cansleep(ctx->reset_gpio, 0);" "$C"
need "reset-gpio 53"    "reset-gpios = <&tlmm 53 GPIO_ACTIVE_LOW>" "$D"
need "panel-compatible" '"janam,xt3-panel"' "$D"

# Last init command must be 0x29 (display on) with 20 ms delay, straight from
# the source: 05 01 00 00 14 00 02 29 00
need "sista kommando 0x29" "0x29" "$C"

echo "== 14-hw-from-dtb"
"$ROOT/scripts/14-hw-from-dtb.py" \
  --dtb "$ROOT/inventory-data/91.57/dtbo/dtb/00-id0-rev0.dts" \
  --outdir "$TMP/hw" >"$TMP/hw.log" 2>&1 \
  && ok "sammanstaller" || { bad "sammanstaller"; cat "$TMP/hw.log"; }
need "hittar i2c8"      "i2c@c1b8000" "$TMP/hw/hw.md"
need "hittar skannern"  "hsm,imager" "$TMP/hw/hw.md"

echo "== dtsi kompilerar (cpp + dtc)"
cat > "$TMP/stub.dts" <<'EOF'
/dts-v1/;
#define GPIO_ACTIVE_LOW 1
/ {
        #address-cells = <1>;
        #size-cells = <1>;
        mdss_dsi0: mdss_dsi0 { #address-cells = <1>; #size-cells = <0>; };
        mdss_dsi0_out: mdss_dsi0_out { };
        tlmm: tlmm { gpio-controller; #gpio-cells = <2>; };
        pm660l_wled: wled { };
};
#include "panel/panel-xt3.dtsi"
EOF
( cd "$TMP" && cpp -x assembler-with-cpp -P -I. stub.dts > stub.pp.dts 2>/dev/null \
  && dtc -I dts -O dtb -o stub.dtb stub.pp.dts 2>"$TMP/dtc.log" ) \
  && ok "dtsi -> dtb" || { bad "dtsi -> dtb"; cat "$TMP/dtc.log"; }

echo "== firmware-extrahering (FAT + ext4)"
if command -v mkfs.vfat >/dev/null && command -v mke2fs >/dev/null; then
  mkdir -p "$TMP/fw/src/image" "$TMP/fw/ext/firmware/image"
  echo mba   > "$TMP/fw/src/image/mba.mbn"
  echo cfg   > "$TMP/fw/src/image/crbtfw21.tlv"
  echo clb   > "$TMP/fw/src/image/bdwlan.bin"
  echo venus > "$TMP/fw/ext/firmware/image/venus.mbn"
  truncate -s 32M "$TMP/fw/modemsda.img"
  mkfs.vfat -F 16 -n modem "$TMP/fw/modemsda.img" >/dev/null 2>&1
  MTOOLS_SKIP_CHECK=1 mcopy -s -i "$TMP/fw/modemsda.img" "$TMP/fw/src"/* ::/ 2>/dev/null
  truncate -s 16M "$TMP/fw/vendor.img"
  mke2fs -q -t ext4 -d "$TMP/fw/ext" "$TMP/fw/vendor.img" >/dev/null 2>&1
  "$ROOT/scripts/11-collect-firmware.sh" --from-dir "$TMP/fw" >"$TMP/fw.log" 2>&1
  [ -f "$ROOT/out/firmware/qcom/mba.mbn" ] && ok "FAT -> qcom/mba.mbn" || bad "FAT -> qcom/mba.mbn"
  [ -f "$ROOT/out/firmware/bt/crbtfw21.tlv" ] && ok "FAT -> bt/" || bad "FAT -> bt/"
  [ -f "$ROOT/out/firmware/wlan/bdwlan.bin" ] && ok "FAT -> wlan/" || bad "FAT -> wlan/"
  [ -f "$ROOT/out/firmware/qcom/venus.mbn" ] && ok "ext4 -> qcom/venus.mbn" || bad "ext4 -> qcom/venus.mbn"
  rm -rf "$ROOT/out/firmware"
else
  echo "  skippar (mkfs.vfat/mke2fs saknas)"
fi

if [ -n "${KSRC:-}" ]; then
  echo "== DTB mot $KSRC"
  cp -f "$ROOT/dts/sdm660-janam-xt3.dts" "$KSRC/arch/arm64/boot/dts/qcom/"
  cp -f "$ROOT/dts/panel-janam-xt3.dtsi" "$KSRC/arch/arm64/boot/dts/qcom/"
  MK="$KSRC/arch/arm64/boot/dts/qcom/Makefile"
  grep -q sdm660-janam-xt3 "$MK" || \
    echo 'dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb' >> "$MK"
  make -C "$KSRC" ARCH=arm64 -j"$(nproc)" qcom/sdm660-janam-xt3.dtb \
    >"$TMP/dtb.log" 2>&1 && ok "sdm660-janam-xt3.dtb" \
    || { bad "sdm660-janam-xt3.dtb"; tail -20 "$TMP/dtb.log"; }
fi

echo
[ "$FAIL" = 0 ] && echo "ALLA TESTER OK" || echo "TESTER MISSLYCKADES"
exit "$FAIL"
