1795651272199642236
KERNEL="${KERNEL:-$ROOT/out/kernel/Image.gz}"
DTB="${DTB:-$(ls "$ROOT"/out/kernel/*.dtb 2>/dev/null | head -1)}"
INITRD="${INITRD:-}"
CMDLINE="${CMDLINE:-console=tty0 console=ttyMSM0,115200n8 earlycon root=PARTLABEL=userdata rootwait rw loglevel=7}"
