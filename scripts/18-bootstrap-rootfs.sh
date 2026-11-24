#!/usr/bin/env bash
# Build an arm64 rootfs with the Lomiri shell from the official Ubuntu archive.
#
#   sudo ./scripts/18-bootstrap-rootfs.sh                 # hela vagen
#   sudo ./scripts/18-bootstrap-rootfs.sh --simulate      # los bara beroendena
#
# Varför inte UBports system-image: deras rotfiler byggs per enhet i CI och
# publiceras inte som en generisk arm64-tarball.  Lomiri-paketen ligger i
# Ubuntu universe (Debian UBports Team är maintainer), och en apt-managed
# rootfs är det som gör porten framtidssäker: apt full-upgrade i stället för
# att vänta på att någon bygger om en bild.
#
# Kräver: debootstrap, qemu-user-static, binfmt-support (installeras av 00).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SUITE="${SUITE:-noble}"
MIRROR="${MIRROR:-http://ports.ubuntu.com/ubuntu-ports}"
ARCH=arm64
WORK="${WORK:-$ROOT/out/rootfs-build}"
TARBALL="${TARBALL:-$ROOT/out/src/xt3-lomiri-$SUITE-$ARCH.tar.gz}"
SIMULATE=0
[ "${1:-}" = "--simulate" ] && SIMULATE=1

[ "$(id -u)" = 0 ] || { echo "kor med sudo"; exit 1; }
command -v debootstrap >/dev/null || { echo "saknar debootstrap (kor make bootstrap)"; exit 1; }
have_binfmt() { [ -e /proc/sys/fs/binfmt_misc/qemu-aarch64 ]; }
if ! have_binfmt && ! command -v qemu-aarch64-static >/dev/null; then
  echo "saknar qemu for arm64: installera qemu-user-binfmt och kor"
  echo "  sudo update-binfmts --enable qemu-aarch64"
  exit 1
fi

mounts=()
cleanup() {
  for m in "${mounts[@]}"; do umount "$m" 2>/dev/null || true; done
}
trap cleanup EXIT

echo "==> 1/4 debootstrap $SUITE/$ARCH"
mkdir -p "$WORK" "$(dirname "$TARBALL")"
if [ ! -x "$WORK/rootfs/debootstrap/debootstrap" ] && [ ! -f "$WORK/rootfs/etc/os-release" ]; then
  debootstrap --arch="$ARCH" --foreign --variant=minbase \
    --components=main,universe "$SUITE" "$WORK/rootfs" "$MIRROR"
fi
if [ -x /usr/bin/qemu-aarch64-static ]; then
  install -m755 /usr/bin/qemu-aarch64-static "$WORK/rootfs/usr/bin/"
fi

echo "==> 2/4 andra steget under qemu"
for d in proc sys dev dev/pts; do
  mkdir -p "$WORK/rootfs/$d"
  mount --bind "/$d" "$WORK/rootfs/$d"
  mounts=("$WORK/rootfs/$d" "${mounts[@]}")
done
if [ -x "$WORK/rootfs/debootstrap/debootstrap" ]; then
  if have_binfmt; then
    chroot "$WORK/rootfs" /debootstrap/debootstrap --second-stage
  elif [ -x "$WORK/rootfs/usr/bin/qemu-aarch64-static" ]; then
    echo "    binfmt saknas - kor andra steget via qemu direkt"
    chroot "$WORK/rootfs" /usr/bin/qemu-aarch64-static \
      /debootstrap/debootstrap --second-stage
    echo "    varning: apt nedanfor kraver binfmt for underprocesser"
  fi
fi

echo "==> 3/4 apt-kallor och paket"
cat > "$WORK/rootfs/etc/apt/sources.list" <<EOF
deb $MIRROR $SUITE main universe
deb $MIRROR $SUITE-updates main universe
deb $MIRROR $SUITE-security main universe
EOF
echo "xt3" > "$WORK/rootfs/etc/hostname"
cat > "$WORK/rootfs/etc/apt/apt.conf.d/99xt3" <<'EOF'
APT::Install-Recommends "true";
APT::Get::Assume-Yes "true";
Dpkg::Options { "--force-confdef"; "--force-confold"; };
EOF

# Lomiri + det som en handhållen enhet behöver för att vara användbar direkt.
PKGS=(
  lomiri
  lomiri-desktop-session
  lomiri-system-settings
  lomiri-greeter
  lomiri-url-dispatcher
  lomiri-calculator-app
  lomiri-clock-app
  lomiri-filemanager-app
  lomiri-gallery-app
  lomiri-mediaplayer-app
  lomiri-music-app
  lomiri-docviewer-app
  maliit-keyboard
  ubuntu-standard
  network-manager
  wpasupplicant
  openssh-server
  sudo
  systemd-sysv
  dbus
  bluez
  alsa-utils
  curl
  ca-certificates
)

if [ "$SIMULATE" = 1 ]; then
  echo "==> 4/4 simulerar (inget installeras)"
  chroot "$WORK/rootfs" apt-get update
  chroot "$WORK/rootfs" apt-get -s install "${PKGS[@]}" \
    | tail -25
  echo
  echo "Simuleringen visar att paketmassan gar att losa."
  echo "Kor utan --simulate for att bygga klart och packa $TARBALL"
  exit 0
fi

echo "==> 4/4 installerar (tar en stund)"
chroot "$WORK/rootfs" apt-get update
chroot "$WORK/rootfs" apt-get install "${PKGS[@]}"

# Forsta boots-debugg over USB: konsol pa ttyGS0 och ssh over usb0.
chroot "$WORK/rootfs" systemctl enable ssh 2>/dev/null || true
mkdir -p "$WORK/rootfs/etc/systemd/system/serial-getty@ttyGS0.service.d"
cat > "$WORK/rootfs/etc/systemd/system/serial-getty@ttyGS0.service.d/override.conf" <<'EOF' 
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -- \\u' --keep-baud 115200,38400,9600 ttyGS0 $TERM
EOF

rm -f "$WORK/rootfs/usr/bin/qemu-aarch64-static"
umount "$WORK/rootfs/dev/pts" "$WORK/rootfs/dev" "$WORK/rootfs/sys" "$WORK/rootfs/proc" 2>/dev/null || true
mounts=()

echo "==> packar $TARBALL"
tar -C "$WORK/rootfs" --numeric-owner --xattrs -czf "$TARBALL" .
ls -lh "$TARBALL"
echo
echo "Nasta steg:"
echo "  make rootfs TARBALL=$TARBALL"
