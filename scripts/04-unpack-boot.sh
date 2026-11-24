#!/usr/bin/env bash
# Packar upp Android boot.img (v0-v4), dtbo.img (DTBO-tabell) eller rå FDT.
# Sjalvstandig - kraver bara python3 och dtc, inga AOSP-skript.
#   usage: 04-unpack-boot.sh <boot.img|dtbo.img> [outdir]
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMG="${1:?anvandning: $0 <boot.img|dtbo.img> [outdir]}"
OUT="${2:-$ROOT/out/boot}"
mkdir -p "$OUT"
[ -f "$IMG" ] || { echo "hittar inte $IMG"; exit 1; }

python3 - "$IMG" "$OUT" <<'PY'
import os, struct, sys

img, out = sys.argv[1], sys.argv[2]
d = open(img, "rb").read()
os.makedirs(out, exist_ok=True)

def w(name, blob):
    p = os.path.join(out, name)
    open(p, "wb").write(blob)
    print(f"    {name:28} {len(blob):>10} byte")

def al(n, p):
    return (n + p - 1) // p * p

if d[:8] == b"ANDROID!":
    hver = struct.unpack_from("<I", d, 40)[0]
    if hver >= 3:
        ksz, rsz = struct.unpack_from("<II", d, 8)
        hsz = struct.unpack_from("<I", d, 20)[0]
        pg = 4096
        off = al(hsz, pg)
        print(f"    boot v{hver}: kernel={ksz} ramdisk={rsz}")
        w("kernel", d[off:off + ksz]); off = al(off + ksz, pg)
        w("ramdisk", d[off:off + rsz]); off = al(off + rsz, pg)
    else:
        # falten ligger inte i foljd: kernel@8, ramdisk@16, second@24
        u32 = lambda o: struct.unpack_from("<I", d, o)[0]
        ksz, rsz, ssz = u32(8), u32(16), u32(24)
        pg = u32(36) or 2048
        print(f"    boot v{hver}: page={pg} kernel={ksz} ramdisk={rsz} second={ssz}")
        off = pg
        w("kernel", d[off:off + ksz]); off = al(off + ksz, pg)
        w("ramdisk", d[off:off + rsz]); off = al(off + rsz, pg)
        if ssz:
            w("second", d[off:off + ssz]); off = al(off + ssz, pg)
        if hver >= 1:
            rdsz = struct.unpack_from("<I", d, 1632)[0]
            if rdsz:
                w("recovery_dtbo", d[off:off + rdsz]); off = al(off + rdsz, pg)
        if hver >= 2:
            dsz = struct.unpack_from("<I", d, 1648)[0]
            if dsz:
                w("dtb-from-boot", d[off:off + dsz])

elif struct.unpack_from("<I", d, 0)[0] == 0xD7B7AB1E:
    total, hsz, esz, cnt, eoff, pg = struct.unpack_from("<IIIIII", d, 4)
    print(f"    DTBO: {cnt} entries, entry={esz} byte, header={hsz}")
    os.makedirs(os.path.join(out, "dtb"), exist_ok=True)
    for i in range(cnt):
        sz, o, did, rev = struct.unpack_from("<IIII", d, eoff + i * esz)
        name = f"dtb/{i:02d}-id{did}-rev{rev}.dtb"
        w(name, d[o:o + sz])
elif d[:4] == b"\xd0\x0d\xfe\xed":
    os.makedirs(os.path.join(out, "dtb"), exist_ok=True)
    w("dtb/00-raw.dtb", d)
else:
    print(f"    okant format, forsta 8 byte: {d[:8]!r}")
    sys.exit(1)
PY
rc=$?
[ "$rc" -eq 0 ] || { echo "  !! kunde inte packa upp $IMG"; exit 1; }

if [ -d "$OUT/dtb" ]; then
  echo "==> avkompilerar devicetree"
  for f in "$OUT"/dtb/*.dtb; do
    [ -e "$f" ] || continue
    dtc -I dtb -O dts -o "${f%.dtb}.dts" "$f" 2>/dev/null || { echo "    ${f##*/}: dtc fel"; continue; }
    printf "    %-28s %s\n" "${f##*/}" "$(grep -m1 -o 'model = "[^"]*"' "${f%.dtb}.dts" | cut -d'"' -f2)"
    grep -m1 -o 'qcom,mdss-dsi-panel-name = "[^"]*"' "${f%.dtb}.dts" | sed 's/.*= /      panel: /' | tr -d '"'
  done
fi
echo "Klart -> $OUT"
