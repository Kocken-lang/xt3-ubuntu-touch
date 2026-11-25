1795647661890953621
  NM      .tmp_vmlinux1.syms
  KSYMS   .tmp_vmlinux1.kallsyms.S
  AS      .tmp_vmlinux1.kallsyms.o
  LD      .tmp_vmlinux2
  NM      .tmp_vmlinux2.syms
  KSYMS   .tmp_vmlinux2.kallsyms.S
  AS      .tmp_vmlinux2.kallsyms.o
  LD      vmlinux.unstripped
  NM      System.map
  SORTTAB vmlinux.unstripped
  OBJCOPY vmlinux
  GEN     modules.builtin.modinfo
aarch64-linux-gnu-objcopy: error: the input file 'vmlinux.unstripped' is empty
make[3]: *** [/home/moon/xt3/out/src/linux/scripts/Makefile.vmlinux:123: modules.builtin.modinfo] Error 1
make[2]: *** [/home/moon/xt3/out/src/linux/Makefile:1370: vmlinux] Error 2
make[1]: *** [/home/moon/xt3/out/src/linux/Makefile:248: __sub-make] Error 2
make[1]: Leaving directory '/home/moon/xt3/out/kbuild'
make: *** [Makefile:248: __sub-make] Error 2
