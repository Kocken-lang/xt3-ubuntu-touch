1795627756278898124
=== 06-fetch-mainline.sh
#!/usr/bin/env bash
# Clone the mainline SDM660 kernel tree and the lk2nd bootloader (both shallow).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/out/src"; mkdir -p "$SRC"
BRANCH="${BRANCH:-qcom-sdm660-7.2.y}"

[ -d "$SRC/linux/.git" ] || git clone --depth 1 -b "$BRANCH" \
  https://github.com/sdm660-mainline/linux "$SRC/linux"
[ -d "$SRC/lk2nd/.git" ] || git clone --depth 1 \
  https://github.com/sdm660-mainline/lk2nd "$SRC/lk2nd"

echo "==> karnversion"
make -s -C "$SRC/linux" kernelversion
echo "==> defconfig: $(ls "$SRC/linux/arch/arm64/configs/sdm660_defconfig")"

=== 07-build-kernel.sh
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
