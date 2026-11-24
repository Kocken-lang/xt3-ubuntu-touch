#!/usr/bin/env bash
# End user installer, shipped INSIDE the release zip. No editing required.
#
#   ./install.sh [--wipe]
#
# Steps: verify checksums -> check fastboot -> flash boot -> flash rootfs to userdata
#        -> reboot. Stock can always be restored with the original 91.57 FOTA package.
set -euo pipefail
cd "$(dirname "$0")"
WIPE=0
[ "${1:-}" = "--wipe" ] && WIPE=1

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }

say "1/5 verifierar filer"
if [ -f SHA256SUMS ]; then
  sha256sum -c SHA256SUMS
else
  echo "  ingen SHA256SUMS - hoppar over"
fi

say "2/5 kontrollerar verktyg"
command -v fastboot >/dev/null || { echo "fastboot saknas: sudo apt install fastboot"; exit 1; }
fastboot devices
fastboot devices | grep -qw fastboot || {
  echo "  Ingen enhet i fastboot-lage. Stang av, hall Vol- + Power, anslut USB."; exit 1; }

say "3/5 flashar boot"
# 91.57 ar en A/B-enhet (ota-type=AB) -> boot och dtbo finns per slot
SLOTS=$(fastboot getvar slot-count 2>&1 | grep -o '[0-9]\+' | head -1)
if [ "${SLOTS:-1}" -ge 2 ]; then
  echo "  A/B-enhet ($SLOTS slots) - flashar bada"
  fastboot --slot all flash boot boot.img
else
  fastboot flash boot boot.img
fi

say "4/5 flashar rootfs till userdata"
if [ -f rootfs.img ]; then
  fastboot flash userdata rootfs.img
else
  echo "  rootfs.img saknas - hoppar over (bootar befintligt system)"
fi

if [ "$WIPE" = "1" ]; then
  say "extra: rensar metadata/cache"
  fastboot erase metadata 2>/dev/null || true
  fastboot erase cache 2>/dev/null || true
fi

say "5/5 startar om"
fastboot reboot
echo
echo "Klart. Forsta uppstart kan ta 2-3 minuter."
echo "Felsokning: koppla UART till ttyMSM0 @115200, eller 'adb devices' efter ~60 s."
