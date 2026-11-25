1795627844476627028
AndroidBoot.mk
Documentation
LICENSE
README.md
app
arch
dev
include
kernel
lib
lk2nd
make
makefile
platform
project
scripts
target
--- README byggavsnitt:
63:> should be enough to make the stock bootloader ignore the keys.
64-
65-`fastboot flash lk2nd lk2nd.img` can be used to update lk2nd directly from its
66-fastboot interface.
67-
68-> [!IMPORTANT]
69-> `fastboot flash boot boot.img` will flash the actual boot image with 512 KiB offset
--
81:## Building
82-
83:Generally, this should be enough to build lk2nd:
84-
85-```
86:$ make TOOLCHAIN_PREFIX=arm-none-eabi- lk2nd-msmXXXX
87-```
88-
89:See [building.md](Documentation/building.md) for more info.
90-
91-## Contact
92-Ask on [`#lk2nd:postmarketos.org`](https://matrix.to/#/#lk2nd:postmarketos.org) (`#lk2nd` on [irc.oftc.net](https://www.oftc.net/)).
93-
94-[PSCI]: https://developer.arm.com/architectures/system-architectures/software-standards/psci
95-[Little Kernel Embedded Operating System]: https://github.com/littlekernel/lk
--- sok sdm660:
