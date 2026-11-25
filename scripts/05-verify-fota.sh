#!/usr/bin/env bash
# Verifierar 91.57-paketet led for led. Inga antaganden:
#  1. zip-integritet (CRC for alla poster)
#  2. payload.bin-regionens sha256 == FILE_HASH i payload_properties.txt
#  3. payload-manifestets partitionslista (payload-dumper-go -l)
#  4. varje uppackad image: storlek, filtyp, sha256 -> manifest
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PFU="${1:?ange PFU-fil}"
OUT="$ROOT/out/fota/verify"; mkdir -p "$OUT"
DUMPER="$ROOT/tools/payload-dumper-go"

echo "==> 1/4 zip-integritet"
unzip -t "$PFU" >"$OUT/zip-test.txt" 2>&1 && echo "   OK ($(grep -c 'testing:' "$OUT/zip-test.txt") poster)" || { echo "   FEL"; tail -5 "$OUT/zip-test.txt"; }

echo "==> 2/4 payload-regionens hash"
python3 - "$PFU" "$OUT" <<'PY'
import sys, zipfile, hashlib, base64, re
pfu, out = sys.argv[1:3]
z = zipfile.ZipFile(pfu)
meta = z.read("META-INF/com/android/metadata").decode()
props = z.read("payload_properties.txt").decode()
m = re.search(r"ota-property-files=([^\n]+)", meta).group(1)
region = [x for x in m.split(",") if x.startswith("payload.bin:")][0].split(":")
off, ln = int(region[1]), int(region[2])
fh = re.search(r"FILE_HASH=(\S+)", props).group(1)
with z.open("payload.bin") as f:
    f.seek(off); h = hashlib.sha256()
    left = ln
    while left:
        b = f.read(min(1 << 20, left))
        if not b: break
        h.update(b); left -= len(b)
got = base64.b64encode(h.digest()).decode()
print(f"   FILE_HASH  {fh}")
print(f"   beraknad   {got}")
print("   OK" if got == fh else "   MISSMATCH")
open(f"{out}/payload-hash.txt", "w").write(f"{fh}\n{got}\n{'OK' if got==fh else 'MISSMATCH'}\n")
PY

echo "==> 3/4 payload-manifest"
if [ ! -s /tmp/payload.bin ]; then
  echo "   packar ut payload.bin (1,4 GB)..."
  python3 - "$PFU" <<'PY'
import sys, zipfile, shutil
z = zipfile.ZipFile(sys.argv[1])
with z.open("payload.bin") as s, open("/tmp/payload.bin", "wb") as d:
    shutil.copyfileobj(s, d, 1 << 20)
PY
fi
"$DUMPER" -l /tmp/payload.bin > "$OUT/partitions.txt" 2>&1
echo "   $(grep -c . "$OUT/partitions.txt") rader i manifestet"

echo "==> 4/4 uppackade images"
: > "$OUT/images.sha256"
for f in "$ROOT"/out/fota/partitions/*.img; do
  [ -f "$f" ] || continue
  printf "%-16s %12s  %-22s " "$(basename "$f")" "$(stat -c%s "$f")" "$(head -c4 "$f" | tr -d '\0' | tr -c '[:print:]' '.')"
  sha256sum "$f" | awk '{print $1}' | tee -a "$OUT/images.sha256"
done
echo
echo "Klart -> $OUT"
