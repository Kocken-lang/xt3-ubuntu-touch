#!/usr/bin/env bash
# Aterstall XT3:s bootkedja till 91.57 utan Janams Windows-verktyg.
#
#   sudo ./scripts/22-restore-stock.sh [--with-system]
#
# Flashar de partitioner som star i boot-kedjan (xbl..vbmeta) till bada
# slottarna och rensar misc, dar ABL halls kommando ligger. System/vendor
# hoppas over som standard - de har vi aldrig rort, och de ar stora.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
P="$ROOT/out/fota/partitions"
WITH_SYSTEM=0
[ "${1:-}" = "--with-system" ] && WITH_SYSTEM=1

[ -d "$P" ] || { echo "saknar $P - kor 02-extract-fota.sh forst"; exit 1; }
command -v fastboot >/dev/null || { echo "fastboot saknas"; exit 1; }
fastboot devices | grep -qw fastboot || {
  echo "Ingen enhet i fastboot. Hall Vol- + Power, anslut USB."; exit 1; }

say() { printf '\n==> %s\n' "$*"; }

say "rensar misc (ABL:s kommandopartition)"
fastboot erase misc || echo "  varning: kunde inte rensa misc"

say "flashar bootkedjan, bada slottarna"
# Ordnning: laddaren forst, sedan det den laddar.
SLOTTED="xbl abl tz hyp rpm pmic devcfg keymaster cmnlib cmnlib64
         modem dsp bluetooth mdtp mdtpsecapp fsgbk dtbo boot vbmeta"
for part in $SLOTTED; do
  img="$P/$part.img"
  [ -f "$img" ] || { echo "  hoppar $part (saknas)"; continue; }
  for s in a b; do
    if fastboot flash "${part}_$s" "$img" >/dev/null 2>&1; then
      echo "  ${part}_$s"
    else
      echo "  ${part}_$s  MISSLYCKADES"
    fi
  done
done

if [ "$WITH_SYSTEM" = "1" ]; then
  say "flashar system och vendor (stort, ~4 GB per slot)"
  for part in system vendor; do
    img="$P/$part.img"
    [ -f "$img" ] || continue
    for s in a b; do
      fastboot flash "${part}_$s" "$img" || echo "  ${part}_$s MISSLYCKADES"
    done
  done
else
  say "system/vendor ororda (kor med --with-system om de behovs)"
fi

say "markerar slot a aktiv"
fastboot set_active a || true
fastboot erase misc  || true   # set_active kan lamna kvar ett kommando

say "klart - startar om"
fastboot reboot
cat <<EOF

Om enheten fortfarande gar till fastboot: klistra in
  fastboot getvar all 2>&1 | grep -iE "slot-|battery|secure|kernel"
och resultatet av
  fastboot continue
EOF
