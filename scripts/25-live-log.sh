#!/usr/bin/env bash
# Realtidslogg från XT3 över USB-C.
# Initramfs startar en CDC-ACM-gadget och strömmar dmesg dit; detta skript
# startar bilden (utan att skriva till flash) och matar loggen till terminalen.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMG="$ROOT/out/boot.img"
LOGDIR="$ROOT/out/logs"; mkdir -p "$LOGDIR"
LOG="$LOGDIR/live-$(date +%Y%m%d-%H%M%S).log"

say(){ printf '\n==> %s\n' "$*"; }
die(){ printf 'FEL: %s\n' "$*"; exit 1; }

[ -f "$IMG" ] || die "saknar $IMG - kör make image först"
command -v fastboot >/dev/null || die "fastboot saknas"
sudo fastboot devices 2>/dev/null | grep -qw fastboot \
  || die "ingen enhet i fastboot (håll Vol- + Power, anslut USB)"

# ModemManager öppnar ttyACM och släpper den inte. Stoppa under mätningen.
MM=0
if systemctl is-active --quiet ModemManager 2>/dev/null; then
        say "stoppar ModemManager (tar annars serieporten)"
        sudo systemctl stop ModemManager && MM=1
fi
cleanup(){ [ "$MM" = 1 ] && sudo systemctl start ModemManager 2>/dev/null; }
trap cleanup EXIT

say "startar bilden - skriver inget till flash"
sudo fastboot boot "$IMG" || die "fastboot boot misslyckades"

say "väntar på serieport (upp till 120 s)"
dev=""
for i in $(seq 1 120); do
        dev=$(ls /dev/ttyACM* 2>/dev/null | head -1)
        [ -n "$dev" ] && break
        sleep 1
done
[ -n "$dev" ] || die "ingen /dev/ttyACM dök upp - gadgeten startade inte"

say "serieport $dev - strömmar logg. Ctrl-C avbryter."
sudo stty -F "$dev" raw -echo 115200 2>/dev/null
sudo cat "$dev" 2>/dev/null | tee "$LOG"
