#!/usr/bin/env bash
# Collect everything we need to know about the XT3 from the device itself.
# Requires: USB debugging enabled, adb installed. Root helps (adb root) but is optional.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out/inventory"
mkdir -p "$OUT"

command -v adb >/dev/null || { echo "adb saknas"; exit 1; }
adb start-server >/dev/null 2>&1

if ! adb devices | grep -qw device; then
  echo "Ingen enhet. Slå på USB-felsökning och auktorisera datorn."
  adb devices; exit 1
fi

SU=""
adb root >/dev/null 2>&1 && sleep 2 && SU="root" || true
sh_() { adb shell "$@" 2>/dev/null || true; }
grab() { local f="$1"; shift; { echo "\$ $*"; sh_ "$@"; } > "$OUT/$f" 2>&1 || true; }

echo "==> identitet"
grab 00-getprop.txt        getprop
grab 01-bootprops.txt      'getprop | grep -E "^\[ro\.(boot|product|vendor|hardware)"'
grab 02-cmdline.txt        cat /proc/cmdline
grab 03-uname.txt          uname -a
grab 04-cpuinfo.txt        cat /proc/cpuinfo
grab 05-soc.txt            'cat /sys/devices/soc0/{machine,family,platform,soc_id,revision} 2>/dev/null'

echo "==> partitioner"
grab 10-by-name.txt        'ls -l /dev/block/by-name/ 2>/dev/null || ls -l /dev/block/bootdevice/by-name/'
grab 11-partitions.txt     'cat /proc/partitions'
grab 12-block-sizes.txt    'for d in /dev/block/by-name/*; do printf "%s " "$d"; blockdev --getsize64 "$d"; done'

echo "==> display / touch / input"
grab 20-drm.txt            'for d in /sys/class/drm/*; do echo "$d: $(cat $d/status 2>/dev/null)"; done'
grab 21-input.txt          'cat /proc/bus/input/devices'
grab 22-i2c.txt            'for d in /sys/bus/i2c/devices/*; do echo "$(basename $d) $(cat $d/name 2>/dev/null)"; done'
grab 23-spi.txt            'ls /sys/bus/spi/devices/ 2>/dev/null; for d in /sys/bus/spi/devices/*; do echo "$(basename $d) $(cat $d/modalias 2>/dev/null)"; done'
grab 24-gpio.txt           'cat /sys/kernel/debug/gpio 2>/dev/null || cat /sys/class/gpio/gpiochip*/label'
grab 25-tty.txt            'ls -l /dev/tty* 2>/dev/null | head -40'
grab 26-panel.txt          'dumpsys SurfaceFlinger 2>/dev/null | head -60'

echo "==> power / thermal / clocks (för strypningsanalys)"
grab 30-thermal.txt        'for z in /sys/class/thermal/thermal_zone*; do echo "$(basename $z) $(cat $z/type) $(cat $z/temp)"; done'
grab 31-cpufreq.txt        'for c in /sys/devices/system/cpu/cpu*/cpufreq; do echo "$c"; cat $c/scaling_available_frequencies $c/scaling_governor 2>/dev/null; done'
grab 32-devfreq.txt        'ls /sys/class/devfreq/ 2>/dev/null'
grab 33-battery.txt        'dumpsys battery 2>/dev/null | head -30'

echo "==> radios"
grab 40-modem.txt          'ls -l /dev/subsys_* /dev/rmnet* 2>/dev/null; getprop | grep -iE "radio|modem|baseband" | head -20'
grab 41-wifi-bt.txt        'getprop | grep -iE "wifi|bluetooth" | head -20; ls /sys/class/ieee80211 2>/dev/null'

echo "==> enterprise (skanner/RFID/SAM/MSR)"
grab 50-vendor-services.txt 'service list 2>/dev/null | grep -iE "device|scanner|serial|rfid|sam|msr|spi|gpio|hijack"'
grab 51-vendor-libs.txt     'ls -l /vendor/lib64/ 2>/dev/null | grep -iE "device|scanner|serial|rfid|sam|msr|gpio"'
grab 52-ttyhsl.txt          'ls -l /dev/ttyHSL* /dev/ttyMSM* 2>/dev/null; cat /proc/tty/drivers 2>/dev/null'

echo "==> kernel logg"
grab 60-dmesg.txt          dmesg

echo "==> device tree (rå)"
if [ "$SU" = "root" ]; then
  adb shell 'tar -cf /data/local/tmp/dt.tar -C /proc device-tree 2>/dev/null' || true
  adb pull /data/local/tmp/dt.tar "$OUT/70-device-tree.tar" >/dev/null 2>&1 || true
  mkdir -p "$OUT/70-device-tree"
  tar -xf "$OUT/70-device-tree.tar" -C "$OUT/70-device-tree" 2>/dev/null || true
fi

echo "==> dump av boot-partitioner (för DTB + panel)"
mkdir -p "$ROOT/out/stock"
for p in boot dtbo; do
  if adb shell "test -e /dev/block/by-name/$p" 2>/dev/null; then
    echo "   $p ..."
    adb shell "dd if=/dev/block/by-name/$p of=/data/local/tmp/$p.img bs=4M" >/dev/null 2>&1 || true
    adb pull "/data/local/tmp/$p.img" "$ROOT/out/stock/$p.img" >/dev/null 2>&1 || true
    adb shell "rm -f /data/local/tmp/$p.img" || true
  fi
done

{
  echo "# Inventering $(date -Is)"
  echo "adb root: ${SU:-nej}"
  ls -la "$OUT"
} > "$OUT/SUMMARY.md"

echo
echo "Klart -> $OUT"
echo "Skicka hit: out/inventory/00-getprop.txt, 10-by-name.txt, 21-input.txt, 22-i2c.txt, 60-dmesg.txt"
echo "samt out/stock/boot.img (om den skapades)."
