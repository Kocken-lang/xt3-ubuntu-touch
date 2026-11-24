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
# --slot all ar avgörande: boot skrivs till bada slottarna, sa verifieringen
# maste stangas av pa bada. Tidigare gick vbmeta bara till aktuell slot, och
# da verifierar den andra slotens vbmeta var bild mot sin ursprungliga hash.
if ! fastboot --disable-verity --disable-verification --slot all \
      flash vbmeta vbmeta.img 2>/dev/null; then
  echo "  --slot all stods inte av fastboot - flashar vbmeta_a och vbmeta_b"
  for s in a b; do
    fastboot --disable-verity --disable-verification flash "vbmeta_$s" vbmeta.img
  done
fi

say "4/5 flashar rootfs till userdata"
if [ -f rootfs.img ]; then
  ROOTFS_B=$(stat -c%s rootfs.img)
  # fastboot svarar "partition-size:userdata: 0x1d0f00000" (hex) eller ibland
  # bara ett tal. Kan vi inte lasa det later vi flashningen forsoka - okant
  # ar inte samma sak som for litet.
  PART_RAW=$(fastboot getvar partition-size:userdata 2>&1 \
             | grep -i 'partition-size' | sed 's/.*: *//' | tr -d ' \r')
  PART_B=""
  case "$PART_RAW" in
    0x*|0X*) PART_B=$((PART_RAW)) ;;
    ''|*[!0-9]*) PART_B="" ;;
    *) PART_B="$PART_RAW" ;;
  esac
  if [ -n "$PART_B" ] && [ "$PART_B" -gt 0 ] 2>/dev/null; then
    echo "  rootfs $((ROOTFS_B/1024/1024)) MB, userdata $((PART_B/1024/1024)) MB"
    if [ "$ROOTFS_B" -gt "$PART_B" ]; then
      echo "  FEL: rootfs.img ar storre an partitionen."
      echo "  Bygg mindre: sudo make rootfs SIZE=4G && make image && make release"
      exit 1
    fi
  else
    echo "  kunde inte lasa userdata-storleken - later fastboot forsoka"
  fi
  # rootfs.img ar en sparse fil (skapad med truncate + mkfs). fastboots
  # sparse-omvandling raknar fel pa hal och skickar bara en del av imagen -
  # flashningen sager OKAY men enheten har ingen giltig rot. Skriv darfor en
  # tat (dense) kopia forst och flasha den.
  FLASH_IMG=rootfs.img
  APPARENT=$(stat -c%s rootfs.img)
  ACTUAL=$(( $(du -s --bytes rootfs.img | cut -f1) ))
  if [ "$ACTUAL" -lt $((APPARENT * 9 / 10)) ]; then
    echo "  rootfs.img ar sparse ($((ACTUAL/1024/1024)) MB pa disk av $((APPARENT/1024/1024)) MB)"
    echo "  skriver tat kopia - tar en stund, och kraver plats i /tmp"
    FLASH_IMG=$(mktemp /tmp/xt3-rootfs-XXXXXX.img)
    cp --sparse=never rootfs.img "$FLASH_IMG"
  fi
  fastboot flash userdata "$FLASH_IMG"
  [ "$FLASH_IMG" = rootfs.img ] || rm -f "$FLASH_IMG"
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
