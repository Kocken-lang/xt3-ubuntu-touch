1795566181196102164
== stock kernel (offset 4096):
00000000: 1f8b 0800 0000 0000 0203 ec7d 0b78 14e5  ...........}.x..
00000010: b9ff 3733 bbc9 ec6e 80dc 1302 920b 5e76  ..73...n......^v
== vara Image.gz:
00000000: 1f8b 0800 0000 0000 0203 ec9c 0b54 1457  .............T.W
== finns okomprimerad Image?
-rw-rw-r-- 1 moon moon 12031269 Nov 25 00:00 out/kernel/Image.gz
== vad 09 packar:
7:KERNEL="${KERNEL:-$ROOT/out/kernel/Image.gz}"
