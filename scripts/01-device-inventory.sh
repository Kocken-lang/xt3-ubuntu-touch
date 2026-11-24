#!/usr/bin/env bash
# Inventerar XT3 via adb. KOR SOM FIL, aldrig genom att klistra in i skalet:
#   ./scripts/01-device-inventory.sh
# Skriptet avbryter aldrig ditt terminalfonster och samlar sa mycket det kan
# aven om root saknas.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out/inventory"
mkdir -p "$OUT"

command -v adb >/dev/null || { echo "adb saknas: sudo apt install adb"; exit 0; }
adb start-server >/dev/null 2>&1

state() { adb devices | awk 'NR>1 && $2!="" {print $2}' | head -1; }
st="$(state)"
if [ "$st" != "device" ]; then
  echo "Enhetsstatus: ${st:-ingen enhet}"
  case "$st" in
    unauthorized) echo "-> Godkann USB-felsokningsdialogen pa enheten." ;;
    offline)      echo "-> Dra ur och i USB-kabeln." ;;
    "")           echo "-> Slå på USB-felsokning och anslut kabeln." ;;
  esac
  adb devices
  exit 0
fi

SU="nej"
if adb root >/dev/null 2>&1; then sleep 2; SU="ja"; fi
echo "adb root: $SU"
sh_() { adb shell "$@" 2>/dev/null; }
grab() { local f="$1"; shift; { echo "\$ $*"; sh_ "$@" 2>&1; } > "$OUT/$f" || true; }

echo "==> identitet"
grab 00-getprop.txt   getprop
grab 01-bootprops.txt 'getprop | grep -E "^\[ro\.(boot|product|vendor|hardware)"'
grab 02-cmdline.txt   cat /proc/cmdline
grab 03-uname.txt     uname -a
grab 05-soc.txt       'cat /sys/devices/soc0/machine /sys/devices/soc0/platform 2>/dev/null'
grab 06-slot.txt      'getprop ro.boot.slot_suffix; getprop ro.build.ab_update'

echo "==> partitioner"
grab 10-by-name.txt     'ls -l /dev/block/by-name/ 2>/dev/null || ls -l /dev/block/bootdevice/by-name/'
grab 11-partitions.txt  'cat /proc/partitions'
grab 12-block-sizes.txt 'for d in /dev/block/by-name/*; do printf "%s " "$d"; blockdev --getsize64 "$d"; done'

echo "==> display / touch / input"
grab 20-drm.txt   'for d in /sys/class/drm/*; do echo "$d: $(cat $d/status 2>/dev/null)"; done'
grab 21-input.txt 'cat /proc/bus/input/devices'
grab 22-i2c.txt   'for d in /sys/bus/i2c/devices/*; do echo "$(basename $d) $(cat $d/name 2>/dev/null)"; done'
grab 24-gpio.txt  'cat /sys/kernel/debug/gpio 2>/dev/null || ls /sys/class/gpio/ 2>/dev/null'
grab 25-tty.txt   'ls -l /dev/tty* 2>/dev/null | head -40'
grab 26-panel.txt 'dumpsys SurfaceFlinger 2>/dev/null | head -60'
grab 27-panel-dmesg 'dmesg 2>/dev/null | grep -iE "panel|dsi|touch|goodix|focal|novatek|synaptics|hx83|ili" | head -40'

echo "==> power / clocks / termik"
grab 30-thermal.txt 'for z in /sys/class/thermal/thermal_zone*; do echo "$(basename $z) $(cat $z/type) $(cat $z/temp)"; done'
grab 31-cpufreq.txt 'for c in /sys/devices/system/cpu/cpu*/cpufreq; do echo "$c"; cat $c/scaling_available_frequencies $c/scaling_governor 2>/dev/null; done'
grab 32-devfreq.txt 'ls /sys/class/devfreq/ 2>/dev/null'
grab 33-battery.txt 'dumpsys battery 2>/dev/null | head -30'

echo "==> radio / wifi"
grab 40-modem.txt   'ls -l /dev/subsys_* /dev/rmnet* 2>/dev/null; getprop | grep -iE "radio|modem|baseband" | head -20'
grab 41-wifi-bt.txt 'getprop | grep -iE "wifi|bluetooth" | head -20; ls /sys/class/ieee80211 2>/dev/null'

echo "==> enterprise (skanner/RFID/SAM/MSR)"
grab 50-vendor-services.txt 'service list 2>/dev/null | grep -iE "device|scanner|serial|rfid|sam|msr|spi|gpio|hijack"'
grab 51-vendor-libs.txt     'ls -l /vendor/lib64/ 2>/dev/null | grep -iE "device|scanner|serial|rfid|sam|msr|gpio" | head -30'
grab 52-ttyhsl.txt          'ls -l /dev/ttyHSL* /dev/ttyMSM* 2>/dev/null; cat /proc/tty/drivers 2>/dev/null'
grab 53-firmware.txt        'ls /vendor/firmware_mnt/image 2>/dev/null | head -40'

echo "==> kernel logg"
grab 60-dmesg.txt dmesg

echo "==> device tree"
if [ "$SU" = "ja" ]; then
  adb shell 'tar -cf /data/local/tmp/dt.tar -C /proc device-tree' 2>/dev/null
  adb pull /data/local/tmp/dt.tar "$OUT/70-device-tree.tar" >/dev/null 2>&1
  adb shell 'rm -f /data/local/tmp/dt.tar' 2>/dev/null
  mkdir -p "$OUT/70-device-tree"
  tar -xf "$OUT/70-device-tree.tar" -C "$OUT/70-device-tree" 2>/dev/null
fi

echo "==> boot + dtbo (A/B-medvetet)"
mkdir -p "$ROOT/out/stock"
for p in boot_a boot_b dtbo_a dtbo_b boot dtbo; do
  if adb shell "test -e /dev/block/by-name/$p" 2>/dev/null; then
    echo "   $p ..."
    adb shell "dd if=/dev/block/by-name/$p of=/data/local/tmp/$p.img bs=4M" 2>/dev/null
    adb pull "/data/local/tmp/$p.img" "$ROOT/out/stock/$p.img" >/dev/null 2>&1
    adb shell "rm -f /data/local/tmp/$p.img" 2>/dev/null
  fi
done

{
  echo "# Inventering $(date -Is)"
  echo "adb root: $SU"
  echo
  echo "## Filer"
  ls -l "$OUT" | tail -n +2
  echo
  echo "## Dumpade partitioner"
  ls -l "$ROOT/out/stock" 2>/dev/null | tail -n +2
} > "$OUT/SUMMARY.md"

echo
echo "Klart -> $OUT"
ls -l "$ROOT/out/stock" 2>/dev/null
