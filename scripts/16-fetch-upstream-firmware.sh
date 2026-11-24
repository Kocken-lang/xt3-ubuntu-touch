#!/usr/bin/env bash
# Fetch the firmware mainline needs but the vendor image does not ship in the
# form mainline expects.  Everything is pinned to one linux-firmware commit and
# verified with sha256, so a build is reproducible and cannot silently pick up
# a different blob.
#
#   ./scripts/16-fetch-upstream-firmware.sh            # -> out/firmware/
#   ./scripts/16-fetch-upstream-firmware.sh --check    # verify only
#
# Why these files:
#   qcom/a630_sqe.fw, qcom/a630_gmu.bin   freedreno a6xx (GPUs own firmware)
#   ath10k/WCN3990/hw1.0/*                ath10k_snoc; the vendor bdwlan.bin is
#                                         for qcacld and cannot be used here
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out/firmware"
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

LF_COMMIT=c637ebae94198f45cf58d74a3adb91e4d4068571
BASE="https://gitlab.com/kernel-firmware/linux-firmware/-/raw/$LF_COMMIT"

files=(
  "qcom/a630_sqe.fw                        1c21b527d9183487cc550dabbb3f43e555df5a977a461934fc61f0635a9aa90c"
  "qcom/a630_gmu.bin                       da8d9b1b1f5c1a0b311f32567093b4828f3c80031dd8435f91ac13c664e173a6"
  "ath10k/WCN3990/hw1.0/firmware-5.bin     fef6539e0127579536bc977be57a90d018b83f2931fedc3a8870fbe38d6c4127"
  "ath10k/WCN3990/hw1.0/wlanmdsp.mbn       92e1501254e6de78c0f2e2cf091507d488b608d07e53acd14813a82744823ec2"
  "ath10k/WCN3990/hw1.0/board-2.bin        c49d2f1894de6edc0ab0c8c9a17ca0328703747c49b6e9428f1de501c2c02c1d"
)

fail=0
for row in "${files[@]}"; do
  read -r path sum <<<"$row"
  dst="$OUT/$path"
  if [ "$CHECK" = 0 ]; then
    mkdir -p "$(dirname "$dst")"
    if ! curl -sfL --retry 3 -o "$dst" "$BASE/$path"; then
      echo "  FEL  $path (nedladdning misslyckades)"
      fail=1
      continue
    fi
  fi
  if [ ! -f "$dst" ]; then
    echo "  saknas  $path"
    fail=1
    continue
  fi
  got=$(sha256sum "$dst" | cut -d' ' -f1)
  if [ "$got" = "$sum" ]; then
    printf "  ok   %-40s %8s byte\n" "$path" "$(stat -c%s "$dst")"
  else
    echo "  FEL  $path: sha256 $got != $sum"
    fail=1
  fi
done

echo
echo "linux-firmware @ $LF_COMMIT"
[ "$fail" = 0 ] || { echo "minst en fil ar felaktig"; exit 1; }
