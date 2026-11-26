#!/usr/bin/env bash
# Oversatter var packares flaggor till AOSP:s mkbootimg.py
set -euo pipefail
AOSP="${AOSP_MKBOOTIMG:-$HOME/xt3/tools/aosp/mkbootimg/mkbootimg.py}"
OUT=""; OSV=""; PAD=""; ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --output) OUT="$2"; shift 2;;
    --os_version) OSV="$2"; shift 2;;
    --pad_to) PAD="$2"; shift 2;;
    *) ARGS+=("$1"); shift;;
  esac
done
OSSTR=$(python3 -c "f=int(str($OSV),0); v=f>>11; print(f\"{(v>>14)&0x7f}.{(v>>7)&0x7f}.{v&0x7f}\")")
PATCH=$(python3 -c "f=int(str($OSV),0); p=f&0x7ff; print(f\"{2000+(p>>4):04d}-{p&0x0f:02d}\")")
python3 "$AOSP" "${ARGS[@]}" --os_version "$OSSTR" --os_patch_level "$PATCH" -o "$OUT"
if [ -n "$PAD" ]; then truncate -s "$PAD" "$OUT"; fi
echo "    AOSP mkbootimg: os_version=$OSSTR patch=$PATCH"
