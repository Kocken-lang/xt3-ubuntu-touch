#!/usr/bin/env bash
# Generate the mainline DRM panel driver from a stock (downstream) DTB.
#
#   usage: 05-gen-panel.sh <dtb|dts> [--panel <nod>]
#
# The stock boot.img DTB is the best source: it contains every panel variant
# with its full init sequence.  dtbo.img only contains the backlight overlay.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="$ROOT/scripts/13-panel-from-dtb.py"
OUT="$ROOT/out/panel"
PANEL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --panel) PANEL="$2"; shift 2 ;;
    *) SRC="$1"; shift ;;
  esac
done

[ -n "${SRC:-}" ] || { echo "anvandning: $0 <dtb|dts> [--panel <nod>]"; exit 1; }

echo "==> paneler i $SRC"
"$GEN" --dtb "$SRC" --list

rm -rf "$OUT"; mkdir -p "$OUT"
echo "==> genererar"
if [ -n "$PANEL" ]; then
  "$GEN" --dtb "$SRC" --name xt3 --outdir "$OUT" --panel "$PANEL"
else
  "$GEN" --dtb "$SRC" --name xt3 --outdir "$OUT"
fi

cat <<HINT

Nasta steg:
  cp $OUT/panel-xt3.c      panel/panel-janam-xt3.c
  cp $OUT/panel-xt3.dtsi   dts/panel-janam-xt3.dtsi
  git add panel/panel-janam-xt3.c dts/panel-janam-xt3.dtsi

Bygg sedan om karnan: make kernel
HINT
