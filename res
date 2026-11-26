1795722622895009684
41-fi
42-
43:echo "==> mkbootimg"
44-# XT3:s boot_a/boot_b ar 64 MB (67108864 byte). Ett for stort image flashar
45-# "lyckat" men startar inte, sa vi kontrollerar det har i stallet.
46-BOOT_MAX=$((64 * 1024 * 1024))
47:# scripts/pack-bootimg.py ar sjalvstandig (header v2). AOSP:s mkbootimg.py kraver
48-# sitt gki/-paket, som inte foljer med nar bara filen laddas ner - darfor
49-# anvands den bara om den faktiskt ar komplett.
50-PACKER="$ROOT/scripts/pack-bootimg.py"
51:if [ -f "$ROOT/tools/mkbootimg.py" ] && \
52-   python3 -c "import sys; sys.path.insert(0,'$ROOT/tools'); import gki" 2>/dev/null; then
53:  PACKER="$ROOT/tools/mkbootimg.py"
54-fi
55-# os_version i stock-headern (offset 44). ABL ser den; vi ateranvander
56-# enhetens eget varde i stallet for att skriva 0.
57-OSV=0
58-STOCK="$ROOT/out/fota/partitions/boot.img"
59-if [ -f "$STOCK" ]; then
60-  OSV=$(python3 - "$STOCK" <<'PYEOF'
61-import struct, sys
62-d = open(sys.argv[1], "rb").read(64)
63-print(struct.unpack_from("<I", d, 44)[0] if d[:8] == b"ANDROID!" else 0)
64-PYEOF
65-)
66-fi
67-
