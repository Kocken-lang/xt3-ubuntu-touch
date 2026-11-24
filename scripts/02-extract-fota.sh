#!/usr/bin/env bash
# Unpack a Janam/Point Mobile PFU update container and classify what came out.
#   usage: 02-extract-fota.sh <file.PFU>
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PFU="${1:?användning: $0 <file.PFU>}"
[ -f "$PFU" ] || { echo "hittar inte $PFU"; exit 1; }

OUT="$ROOT/out/fota"
mkdir -p "$OUT"

echo "==> 1/4 checksumma"
if [ -f "$PFU.md5" ]; then
  ( cd "$(dirname "$PFU")" && md5sum -c "$(basename "$PFU").md5" ) || {
    echo "!! MD5 stämmer inte – avbryter"; exit 1; }
else
  echo "   ingen .md5 fil, hoppar över"
fi

echo "==> 2/4 formatdiagnostik"
{
  echo "# $PFU  $(stat -c%s "$PFU") byte"
  xxd -l 4096 "$PFU"
} > "$OUT/00-header.txt"
head -c 16M "$PFU" | strings -n 8 -t d > "$OUT/01-strings-head.txt" || true
file "$PFU" > "$OUT/02-file.txt" || true
head -40 "$OUT/00-header.txt"
echo "   -> $OUT/00-header.txt, 01-strings-head.txt"

echo "==> 3/4 carving"
python3 "$ROOT/scripts/03-carve.py" carve "$PFU" -o "$OUT/carved" | tee "$OUT/03-carve.log"

echo "==> 4/4 klassificering"
mkdir -p "$OUT/raw"
for f in "$OUT"/carved/*.img "$OUT"/carved/*.bin; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  echo "--- $base"
  file "$f"
  case "$base" in
    *_android_sparse.img)
      out="$OUT/raw/${base%_android_sparse.img}.raw"
      simg2img "$f" "$out" && echo "    -> $out ($(stat -c%s "$out") byte)" ;;
    *_ext4.img)
      cp -f "$f" "$OUT/raw/${base%_ext4.img}.ext4"
      7z l "$OUT/raw/${base%_ext4.img}.ext4" > "$OUT/raw/${base%_ext4.img}.listing.txt" 2>&1 || true
      head -25 "$OUT/raw/${base%_ext4.img}.listing.txt" | sed 's/^/    /' ;;
    *_android_boot.img)
      cp -f "$f" "$OUT/raw/${base%_android_boot.img}.boot.img"
      "$ROOT/scripts/04-unpack-boot.sh" "$OUT/raw/${base%_android_boot.img}.boot.img" || true ;;
    *_super_lp.img)
      python3 "$ROOT/scripts/03-carve.py" lpunpack "$f" -o "$OUT/super" || true ;;
  esac
done

echo
echo "Klart -> $OUT"
[ -s "$OUT/03-carve.log" ] || echo "Inga magics hittades: se 00-header.txt/01-strings-head.txt."
