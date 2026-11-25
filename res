1795628038801194196
-rw-r--r-- 1 root root 7.4M Nov 24 23:31 out/initramfs.img
-rw-rw-r-- 1 moon moon  64K Nov 25 02:20 out/vbmeta-disabled.img

out/kernel/:
total 12M
-rw-rw-r-- 1 moon moon  12M Nov 25 18:31 Image.gz
drwxrwxr-x 3 moon moon 4.0K Nov 25 18:31 modules
-rw-rw-r-- 1 moon moon  54K Nov 25 18:32 sdm660-janam-xt3.dtb
--- initramfs innehall (letar usb-nat/telnet):
.
bin
conf
conf/arch.conf
conf/conf.d
conf/initramfs.conf
conf/modules
etc
--- usb-nat i initramfs?
2
--- pack-bootimg.py flaggor:
  kernel, ramdisk, second (0), recovery_dtbo (0), dtb
def build(kernel, ramdisk, dtb, page, cmdline, name, base,
          kernel_offset, ramdisk_offset, tags_offset, dtb_offset, os_version=0):
    struct.pack_into("<IQ", hdr, 1648, len(dtb), base + dtb_offset)
                     pad(ramdisk, page), pad(dtb, page)])
    for f in ("kernel", "ramdisk", "dtb", "output"):
        ap.add_argument(f"--{f}", required=True)
    ap.add_argument("--cmdline", default="")
    ap.add_argument("--name", default="")
    ap.add_argument("--pagesize", type=int, default=4096)
    ap.add_argument("--base", type=lambda v: int(v, 0), default=0)
    ap.add_argument("--kernel_offset", type=lambda v: int(v, 0), default=0x8000)
    ap.add_argument("--ramdisk_offset", type=lambda v: int(v, 0), default=0x1000000)
    ap.add_argument("--tags_offset", type=lambda v: int(v, 0), default=0x100)
    ap.add_argument("--dtb_offset", type=lambda v: int(v, 0), default=0x1F00000)
    ap.add_argument("--os_version", type=lambda v: int(v, 0), default=0)
    ap.add_argument("--pad_to", type=lambda v: int(v, 0), default=0)
    ap.add_argument("--header_version", type=int, default=2,
    img = build(read(a.kernel), read(a.ramdisk), read(a.dtb), a.pagesize,
                a.tags_offset, a.dtb_offset, a.os_version)
