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
MK="$KSRC/arch/arm64/boot/dts/qcom/Makefile"
grep -q "$DTS_NAME" "$MK" || \
  echo "dtb-\$(CONFIG_ARCH_QCOM) += ${DTS_NAME%.dts}.dtb" >> "$MK"

echo "==> defconfig + fragment"
make -C "$KSRC" O="$KB" sdm660_defconfig
"$KSRC/scripts/kconfig/merge_config.sh" -m -O "$KB" \
  "$KB/.config" "$ROOT/scripts/60-waydroid.config" "$ROOT/scripts/61-performance.config"
make -C "$KSRC" O="$KB" olddefconfig

echo "==> bygger med $(nproc) jobb"
make -C "$KSRC" O="$KB" -j"$(nproc)" Image.gz dtbs 2>&1 | tail -40

mkdir -p "$ROOT/out/kernel"
cp -f "$KB/arch/arm64/boot/Image.gz" "$ROOT/out/kernel/"
cp -f "$KB/arch/arm64/boot/dts/qcom/${DTS_NAME%.dts}.dtb" "$ROOT/out/kernel/"
ls -lh "$ROOT/out/kernel/"
