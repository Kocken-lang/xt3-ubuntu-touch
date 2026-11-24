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
