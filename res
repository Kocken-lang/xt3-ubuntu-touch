1795652343749816485
--- kontext:
4:  COPY    vmlinux.a
5:  LD      vmlinux.o
8:  COPY    vmlinux.a
9:  MODPOST vmlinux.symvers
12:  KSYMS   .tmp_vmlinux0.kallsyms.S
13:  AS      .tmp_vmlinux0.kallsyms.o
14:  LD      .tmp_vmlinux1
15:  MODPOST vmlinux.symvers
18:  NM      .tmp_vmlinux1.syms
19:  KSYMS   .tmp_vmlinux0.kallsyms.S
--- minne:
               total        used        free      shared  buff/cache   available
Mem:              30           7           3           1          20          22
