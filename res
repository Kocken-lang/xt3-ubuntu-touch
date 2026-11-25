1795645497653734411
target/sdm660 skapad
project/lk2nd-sdm660.mk skapad
78:TOOLCHAIN_PREFIX ?= arm-eabi-
90:all:: $(OUTBIN) $(OUTELF).lst $(OUTELF).debug.lst $(OUTELF).sym $(OUTELF).size $(OUTELF_STRIP) APPSBOOTHEADER
211:all:: $(EXTRA_BUILDDEPS)
251:CC := $(CCACHE) $(TOOLCHAIN_PREFIX)gcc
253:LD := $(TOOLCHAIN_PREFIX)ld
255:STRIP := $(TOOLCHAIN_PREFIX)strip
=== forsta byggforsok:
make[1]: Entering directory '/home/moon/xt3/out/src/lk2nd'
aarch64-linux-gnu-gcc: error: unrecognized command-line option ‘-mthumb-interwork’
aarch64-linux-gnu-gcc: error: unrecognized command-line option ‘-mthumb’
including dev/fbcon dev/gcdb/display dev/keys dev/pmic/pm8x41 dev/pmic/pmi8994 dev/qpnp_haptic dev/qpnp_wled dev/vib lib/debug lib/heap lib/libc lib/libfdt lib/ptable lk2nd lk2nd/device lk2nd/device/2nd lk2nd/device/menu lk2nd/display lk2nd/fastboot lk2nd/fastboot/debug lk2nd/hw/gpio lk2nd/hw/i2c lk2nd/ramoops lk2nd/serialno lk2nd/smp lk2nd/smp/spin-table lk2nd/version
lk2nd/smp/spin-table/rules.mk:7: NOTE: msm8953 not supported, disabling SMP spin table
including lk2nd/hw/regulator
lk2nd/project/base.mk:15: project/sdm660.mk: No such file or directory
make[1]: *** No rule to make target 'project/sdm660.mk'.  Stop.
make[1]: Leaving directory '/home/moon/xt3/out/src/lk2nd'
make: *** [makefile:20: make-make] Error 2
