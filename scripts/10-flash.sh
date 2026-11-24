#!/usr/bin/env bash
# Flash the built boot image to the XT3. Backs up the current partitions first.
#
#   usage: 10-flash.sh --yes [--boot out/boot.img] [--dtbo out/dtbo.img]
#
# Kravs: upplast bootloader, fastboot, USB-kabel. Enheten ar DIN - men
# kontrollera alltid att out/backup/ innehaller giltiga kopior innan du fortsatter.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOT="$ROOT/out/boot.img"
DTBO=""
CONFIRM=0

while [ $# -gt 0 ]; do
  case "$1" in
    --yes) CONFIRM=1; shift ;;
    --boot) BOOT="$2"; shift 2 ;;
    --dtbo) DTBO="$2"; shift 2 ;;
    *) echo "okant argument: $1"; exit 1 ;;
  esac
done

[ "$CONFIRM" = "1" ] || { echo "vagrar utan --yes"; exit 1; }
[ -f "$BOOT" ] || { echo "saknar $BOOT"; exit 1; }

echo "==> vantar pa fastboot"
fastboot devices
fastboot getvar product 2>&1 | head -3 || true

echo "==> sakerhetskopierar nuvarande partitioner"
BK="$ROOT/out/backup"; mkdir -p "$BK"
for p in boot dtbo; do
  fastboot fetch "$p" "$BK/$p-stock.img" 2>/dev/null \
    || echo "    kunde inte lasa $p (anvand adb dd fran 01-device-inventory.sh)"
done
ls -lh "$BK" || true

echo "==> flashar boot"
fastboot flash boot "$BOOT"
if [ -n "$DTBO" ]; then
  echo "==> flashar dtbo"
  fastboot flash dtbo "$DTBO"
fi

echo "==> startar om"
fastboot reboot
echo "Klart. Kontrollera: adb devices / dmesg over UART (ttyMSM0, 115200)."
