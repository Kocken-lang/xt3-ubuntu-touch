1795652525007826192
grep: (standard input): binary file matches
+ is_enabled CONFIG_DEBUG_INFO_BTF
+ grep -q ^CONFIG_DEBUG_INFO_BTF=y include/config/auto.conf
+ mksysmap vmlinux.unstripped System.map
+ info NM System.map
+ printf   %-7s %s\n NM System.map
+ aarch64-linux-gnu-nm -n vmlinux.unstripped
+ sed -f /home/moon/xt3/out/src/linux/scripts/mksysmap
+ is_enabled CONFIG_BUILDTIME_TABLE_SORT
+ grep -q ^CONFIG_BUILDTIME_TABLE_SORT=y include/config/auto.conf
+ info SORTTAB vmlinux.unstripped
+ printf   %-7s %s\n SORTTAB vmlinux.unstripped
+ sorttable vmlinux.unstripped
+ aarch64-linux-gnu-nm -S vmlinux.unstripped
+ ./scripts/sorttable -s .tmp_vmlinux.nm-sort vmlinux.unstripped
+ is_enabled CONFIG_KALLSYMS
+ grep -q ^CONFIG_KALLSYMS=y include/config/auto.conf
+ cmp -s System.map .tmp_vmlinux2.syms
+ echo vmlinux.unstripped: /home/moon/xt3/out/src/linux/scripts/link-vmlinux.sh
# OBJCOPY vmlinux
# GEN     modules.builtin.modinfo
