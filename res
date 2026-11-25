1795650565124966196
  fi
fi

echo "==> mkbootimg"
# XT3:s boot_a/boot_b ar 64 MB (67108864 byte). Ett for stort image flashar
# "lyckat" men startar inte, sa vi kontrollerar det har i stallet.
BOOT_MAX=$((64 * 1024 * 1024))
# scripts/pack-bootimg.py ar sjalvstandig (header v2). AOSP:s mkbootimg.py kraver
# sitt gki/-paket, som inte foljer med nar bara filen laddas ner - darfor
# anvands den bara om den faktiskt ar komplett.
PACKER="$ROOT/scripts/pack-bootimg.py"
if [ -f "$ROOT/tools/mkbootimg.py" ] && \
   python3 -c "import sys; sys.path.insert(0,'$ROOT/tools'); import gki" 2>/dev/null; then
  PACKER="$ROOT/tools/mkbootimg.py"
fi
# os_version i stock-headern (offset 44). ABL ser den; vi ateranvander
# enhetens eget varde i stallet for att skriva 0.
OSV=0
STOCK="$ROOT/out/fota/partitions/boot.img"
if [ -f "$STOCK" ]; then
  OSV=$(python3 - "$STOCK" <<'PYEOF'
import struct, sys
d = open(sys.argv[1], "rb").read(64)
print(struct.unpack_from("<I", d, 44)[0] if d[:8] == b"ANDROID!" else 0)
PYEOF
)
fi

# Stock ar padad till hela partitionen (64 MB). Qualcomm-ABL laser en fast
# region, sa vi fyller ut till samma storlek.
BOOT_PAD=67108864
[ -f "$STOCK" ] && BOOT_PAD=$(stat -c%s "$STOCK")

python3 "$PACKER" \
  --os_version "$OSV" --pad_to "$BOOT_PAD" \
  --kernel "$KERNEL" \
  --ramdisk "$INITRD" \
  --dtb "$DTB" \
  --cmdline "$CMDLINE" \
  --base 0x00000000 \
  --kernel_offset 0x00008000 \
