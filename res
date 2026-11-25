1795650548827730221
scripts/09-pack-boot.sh
scripts/00-bootstrap.sh
scripts/__pycache__/pack-bootimg.cpython-314.pyc
scripts/pack-bootimg.py
---
scripts/00-bootstrap.sh:35:for f in unpack_bootimg.py mkbootimg.py; do
scripts/00-bootstrap.sh:37:    "https://android.googlesource.com/platform/system/tools/mkbootimg/+/refs/heads/main/$f?format=TEXT" \
scripts/09-pack-boot.sh:43:echo "==> mkbootimg"
scripts/09-pack-boot.sh:47:# scripts/pack-bootimg.py ar sjalvstandig (header v2). AOSP:s mkbootimg.py kraver
scripts/09-pack-boot.sh:51:if [ -f "$ROOT/tools/mkbootimg.py" ] && \
scripts/09-pack-boot.sh:53:  PACKER="$ROOT/tools/mkbootimg.py"
