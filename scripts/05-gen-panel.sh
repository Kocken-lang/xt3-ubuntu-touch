#!/usr/bin/env bash
# Generate a mainline DRM panel driver from the stock (downstream) DTB.
#   usage: 05-gen-panel.sh <vendor.dtb> [more.dtb ...]
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ $# -ge 1 ] || { echo "anvandning: $0 <vendor.dtb> [...]"; exit 1; }

LMD="$ROOT/.reference/linux-mdss-dsi-panel-driver-generator"
[ -d "$LMD" ] || { echo "kor 00-bootstrap.sh forst"; exit 1; }
PY="$ROOT/.venv/bin/python"
[ -x "$PY" ] || PY=python3

OUT="$ROOT/out/panel"
rm -rf "$OUT"; mkdir -p "$OUT"

for dtb in "$@"; do
  echo "==> $dtb"
  dts="${dtb%.dtb}.dts"
  [ -f "$dts" ] || dtc -I dtb -O dts -o "$dts" "$dtb" 2>/dev/null || true
  if ! grep -q "mdss_dsi" "$dts" 2>/dev/null; then
    echo "    hoppar: ingen mdss_dsi-nod"
    continue
  fi
  ( cd "$OUT" && "$PY" "$LMD/lmdpdg.py" "$dtb" 2>&1 | sed 's/^/    /' ) \
    || echo "    !! generatorn misslyckades"
done

echo
ls -l "$OUT" 2>/dev/null || true
cat <<'HINT'

Nasta steg (manuellt, 5 min):
 1. Flytta panel-*.c -> <karna>/drivers/gpu/drm/panel/ + Makefile/Kconfig
 2. Ta panel-*.dtsi-noden till dts/sdm660-janam-xt3.dts (&dsi0 -> panel@0)
 3. Kontrollera regulatorer/reset-gpio mot utdatan i out/panel/
HINT
