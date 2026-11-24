#!/usr/bin/env bash
# Collect the proprietary firmware blobs the mainline kernel needs, from the device
# (preferred, it is rooted) or from a carved vendor image.
#
#   usage: 11-collect-firmware.sh [--from-device|--from-image <vendor.ext4>]
#
# Firmware is NOT an "Android blob" in the HAL sense - it is the signed firmware that
# Qualcomm's own hardware requires. Every mainline SDM660 device needs these files.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out/firmware"
MODE="device"; IMAGE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --from-device) MODE="device"; shift ;;
    --from-image) MODE="image"; IMAGE="$2"; shift 2 ;;
    *) echo "okant argument: $1"; exit 1 ;;
  esac
done

mkdir -p "$OUT"/{qcom,wlan,adreno}

if [ "$MODE" = "device" ]; then
  echo "==> hamtar fran enheten"
  for d in /vendor/firmware /vendor/firmware_mnt/image /firmware/image /system/etc/firmware; do
    echo "   $d"
    adb pull "$d" "$OUT/device-$(echo "$d" | tr '/' '_')" >/dev/null 2>&1 || true
  done
else
  [ -f "$IMAGE" ] || { echo "saknar $IMAGE"; exit 1; }
  echo "==> packar upp firmware ur $IMAGE"
  rm -rf "$OUT/from-image"; mkdir -p "$OUT/from-image"
  command -v debugfs >/dev/null || { echo "  debugfs saknas (apt install e2fsprogs)"; exit 1; }
  for d in /firmware_mnt/image /firmware/image /etc/firmware; do
    before=$(find "$OUT/from-image" -type f 2>/dev/null | wc -l)
    debugfs -R "rdump $d $OUT/from-image" "$IMAGE" >/dev/null 2>&1 || true
    after=$(find "$OUT/from-image" -type f 2>/dev/null | wc -l)
    [ "$after" -gt "$before" ] && echo "   $d: +$((after - before)) filer"
  done
  n=$(find "$OUT/from-image" -type f 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] || { echo "  inga filer ur $IMAGE"; exit 1; }
  echo "   totalt $n filer"
fi

echo "==> sorterar in i /lib/firmware-struktur"
find "$OUT" -type f \( -name '*.mbn' -o -name '*.mdt' -o -name '*.b0*' \
  -o -name '*.bin' -o -name '*.tlv' -o -name '*.fw' -o -name '*.jsn' \) \
  -not -path "$OUT/qcom/*" -not -path "$OUT/wlan/*" -not -path "$OUT/adreno/*" \
  -print0 2>/dev/null | while IFS= read -r -d '' f; do
    b="$(basename "$f")"
    case "$b" in
      wlan*|bdwlan*|crbtfw*|crbtnv*) cp -n "$f" "$OUT/wlan/$b" ;;
      a6xx*|a630*) cp -n "$f" "$OUT/adreno/$b" ;;
      *) cp -n "$f" "$OUT/qcom/$b" ;;
    esac
  done

cat > "$OUT/README.md" <<'EOF'
# Firmware för XT3 (mainline)

| Fil(er) | Konsument i mainline | Källa |
|---|---|---|
| `mba.mbn`, `modem.mdt`, `modem.b0*` | `remoteproc_mss` (WWAN) | `/vendor/firmware_mnt/image` |
| `adsp.mdt`, `adsp.b0*` | `adsp_pil` (audio/sensors) | samma |
| `wlanmdsp.mbn`, `bdwlan*.bin` | `ath10k_snoc` (WCN3990 WiFi) | samma |
| `crbtfw*.tlv`, `crbtnv*.bin` | BT (WCN3990) | samma |
| `a630_sqe.fw`, `a630_gmu.bin` | `msm`/freedreno (GPU) | `firmware-qcom-adreno` (linux-firmware) |
| `venus*.mbn` | `venus` (video) | `/vendor/firmware` |

Installation i rootfs:
    install -D -m644 qcom/*  /lib/firmware/qcom/
    install -D -m644 wlan/*  /lib/firmware/
    install -D -m644 adreno/* /lib/firmware/qcom/
EOF

echo
echo "==> resultat"
find "$OUT" -type f -not -name README.md | sed "s|$OUT/||" | sort | head -40
echo "..."
echo "Totalt: $(find "$OUT" -type f -not -name README.md | wc -l) filer, $(du -sh "$OUT" | cut -f1)"
echo "Klart -> $OUT"
