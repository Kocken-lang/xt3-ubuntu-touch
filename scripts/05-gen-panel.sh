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
INSTALL=1
XT3_PANEL="jd9365da 720p video mode dsi panel"

while [ $# -gt 0 ]; do
  case "$1" in
    --panel)     PANEL="$2"; shift 2 ;;
    --no-install) INSTALL=0; shift ;;
    *) SRC="$1"; shift ;;
  esac
done

[ -n "${SRC:-}" ] || { echo "anvandning: $0 <dtb|dts> [--panel <nod>]"; exit 1; }

echo "==> paneler i $SRC"
"$GEN" --dtb "$SRC" --list

rm -rf "$OUT"; mkdir -p "$OUT"
echo "==> genererar"
if [ -z "$PANEL" ] && "$GEN" --dtb "$SRC" --list | grep -qF "$XT3_PANEL"; then
  PANEL="$XT3_PANEL"
  echo "==> valjer XT3-panelen: $PANEL"
fi

if [ -n "$PANEL" ]; then
  "$GEN" --dtb "$SRC" --name xt3 --outdir "$OUT" --panel "$PANEL"
else
  "$GEN" --dtb "$SRC" --name xt3 --outdir "$OUT"
fi

if [ "$INSTALL" = 1 ]; then
  cp "$OUT/panel-xt3.c"    "$ROOT/panel/panel-janam-xt3.c"
  cp "$OUT/panel-xt3.dtsi" "$ROOT/dts/panel-janam-xt3.dtsi"
  echo "==> panel/panel-janam-xt3.c och dts/panel-janam-xt3.dtsi uppdaterade"
  echo "    kom ihag att avkommentera #include i dts/sdm660-janam-xt3.dts"
else
  cat <<HINT

Nasta steg:
  cp $OUT/panel-xt3.c      panel/panel-janam-xt3.c
  cp $OUT/panel-xt3.dtsi   dts/panel-janam-xt3.dtsi
HINT
fi

echo "bygg om karnan: make kernel"
