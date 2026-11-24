#!/usr/bin/env bash
# Install all host tooling needed by the XT3 port pipeline (Ubuntu/Debian).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> apt packages"
sudo apt-get update
sudo apt-get install -y \
  android-sdk-libsparse-utils android-sdk-platform-tools-common adb fastboot \
  apktool aapt apksigner zipalign binwalk tcpdump clang \
  device-tree-compiler gcc-aarch64-linux-gnu libssl-dev libelf-dev \
  bc bison flex git curl wget unzip 7zip cpio rsync kmod e2fsprogs \
  python3-pip python3-venv python3-dev swig libfdt-dev dosfstools mtools

# jadx is not in the Ubuntu archive -> GitHub release
if ! command -v jadx >/dev/null; then
  echo "==> jadx (GitHub release)"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/jadx.zip" \
    https://github.com/skylot/jadx/releases/download/v1.5.1/jadx-1.5.1.zip
  sudo unzip -q -o "$tmp/jadx.zip" -d /opt/jadx
  sudo ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx
  rm -rf "$tmp"
fi

echo "==> python venv"
python3 -m venv "$ROOT/.venv"
"$ROOT/.venv/bin/pip" install --quiet --upgrade pip
"$ROOT/.venv/bin/pip" install --quiet pylibfdt

echo "==> AOSP boot image tools"
mkdir -p "$ROOT/tools"
for f in unpack_bootimg.py mkbootimg.py; do
  [ -f "$ROOT/tools/$f" ] || curl -fsSL -o "$ROOT/tools/$f" \
    "https://android.googlesource.com/platform/system/tools/mkbootimg/+/refs/heads/main/$f?format=TEXT" \
    && base64 -d "$ROOT/tools/$f" > "$ROOT/tools/$f.dec" && mv "$ROOT/tools/$f.dec" "$ROOT/tools/$f"
  chmod +x "$ROOT/tools/$f"
done
[ -f "$ROOT/tools/mkdtboimg.py" ] || {
  curl -fsSL "https://android.googlesource.com/platform/system/libufdt/+/refs/heads/main/utils/src/mkdtboimg.py?format=TEXT" \
    | base64 -d > "$ROOT/tools/mkdtboimg.py"; chmod +x "$ROOT/tools/mkdtboimg.py"; }

echo "==> panel driver generator"
[ -d "$ROOT/.reference/linux-mdss-dsi-panel-driver-generator" ] || {
  mkdir -p "$ROOT/.reference"
  git clone -q --depth 1 \
    https://github.com/msm8916-mainline/linux-mdss-dsi-panel-driver-generator \
    "$ROOT/.reference/linux-mdss-dsi-panel-driver-generator"; }

echo "OK. Nästa: ./scripts/01-device-inventory.sh"
