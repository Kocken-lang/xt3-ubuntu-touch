1795650652015445161
  --ramdisk "$INITRD" \
  --dtb "$DTB" \
  --cmdline "$CMDLINE" \
  --base 0x00000000 \
  --kernel_offset 0x00008000 \
  --ramdisk_offset 0x01000000 \
  --tags_offset 0x00000100 \
  --pagesize 4096 \
  --header_version 2 \
  --output "$OUTIMG"

ls -lh "$OUTIMG"
BOOT_SIZE=$(stat -c%s "$OUTIMG")
if [ "$BOOT_SIZE" -gt "$BOOT_MAX" ]; then
  echo "FEL: boot.img ar $((BOOT_SIZE / 1024 / 1024)) MB, partitionen ar 64 MB."
  echo "     Minsta initramfs: MODULES=dep i /etc/initramfs-tools/initramfs.conf"
  echo "     bygg om med: sudo make rootfs && make image"
  exit 1
fi
echo "    $((BOOT_SIZE / 1024 / 1024)) MB av 64 MB"
echo "Klart -> $OUTIMG"
