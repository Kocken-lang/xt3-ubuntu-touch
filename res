1795723137015472448
patchad
syntax OK
8:  for _k in "$ROOT/out/kbuild/arch/arm64/boot/Image" "$ROOT/out/kernel/Image" "$ROOT/out/kernel/Image.gz"; do
48:RAMDISK_OFFSET="${RAMDISK_OFFSET:-0x01000000}"
50:if [ "$(( 0x8000 + KERNSZ ))" -gt "$(( RAMDISK_OFFSET ))" ]; then
51:  echo "    OBS: karnan ($KERNSZ B) overlappar ramdisken vid $RAMDISK_OFFSET - flyttar till 0x02000000"
52:  RAMDISK_OFFSET=0x02000000
92:  --ramdisk_offset "$RAMDISK_OFFSET" \
