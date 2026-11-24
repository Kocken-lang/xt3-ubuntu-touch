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

say "3b/5 stanger av AVB (vbmeta)"
# 91.57 har vbmeta med verifiering pa. En modifierad boot.img far inte plats
# i den hash-kedjan, sa verifieringen maste stangas av - annars bootloop.
# Utan detta steg bootloopar enheten: varifieringen slar till pa var boot.img.
if [ ! -f vbmeta.img ]; then
  echo "  FEL: vbmeta.img saknas i paketet."
  echo "  En modifierad boot.img kan inte passera AVB utan att verifieringen"
  echo "  stangs av. Avbryter hellre an att lamna en enhet som bootloopar."
  exit 1
fi
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img

say "4/5 flashar rootfs till userdata"
if [ -f rootfs.img ]; then
  ROOTFS_B=$(stat -c%s rootfs.img)
  PART_B=$(fastboot getvar partition-size:userdata 2>&1 \
           | grep -oE '0x[0-9a-fA-F]+|[0-9]+' | tail -1)
  if [ -n "$PART_B" ]; then
    [ "$PART_B" -gt 1000000000 ] 2>/dev/null || PART_B=$((PART_B))
    if [ "$ROOTFS_B" -gt "$PART_B" ] 2>/dev/null; then
      echo "  FEL: rootfs.img ar $((ROOTFS_B/1024/1024)) MB, userdata ar"
      echo "       $((PART_B/1024/1024)) MB. Bygg mindre: sudo make rootfs SIZE=4G"
      exit 1
    fi
  fi
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
