#!/usr/bin/env python3
"""Jamfor tva Android boot images falt for falt.

Syfte: enheten accepterar stock-boot.img men inte var. Skillnaden maste
ligga i headern (adresser, sidstorlek, version, cmdline) eller i innehallet.
Verktyget skriver bada bildernas falt sida vid sida och kan packa om en bild
med vara verktyg for att isolera om felet ar var packare eller var karna.

  usage: 21-bootimg-diff.py <stock.img> <var.img>
         21-bootimg-diff.py --repack <stock.img> <ut.img>
"""
import struct
import sys

FIELDS = ["kernel_size", "kernel_addr", "ramdisk_size", "ramdisk_addr",
          "second_size", "second_addr", "tags_addr", "page_size",
          "header_version", "os_version"]


def parse(path):
    with open(path, "rb") as fh:
        d = fh.read()
    if d[:8] != b"ANDROID!":
        raise SystemExit(f"{path}: inte en Android boot image")
    vals = dict(zip(FIELDS, struct.unpack_from("<10I", d, 8)))
    name = d[48:64].rstrip(b"\0").decode(errors="replace")
    cmdline = d[64:576].rstrip(b"\0").decode(errors="replace")
    extra = d[608:1632].rstrip(b"\0").decode(errors="replace")
    hv = vals["header_version"]
    dtb_size = dtb_addr = 0
    if hv >= 2:
        dtb_size, dtb_addr = struct.unpack_from("<IQ", d, 1648)
    vals["dtb_size"], vals["dtb_addr"] = dtb_size, dtb_addr
    page = vals["page_size"]
    off = page
    kern = d[off:off + vals["kernel_size"]]
    off += (vals["kernel_size"] + page - 1) // page * page
    ram = d[off:off + vals["ramdisk_size"]]
    off += (vals["ramdisk_size"] + page - 1) // page * page
    off += (vals["second_size"] + page - 1) // page * page
    if hv >= 1:
        rd_size, rd_off = struct.unpack_from("<IQ", d, 1632)
        off += (rd_size + page - 1) // page * page
    dtb = d[off:off + dtb_size] if dtb_size else b""
    return dict(vals=vals, name=name, cmdline=cmdline, extra=extra,
                kernel=kern, ramdisk=ram, dtb=dtb, size=len(d), path=path)


def show(a, b):
    print(f"{'falt':18} {'stock':>22} {'var':>22}")
    for f in FIELDS:
        va, vb = a["vals"][f], b["vals"][f]
        mark = "" if va == vb else "   <-- skiljer"
        print(f"{f:18} {va:>22} {vb:>22}{mark}")
    print(f"{'kernel byte':18} {len(a['kernel']):>22} {len(b['kernel']):>22}")
    print(f"{'ramdisk byte':18} {len(a['ramdisk']):>22} {len(b['ramdisk']):>22}")
    print(f"{'dtb_size':18} {a['vals']['dtb_size']:>22} {b['vals']['dtb_size']:>22}")
    print(f"{'dtb_addr':18} {a['vals']['dtb_addr']:>22} {b['vals']['dtb_addr']:>22}")
    print(f"{'dtb byte':18} {len(a['dtb']):>22} {len(b['dtb']):>22}")
    print(f"{'filstorlek':18} {a['size']:>22} {b['size']:>22}")
    print(f"\nstock name    : {a['name']}")
    print(f"var   name    : {b['name']}")
    print(f"\nstock cmdline : {a['cmdline']}")
    print(f"var   cmdline : {b['cmdline']}")
    if a["extra"]:
        print(f"\nstock extra   : {a['extra'][:200]}")


def repack(src, dst):
    sys.path.insert(0, __file__.rsplit("/", 1)[0])
    from importlib.machinery import SourceFileLoader
    pack = SourceFileLoader("pack", __file__.replace("21-bootimg-diff.py",
                                                     "pack-bootimg.py")).load_module()
    a = parse(src)
    v = a["vals"]
    img = pack.build(a["kernel"], a["ramdisk"], a["dtb"], v["page_size"],
                     a["cmdline"], a["name"], 0,
                     v["kernel_addr"], v["ramdisk_addr"], v["tags_addr"],
                     v["dtb_addr"] or 0x1F00000, v["os_version"])
    # Samma slutstorlek som stock - ABL laser en fast region.
    if len(img) < a["size"]:
        img += b"\0" * (a["size"] - len(img))
    with open(dst, "wb") as fh:
        fh.write(img)
    print(f"skrev {dst}: {len(img)} byte (samma innehall som {src}, vara header-falt)")


def hybrid(stock_img, out_img, root, kernel="ours", dtb="ours",
           ramdisk="ours", cmdline="stock"):
    """Blanda vara delar med stock-delar for att isolera en i taget."""
    sys.path.insert(0, __file__.rsplit("/", 1)[0])
    from importlib.machinery import SourceFileLoader
    pack = SourceFileLoader("pack", __file__.replace("21-bootimg-diff.py",
                                                     "pack-bootimg.py")).load_module()
    st = parse(stock_img)
    v = st["vals"]
    mine = {
        "kernel": f"{root}/out/kernel/Image.gz",
        "dtb": f"{root}/out/kernel/sdm660-janam-xt3.dtb",
        "ramdisk": f"{root}/out/initramfs.img",
    }
    def pick(choice, key, default):
        return default if choice == "stock" else open(mine[key], "rb").read()
    kern = pick(kernel, "kernel", st["kernel"])
    dtb_ = pick(dtb, "dtb", st["dtb"])
    ram = pick(ramdisk, "ramdisk", st["ramdisk"])
    cmd = st["cmdline"] if cmdline == "stock" else st["cmdline"] + " root=LABEL=ut-rootfs rootwait rw"
    img = pack.build(kern, ram, dtb_, v["page_size"], cmd, "", 0,
                     v["kernel_addr"], v["ramdisk_addr"], v["tags_addr"],
                     v["dtb_addr"] or 0x1F00000, v["os_version"])
    if len(img) < st["size"]:
        img += b"\0" * (st["size"] - len(img))
    open(out_img, "wb").write(img)
    print(f"skrev {out_img}: kernel={kernel} dtb={dtb} ramdisk={ramdisk} "
          f"cmdline={cmdline}, {len(img)} byte")


if __name__ == "__main__":
    if len(sys.argv) >= 5 and sys.argv[1] == "--hybrid":
        args = dict(a.split("=", 1) for a in sys.argv[5:])
        hybrid(sys.argv[2], sys.argv[3], sys.argv[4], **args)
    elif len(sys.argv) == 4 and sys.argv[1] == "--repack":
        repack(sys.argv[2], sys.argv[3])
    elif len(sys.argv) == 3:
        show(parse(sys.argv[1]), parse(sys.argv[2]))
    else:
        raise SystemExit(__doc__)
