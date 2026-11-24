#!/usr/bin/env bash
# Assemble the installable release artifact.
#
#   make release            -> out/xt3-ut-<version>.zip
#
# The zip contains everything the end user needs, with no editing:
#   boot.img  rootfs.img  install.sh  README.txt  SHA256SUMS  manifest.json
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION="${VERSION:-$(date +%Y%m%d)-$(git rev-parse --short HEAD 2>/dev/null || echo dev)}"
NAME="xt3-ut-$VERSION"
REL="$ROOT/out/release/$NAME"
mkdir -p "$REL"

need() { [ -f "$1" ] || { echo "saknar $1 - kor byggstegen forst"; exit 1; }; }
need out/boot.img
need out/rootfs.img

echo "==> samlar $NAME"
install -m644 out/boot.img "$REL/boot.img"
install -m644 out/rootfs.img "$REL/rootfs.img"
install -m755 scripts/install.sh "$REL/install.sh"

KREL=$(make -s -C out/src/linux kernelrelease 2>/dev/null || echo unknown)
KVER=$(git -C out/src/linux describe --always --tags 2>/dev/null || echo unknown)
cat > "$REL/manifest.json" <<EOF
{
  "product": "Janam XT3",
  "soc": "Qualcomm SDM660",
  "userspace": "Ubuntu Touch (Lomiri) on mainline DRM/Mesa",
  "kernel": "$KREL",
  "kernel_source": "sdm660-mainline/linux $KVER",
  "base_firmware": "Janam 91.57 (a11/XT3/91.57_20251001.PFU)",
  "built": "$(date -Is)",
  "commit": "$(git rev-parse HEAD 2>/dev/null || echo unknown)",
  "channel": "${CHANNEL:-bringup}"
}
EOF

cat > "$REL/README.txt" <<EOF
Janam XT3 - Ubuntu Touch ($NAME)
================================

Installation (ingen redigering kravs):

  1. Stall enheten i fastboot:  hall Vol- och Power, slapp vid vibration
  2. Anslut USB
  3. Kor:   ./install.sh

For att aterstalla original Android 11 (91.57): flasha om
  ~/janam_fota/a11/XT3/91.57_20251001.PFU med Janams uppdateringsverktyg.

Kanal: ${CHANNEL:-bringup}
Karna: $KREL
EOF

echo "==> checksummor"
( cd "$REL" && sha256sum boot.img rootfs.img install.sh manifest.json > SHA256SUMS )

echo "==> zippar"
ZIP="$ROOT/out/$NAME.zip"
rm -f "$ZIP"
( cd "$REL/.." && zip -q -r "$ZIP" "$NAME" )

echo
ls -lh "$ZIP"
echo "Klart -> $ZIP"
echo "Publicera: gh release create $VERSION \"$ZIP\" --title \"XT3 Ubuntu Touch $VERSION\""
