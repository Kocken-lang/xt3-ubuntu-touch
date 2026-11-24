#!/usr/bin/env bash
# Build the SDM660 mainline kernel + device tree for the XT3.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KSRC="${KSRC:-$ROOT/out/src/linux}"
KB="$ROOT/out/kbuild"
DTS_NAME="sdm660-janam-xt3.dts"
export ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE:-aarch64-linux-gnu-}"

[ -d "$KSRC" ] || { echo "kor 06-fetch-mainline.sh forst"; exit 1; }
mkdir -p "$KB"

echo "==> installerar DTS i tradet"
cp -f "$ROOT/dts/$DTS_NAME" "$KSRC/arch/arm64/boot/dts/qcom/$DTS_NAME"
cp -f "$ROOT/dts/panel-janam-xt3.dtsi" "$KSRC/arch/arm64/boot/dts/qcom/"
MK="$KSRC/arch/arm64/boot/dts/qcom/Makefile"
grep -q "$DTS_NAME" "$MK" || \
  echo "dtb-\$(CONFIG_ARCH_QCOM) += ${DTS_NAME%.dts}.dtb" >> "$MK"

echo "==> installerar paneldrivrutin"
PANEL_SRC="$ROOT/panel/panel-janam-xt3.c"
if [ -f "$PANEL_SRC" ]; then
  cp -f "$PANEL_SRC" "$KSRC/drivers/gpu/drm/panel/"
  PMK="$KSRC/drivers/gpu/drm/panel/Makefile"
  grep -q "panel-janam-xt3" "$PMK" || \
    echo 'obj-$(CONFIG_DRM_PANEL_JANAM_XT3) += panel-janam-xt3.o' >> "$PMK"
  PK="$KSRC/drivers/gpu/drm/panel/Kconfig"
  if ! grep -q "DRM_PANEL_JANAM_XT3" "$PK"; then
    echo "" >> "$PK"
    cat "$ROOT/panel/Kconfig" >> "$PK"
  fi
fi

echo "==> defconfig + fragment"
make -C "$KSRC" O="$KB" sdm660_defconfig
"$KSRC/scripts/kconfig/merge_config.sh" -m -O "$KB" \
  "$KB/.config" "$ROOT/scripts/60-waydroid.config" "$ROOT/scripts/61-performance.config"
make -C "$KSRC" O="$KB" olddefconfig

echo "==> bygger med $(nproc) jobb"
# VIKTIGT: 617 symboler ar =m (ath10k_snoc, btqca, drm_msm, qcom_ipa,
# alla remoteproc/PIL). Bygger man bara Image.gz saknas WiFi, BT, GPU och modem.
make -C "$KSRC" O="$KB" -j"$(nproc)" Image.gz modules dtbs 2>&1 | tail -40

mkdir -p "$ROOT/out/kernel"
cp -f "$KB/arch/arm64/boot/Image.gz" "$ROOT/out/kernel/"
MODDIR="$ROOT/out/kernel/modules"
rm -rf "$MODDIR"
make -C "$KSRC" O="$KB" INSTALL_MOD_PATH="$MODDIR" \
     INSTALL_MOD_STRIP=--strip-debug modules_install 2>&1 | tail -3
built=$(find "$KB" -name '*.ko' | wc -l)
installed=$(find "$MODDIR" -name '*.ko' | wc -l)
echo "    $built byggda, $installed installerade i out/kernel/modules"
if [ "$installed" -eq 0 ] && [ "$built" -gt 0 ]; then
  echo "    kbuild installerade inget - kopierar modulerna for hand"
  rel=$(make -s -C "$KSRC" O="$KB" kernelrelease)
  dest="$MODDIR/lib/modules/$rel"
  while IFS= read -r ko; do
    install -D -m644 "$ko" "$dest/kernel/${ko#"$KB"/}"
  done < <(find "$KB" -name '*.ko')
  depmod -b "$MODDIR" "$rel" 2>/dev/null || true
  installed=$(find "$MODDIR" -name '*.ko' | wc -l)
  echo "    $installed moduler efter manuell kopiering"
fi
if [ "$installed" -eq 0 ]; then
  echo "FEL: inga moduler installerade. Innehall i out/kernel/modules:"
  find "$MODDIR" -maxdepth 6 | head -20
  echo "Byggda moduler i out/kbuild: $built"
  find "$KB" -name '*.ko' | head -3
  exit 1
fi
cp -f "$KB/arch/arm64/boot/dts/qcom/${DTS_NAME%.dts}.dtb" "$ROOT/out/kernel/"
ls -lh "$ROOT/out/kernel/"
