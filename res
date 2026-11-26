1795652359507786943
  KSYMS   .tmp_vmlinux2.kallsyms.S
  AS      .tmp_vmlinux2.kallsyms.o
  NM      .tmp_vmlinux2.syms
  KSYMS   .tmp_vmlinux2.kallsyms.S
  LD      vmlinux.unstripped
  AS      .tmp_vmlinux2.kallsyms.o
  LD      vmlinux.unstripped
  NM      System.map
aarch64-linux-gnu-nm: vmlinux.unstripped: file format not recognized
  SORTTAB vmlinux.unstripped
aarch64-linux-gnu-nm: vmlinux.unstripped: file format not recognized
unrecognized ELF data encoding 0: vmlinux.unstripped
Failed to sort kernel tables
make[3]: *** [/home/moon/xt3/out/src/linux/scripts/Makefile.vmlinux:72: vmlinux.unstripped] Error 1
make[3]: *** Deleting file 'vmlinux.unstripped'
make[2]: *** [/home/moon/xt3/out/src/linux/Makefile:1370: vmlinux] Error 2
make[1]: *** [/home/moon/xt3/out/src/linux/Makefile:248: __sub-make] Error 2
make[1]: Leaving directory '/home/moon/xt3/out/kbuild'
make: *** [Makefile:248: __sub-make] Error 2
  NM      System.map
aarch64-linux-gnu-nm: 'vmlinux.unstripped': No such file
  SORTTAB vmlinux.unstripped
aarch64-linux-gnu-nm: 'vmlinux.unstripped': No such file
vmlinux.unstripped: No such file or directory
Failed to sort kernel tables
make[3]: *** [/home/moon/xt3/out/src/linux/scripts/Makefile.vmlinux:72: vmlinux.unstripped] Error 1
make[2]: *** [/home/moon/xt3/out/src/linux/Makefile:1370: vmlinux] Error 2
make[1]: *** [/home/moon/xt3/out/src/linux/Makefile:248: __sub-make] Error 2
make[1]: Leaving directory '/home/moon/xt3/out/kbuild'
make: *** [Makefile:248: __sub-make] Error 2
