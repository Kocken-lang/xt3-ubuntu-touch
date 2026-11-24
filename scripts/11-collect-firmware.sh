#!/usr/bin/env bash
# Collect the proprietary firmware blobs that mainline needs.
#
#   usage: 11-collect-firmware.sh [--from-device]
#                                 [--from-image <img>]...
#                                 [--from-dir <dir>] [--inspect]
#
# On the XT3 the blobs are NOT in vendor.img.  /vendor/firmware_mnt is a
# mount point, so the files live in the separate modem/bluetooth/dsp
# partitions.  Those images are FAT or ext4 depending on the partition:
#
#   modemsda.img / modemsdm.img   FAT   mba.mbn, modem.*, adsp.*, ...
#   bluetooth.img                 FAT   crbtfw*, crbtnv*, btfm.bin
#   dsp.img                       ext4  adsp/cdsp firmware
#   vendor.img                    ext4  only HAL libraries, no firmware
#
# The script detects the filesystem instead of assuming ext4, and for ext4 it
# only dumps the firmware directories - never the whole image.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/out/firmware"
MODE="device"; IMAGES=(); INDIR=""; INSPECT=0

while [ $# -gt 0 ]; do
  case "$1" in
    --from-device) MODE="device"; shift ;;
    --from-image)  MODE="image"; IMAGES+=("$2"); shift 2 ;;
    --from-dir)    MODE="image"; INDIR="$2"; shift 2 ;;
    --inspect)     INSPECT=1; shift ;;
    *) echo "okant argument: $1"; exit 1 ;;
  esac
done

mkdir -p "$OUT"/{qcom,wlan,bt,adreno}
RAW="$OUT/raw"

fstype() {
  python3 - "$1" <<'PY'
import sys
b = open(sys.argv[1], "rb").read(4096)
if b[:4] == b"\x3a\xff\x26\xed":
    print("sparse")
elif b[:8] == b"ANDROID!":
    print("bootimg")
elif b[0x438:0x43a] == b"\x53\xef":
    print("ext")
elif b[54:57] == b"FAT" or b[82:87] == b"FAT32":
    print("fat")
elif b[257:262] == b"ustar":
    print("tar")
elif b[:2] == b"\x1f\x8b":
    print("gzip")
elif b[:6] == b"\xfd7zXZ\x00":
    print("xz")
elif b[:4] == b"\x28\xb5\x2f\xfd":
    print("zstd")
elif b[:4] == b"\xd7\xb7\xab\x1e":
    print("dtbo")
else:
    print("unknown")
PY
}

count_files() { find "$1" -type f 2>/dev/null | wc -l; }

extract_ext() {
  local img="$1" dst="$2"
  local dirs=(/image /firmware/image /firmware_mnt/image /vendor/firmware_mnt/image
              /etc/firmware /lib/firmware /vendor/firmware)
  local d before after
  for d in "${dirs[@]}"; do
    before=$(count_files "$dst")
    debugfs -R "rdump $d $dst" "$img" >/dev/null 2>&1
    after=$(count_files "$dst")
    if [ "$after" -gt "$before" ]; then
      echo "     $d: +$((after - before)) filer"
    fi
  done
  if [ "$(count_files "$dst")" -eq 0 ]; then
    echo "     inga kandade firmware-kataloger; toppniva i imagen:"
    debugfs -R "ls -l /" "$img" 2>/dev/null | sed 's/^/       /' | head -20
  fi
}

extract_fat() {
  local img="$1" dst="$2"
  if command -v 7z >/dev/null; then
    7z x -y -bd -o"$dst" "$img" >/dev/null 2>&1
  elif command -v mcopy >/dev/null; then
    MTOOLS_SKIP_CHECK=1 mcopy -s -i "$img" ::/ "$dst"/ 2>/dev/null
  else
    echo "     varken 7z eller mtools finns"; return 1
  fi
}

extract_one() {
  local img="$1"
  local base; base="$(basename "$img")"
  local dst="$RAW/${base%.img}"
  local t; t="$(fstype "$img")"
  echo "==> $base  ($t, $(du -h "$img" | cut -f1))"

  if [ "$INSPECT" = 1 ]; then
    case "$t" in
      ext)   debugfs -R "ls -l /" "$img" 2>/dev/null | sed 's/^/     /' | head -25 ;;
      fat)   7z l "$img" 2>/dev/null | sed -n '15,35p' | sed 's/^/     /' ;;
      tar)   tar -tf "$img" 2>/dev/null | head -25 | sed 's/^/     /' ;;
      *)     echo "     kan inte lista $t" ;;
    esac
    return 0
  fi

  rm -rf "$dst"; mkdir -p "$dst"
  case "$t" in
    ext)   extract_ext "$img" "$dst" ;;
    fat)   extract_fat "$img" "$dst" ;;
    tar)   tar -xf "$img" -C "$dst" 2>/dev/null ;;
    sparse)
      if command -v simg2img >/dev/null; then
        simg2img "$img" "$dst.raw" && extract_one "$dst.raw"
      else
        echo "     sparse image; install android-sdk-libsparse-utils"
      fi ;;
    *)     echo "     hoppar ($t)"; rm -rf "$dst" ;;
  esac
}

if [ "$MODE" = "device" ]; then
  echo "==> hamtar fran enheten"
  for d in /vendor/firmware_mnt/image /vendor/firmware /firmware/image /system/etc/firmware; do
    echo "   $d"
    adb pull "$d" "$RAW/device-$(echo "$d" | tr '/' '_')" >/dev/null 2>&1 || true
  done
else
  [ -n "$INDIR" ] && IMAGES+=("$INDIR"/*.img)
  [ ${#IMAGES[@]} -gt 0 ] || { echo "inga images angivna"; exit 1; }
  mkdir -p "$RAW"
  for img in "${IMAGES[@]}"; do
    [ -f "$img" ] || { echo "saknar $img"; continue; }
    extract_one "$img"
  done
fi

[ "$INSPECT" = 1 ] && exit 0

echo "==> sorterar in i /lib/firmware-struktur"
find "$RAW" -type f 2>/dev/null | while IFS= read -r f; do
  b="$(basename "$f")"
  case "$b" in
    crbtfw*|crbtnv*|btfm*|nvm*|*btslim*)           cp -f "$f" "$OUT/bt/$b" ;;
    wlan*|bdwlan*|WCNSS*|wlan_mac.bin|qca*)        cp -f "$f" "$OUT/wlan/$b" ;;
    a6xx*|a630*|a5xx*|*sqe.fw|*gmu.bin)            cp -f "$f" "$OUT/adreno/$b" ;;
    *.mbn|*.mdt|*.b0*|*.elf|*.jsn|*.tlv)           cp -f "$f" "$OUT/qcom/$b" ;;
  esac
done

cat > "$OUT/README.md" <<'EOF'
# Firmware for XT3 (mainline)

| Files | Consumer in mainline | Source partition |
|---|---|---|
| `qcom/mba.mbn`, `qcom/modem.mdt`, `qcom/modem.b0*` | `remoteproc_mss` (WWAN) | `modemsda.img` (SDA660 SKU) |
| `qcom/adsp.mdt`, `qcom/adsp.b0*` | `adsp_pil` (audio/sensors) | `modemsda.img` / `dsp.img` |
| `wlan/wlanmdsp.mbn`, `wlan/bdwlan*.bin` | `ath10k_snoc` (WCN3990 WiFi) | `modemsda.img` |
| `bt/crbtfw*.tlv`, `bt/crbtnv*.bin` | `btqca` (WCN3990 BT) | `bluetooth.img` |
| `adreno/a630_sqe.fw`, `adreno/a630_gmu.bin` | `msm`/freedreno (GPU) | `modemsda.img` / linux-firmware |
| `qcom/venus*.mbn` | `venus` (video) | `modemsda.img` |

Install into the rootfs:

    install -D -m644 qcom/*   /lib/firmware/qcom/
    install -D -m644 wlan/*   /lib/firmware/
    install -D -m644 bt/*     /lib/firmware/
    install -D -m644 adreno/* /lib/firmware/qcom/
EOF

echo
echo "==> resultat"
for d in qcom wlan bt adreno; do
  printf "  %-8s %3d filer\n" "$d" "$(find "$OUT/$d" -type f 2>/dev/null | wc -l)"
done
echo "  raw      $(du -sh "$RAW" 2>/dev/null | cut -f1)"
echo "Klart -> $OUT"
