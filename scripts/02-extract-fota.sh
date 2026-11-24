#!/usr/bin/env bash
# Unpack a Janam/Point Mobile FOTA package.
#
# The 91.57 package is an Android A/B OTA zip:
#   META-INF/com/android/metadata   post-build=Janam/XT3/XT3:11/RKQ1.210924.001/R141
#   payload.bin                     1.44 GB update_engine payload
#   payload_properties.txt          FILE_HASH m.m.
#   care_map.pb, META-INF/com/android/otacert
#
# payload.bin is NOT carvable: partitions are stored as update_engine operations.
# Use payload-dumper-go (handles REPLACE_BZ/XZ and dynamic partitions).
#
#   usage: 02-extract-fota.sh <file.PFU>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PFU="${1:?anvandning: $0 <file.PFU>}"
[ -f "$PFU" ] || { echo "hittar inte $PFU"; exit 1; }

OUT="$ROOT/out/fota"
BIN="$ROOT/tools/payload-dumper-go"
mkdir -p "$OUT" "$ROOT/tools"

echo "==> 1/5 checksumma"
if [ -f "$PFU.md5" ]; then
  ( cd "$(dirname "$PFU")" && md5sum -c "$(basename "$PFU").md5" ) || {
    echo "!! MD5 stammer inte - avbryter"; exit 1; }
fi

echo "==> 2/5 format"
if ! head -c 2 "$PFU" | grep -q PK; then
  echo "    inte en zip - faller tillbaka pa carvern"
  python3 "$ROOT/scripts/03-carve.py" carve "$PFU" -o "$OUT/carved" | tee "$OUT/03-carve.log"
  exit 0
fi
unzip -o -q "$PFU" 'META-INF/com/android/metadata' 'payload_properties.txt' \
  'care_map.pb' -d "$OUT/meta" 2>/dev/null || true
echo "--- metadata"
sed 's/^/    /' "$OUT/meta/META-INF/com/android/metadata" 2>/dev/null || true
echo "--- payload_properties"
sed 's/^/    /' "$OUT/meta/payload_properties.txt" 2>/dev/null || true

echo "==> 3/5 payload-dumper-go"
if [ ! -x "$BIN" ]; then
  echo "    hamtar senaste release fran ssut/payload-dumper-go"
  url=$(curl -fsSL https://api.github.com/repos/ssut/payload-dumper-go/releases/latest \
        | grep -o 'https://[^"]*linux_amd64\.tar\.gz' | head -1)
  [ -n "$url" ] || { echo "!! kunde inte hitta release-URL"; exit 1; }
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/p.tar.gz" "$url"
  tar -xzf "$tmp/p.tar.gz" -C "$tmp"
  install -m755 "$(find "$tmp" -name payload-dumper-go -type f | head -1)" "$BIN"
  rm -rf "$tmp"
fi

mkdir -p "$OUT/partitions"
echo "    packar upp 1.4 GB (nagra minuter)..."
"$BIN" -o "$OUT/partitions" -c "$(nproc)" "$PFU" 2>&1 | tail -5

echo "==> 4/5 verifierar payload-hash"
# FILE_HASH galler payload.bin inuti zipen - inte hela .PFU-filen.
python3 - "$PFU" "$OUT/meta/META-INF/com/android/metadata" "$OUT/meta/payload_properties.txt" <<'PYV'
import base64, hashlib, os, re, sys
pfu, meta, props = sys.argv[1:4]
want = None
if os.path.exists(props):
    for line in open(props):
        if line.startswith("FILE_HASH="):
            want = line.split("=", 1)[1].strip()
if not want:
    print("    ingen FILE_HASH, hoppar over"); sys.exit(0)
off = ln = None
if os.path.exists(meta):
    txt = open(meta, errors="ignore").read()
    m = re.search(r"payload\.bin:(\d+):(\d+)", txt)
    if m:
        off, ln = int(m.group(1)), int(m.group(2))
if off is None:
    print("    hittar inte payload.bin i metadata, hoppar over"); sys.exit(0)
h = hashlib.sha256()
with open(pfu, "rb") as f:
    f.seek(off)
    left = ln
    while left > 0:
        b = f.read(min(8 << 20, left))
        if not b:
            break
        h.update(b); left -= len(b)
got = base64.b64encode(h.digest()).decode()
print(f"    {'OK' if got == want else 'MISSMATCH'}: payload.bin sha256 ({ln} byte)")
PYV

echo "==> 5/5 innehall"
{
  echo "# partitioner ur $(basename "$PFU")"
  for f in "$OUT"/partitions/*.img; do
    [ -e "$f" ] || continue
    printf "%-24s %12s  %s\n" "$(basename "$f")" \
      "$(stat -c%s "$f")" "$(file -b "$f" | cut -c1-58)"
  done
} | tee "$OUT/05-partitions.txt"

echo
echo "Klart -> $OUT/partitions"
echo "Nasta: ./scripts/04-unpack-boot.sh out/fota/partitions/boot.img"
echo "       ./scripts/11-collect-firmware.sh --from-image out/fota/partitions/vendor.img"
