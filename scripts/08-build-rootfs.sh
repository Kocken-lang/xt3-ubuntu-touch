#!/usr/bin/env bash
# Build the Ubuntu Touch rootfs image for the XT3 (arm64, ext4 in a file).
#
#   usage: 08-build-rootfs.sh [--size 6G] [--tarball <ut-arm64-rootfs.tar.gz>]
#
# Get the tarball from https://cdimage.ubports.com/ubports-touch/ (arm64, focal).
# A mainline (non-Halium) rootfs needs manual glue; this script does the mechanical
# part and leaves a device hook directory at out/rootfs-overlay/.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIZE="6G"; TARBALL=""
while [ $# -gt 0 ]; do
  case "$1" in
    --size) SIZE="$2"; shift 2 ;;
    --tarball) TARBALL="$2"; shift 2 ;;
    *) echo "okant argument: $1"; exit 1 ;;
  esac
done
TARBALL="${TARBALL:-$ROOT/out/src/ubports-touch-arm64-rootfs.tar.gz}"
IMG="$ROOT/out/rootfs.img"
MNT="$ROOT/out/rootfs"
OVERLAY="$ROOT/out/rootfs-overlay"

[ -f "$TARBALL" ] || {
  cat <<EOF
Saknar rootfs-tarball: $TARBALL

Ladda ner en arm64 Ubuntu Touch rootfs, t.ex.:
  curl -L -o "$TARBALL" <url-fran https://cdimage.ubports.com/ubports-touch/>
EOF
  exit 1
}

echo "==> skapar $IMG ($SIZE)"
rm -f "$IMG"; truncate -s "$SIZE" "$IMG"
mkfs.ext4 -q -F -L ut-rootfs "$IMG"

mkdir -p "$MNT"
sudo mount -o loop "$IMG" "$MNT"
trap 'sudo umount "$MNT" || true' EXIT

echo "==> packar upp rootfs"
sudo tar -xpf "$TARBALL" -C "$MNT" --numeric-owner

echo "==> karnmoduler"
if [ -d "$ROOT/out/kbuild" ]; then
  sudo make -C "$ROOT/out/src/linux" O="$ROOT/out/kbuild" \
    INSTALL_MOD_PATH="$MNT" modules_install >/dev/null
  KREL=$(make -s -C "$ROOT/out/src/linux" kernelrelease)
  echo "    $KREL -> /lib/modules/$KREL"
else
  echo "    hoppar (bygg karnan forst: 07-build-kernel.sh)"
fi

echo "==> enhetsglue (overlay)"
if [ -d "$OVERLAY" ]; then
  sudo cp -a "$OVERLAY/." "$MNT/"
  echo "    kopierade $(find "$OVERLAY" -type f | wc -l) filer"
else
  echo "    ingen overlay - skapa out/rootfs-overlay/ vid behov"
fi

echo "==> fstab / boot-parametrar"
sudo tee "$MNT/etc/fstab" >/dev/null <<'EOF'
LABEL=ut-rootfs  /  ext4  defaults,noatime  0 1
EOF

sudo umount "$MNT"
trap - EXIT
ls -lh "$IMG"
echo "Klart -> $IMG"
