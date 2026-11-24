#!/usr/bin/env bash
# Install out/firmware into a rootfs, using the paths mainline drivers ask for.
#
#   ./scripts/17-install-firmware.sh out/rootfs
#
# The on-disk categories (qcom/, bt/, adreno/, touch/) exist so a human can see
# where a file came from.  Mainline looks in fixed paths, so they are mapped
# here instead of at extraction time.
set -uo pipefail
DEST="${1:-}"
[ -n "$DEST" ] || { echo "usage: 17-install-firmware.sh <rootfs-mount>"; exit 2; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/out/firmware"
[ -d "$SRC" ] || { echo "saknar $SRC - kor 11 och 16 forst"; exit 1; }

install_dir() {
  local from="$1" to="$2" glob="${3:-*}"
  [ -d "$from" ] || return 0
  local n=0
  mkdir -p "$DEST/$to"
  for f in "$from"/$glob; do
    [ -f "$f" ] || continue
    install -m644 "$f" "$DEST/$to/"
    n=$((n + 1))
  done
  printf "  %-34s %3d filer\n" "$to" "$n"
}

echo "==> firmware -> $DEST/lib/firmware"
# Remoteproc, PIL, ADSP, Venus, modem and the GPU firmware all live in qcom/.
install_dir "$SRC/qcom"   lib/firmware/qcom
install_dir "$SRC/adreno" lib/firmware/qcom
# btqca asks for qcom/crbtfw*.tlv and qcom/crbtnv*.bin on this chip.
install_dir "$SRC/bt"     lib/firmware/qcom
# ath10k_snoc: firmware-5.bin + wlanmdsp.mbn + board-2.bin (nested by hw1.0)
if [ -d "$SRC/ath10k" ]; then
  mkdir -p "$DEST/lib/firmware"
  cp -a "$SRC/ath10k" "$DEST/lib/firmware/"
  echo "  lib/firmware/ath10k (rekursivt)"
fi
# Synaptics touch controller firmware, kept for re-flashing from userspace.
install_dir "$SRC/touch"  lib/firmware/synaptics

if [ -d "$SRC/wlan" ] && [ -n "$(ls -A "$SRC/wlan" 2>/dev/null)" ]; then
  echo "  not: out/firmware/wlan innehaller qcacld-filer (bdwlan*, WCNSS_qcom_cfg)"
  echo "       som mainline ath10k inte kan anvanda - de installeras inte."
fi

echo "Klart"
