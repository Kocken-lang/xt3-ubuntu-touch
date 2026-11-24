#!/usr/bin/env bash
# Build the Ubuntu Touch rootfs image for the XT3 (arm64, ext4 in a file).
#
#   usage: 08-build-rootfs.sh [--size 6G] [--tarball <ut-arm64-rootfs.tar.gz>]
#
# Tarballen byggs av 18-bootstrap-rootfs.sh (debootstrap noble/arm64 + Lomiri).
# Hittas automatiskt i out/src/.  Enhetsglue lases fran out/rootfs-overlay/.
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
if [ -z "${TARBALL:-}" ]; then
  for c in "$ROOT"/out/src/xt3-lomiri-*.tar.gz \
           "$ROOT/out/src/ubports-touch-arm64-rootfs.tar.gz"; do
    [ -f "$c" ] && TARBALL="$c" && break
  done
fi
TARBALL="${TARBALL:-}"
IMG="$ROOT/out/rootfs.img"
MNT="$ROOT/out/rootfs"
OVERLAY="$ROOT/out/rootfs-overlay"

[ -f "$TARBALL" ] || {
  cat <<EOF
Saknar rootfs-tarball: ${TARBALL:-<ingen>}

Bygg en med Lomiri ur Ubuntu-arkivet (rekommenderas, se docs/04-rootfs.md):
  make rootfs-bootstrap
Da hamnar den i out/src/xt3-lomiri-noble-arm64.tar.gz och hittas automatiskt.
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
KB="$ROOT/out/kbuild"
KSRC="$ROOT/out/src/linux"
KARCH=(ARCH=arm64 CROSS_COMPILE="${CROSS_COMPILE:-aarch64-linux-gnu-}")
KREL=""
if [ -f "$KB/.config" ]; then
  KREL=$(make -s -C "$KSRC" O="$KB" "${KARCH[@]}" kernelrelease 2>/dev/null || true)
  sudo make -C "$KSRC" O="$KB" "${KARCH[@]}" \
    INSTALL_MOD_PATH="$MNT" INSTALL_MOD_STRIP=--strip-debug \
    modules_install >/dev/null 2>&1 || true
  n=$(find "$MNT/lib/modules/$KREL" -name '*.ko' 2>/dev/null | wc -l)
  if [ "$n" -eq 0 ]; then
    # Samma fallback som 07: kopiera for hand om kbuild inte installerar.
    dest="$MNT/lib/modules/$KREL"
    while IFS= read -r ko; do
      sudo install -D -m644 "$ko" "$dest/kernel/${ko#"$KB"/}"
    done < <(find "$KB" -name '*.ko')
    sudo depmod -b "$MNT" "$KREL" 2>/dev/null || true
    n=$(find "$dest" -name '*.ko' 2>/dev/null | wc -l)
  fi
  echo "    $KREL -> /lib/modules/$KREL ($n moduler)"
  [ "$n" -gt 0 ] || echo "    VARNING: inga .ko installerade - kor make kernel igen"
else
  echo "    hoppar (bygg karnan forst: make kernel)"
fi

echo "==> enhetsglue (overlay)"
if [ -d "$OVERLAY" ]; then
  sudo cp -a "$OVERLAY/." "$MNT/"
  echo "    kopierade $(find "$OVERLAY" -type f | wc -l) filer"
else
  echo "    ingen overlay - skapa out/rootfs-overlay/ vid behov"
fi

echo "==> firmware"
if [ -d "$ROOT/out/firmware" ]; then
  "$ROOT/scripts/17-install-firmware.sh" "$MNT" | sed 's/^/    /'
else
  echo "    hoppar (kor make firmware forst)"
fi

echo "==> initramfs"
if [ -n "$KREL" ] && [ -x "$MNT/usr/sbin/update-initramfs" ]; then
  for d in proc sys dev; do
    sudo mountpoint -q "$MNT/$d" || sudo mount --bind "/$d" "$MNT/$d"
  done
  # XT3:s boot-partition ar 64 MB. Standard (MODULES=most) stoppar in alla
  # 767 moduler i initramfs och ger 60 MB - da far kernel+dtb inte plats.
  # MODULES=dep tar bara det som behovs for att na rotfilsystemet.
  sudo mkdir -p "$MNT/etc/initramfs-tools"
  printf 'MODULES=dep\nCOMPRESS=gzip\nBUSYBOX=auto\n' \
    | sudo tee "$MNT/etc/initramfs-tools/initramfs.conf" >/dev/null
  # MODULES=dep harleder drivrutiner ur /etc/fstab, dar roten star som
  # LABEL=ut-rootfs. Etiketten gar inte att sla upp vid byggtid, sa listan
  # kan bli tom - och da hittar initramfs aldrig disken. Namnge lagret
  # explicit i stallet. Saknade moduler ger bara en varning.
  printf 'mmc_block\nsdhci\nsdhci_msm\next4\n' \
    | sudo tee "$MNT/etc/initramfs-tools/modules" >/dev/null
  if sudo chroot "$MNT" /usr/bin/env DEBIAN_FRONTEND=noninteractive \
       update-initramfs -c -k "$KREL" >/tmp/xt3-initramfs.log 2>&1; then
    sudo cp "$MNT/boot/initrd.img-$KREL" "$ROOT/out/initramfs.img"
    echo "    out/initramfs.img ($(du -h "$ROOT/out/initramfs.img" | cut -f1))"
  else
    echo "    FEL: update-initramfs misslyckades, se /tmp/xt3-initramfs.log"
    tail -5 /tmp/xt3-initramfs.log | sed 's/^/      /'
  fi
  for d in dev sys proc; do sudo umount "$MNT/$d" 2>/dev/null || true; done
else
  echo "    hoppar (saknar initramfs-tools i rootfs - kor make rootfs-bootstrap)"
fi

echo "==> fstab / boot-parametrar"
sudo tee "$MNT/etc/fstab" >/dev/null <<'EOF'
LABEL=ut-rootfs  /  ext4  defaults,noatime  0 1
EOF

sudo umount "$MNT"
trap - EXIT
ls -lh "$IMG"
echo "Klart -> $IMG"
