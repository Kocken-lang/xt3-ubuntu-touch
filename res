1795645610865830559
AndroidBoot.mk
Documentation
LICENSE
README.md
app
arch
build-lk2nd-sdm660
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
=== README (forsta 40):
![An image of multiple devices showing lk2nd menu](Documentation/.assets/header.jpg)

# lk2nd
lk2nd is a custom bootloader for many different devices based on Qualcomm
system-on-chips (SoCs), including smartphones, tablets, smartwatches and a few
single board computers (SBCs). It simplifies booting standard operating systems
by providing:

  - **A unified boot and flashing interface** (Android Fastboot), independent of
    device-specific modifications made to the boot chain (e.g. the proprietary
    flashing interface on Samsung devices)
  - **Automatic device and hardware detection** (e.g. display panels, batteries, ...)
  - **Additional bootloader features** (e.g. file system boot, booting from SD card)
  - **Additional firmware features** (e.g. booting secondary CPU cores if the firmware
    lacks [PSCI] support)
  - **Workarounds for various device-specific issues** (e.g. USB on some Samsung
    devices, modem on Motorola smartphones, ...)
  - **Various debugging commands** that allow better understanding of the hardware
    for research and development purposes

There are two different configurations:

  - **lk2nd:** "secondary" bootloader intended for devices where existing
    firmware cannot be replaced easily (most smartphones and tablets). In this
    configuration, lk2nd does **not** replace the stock bootloader. Instead, it
    is packed into an Android boot image, which is then loaded by the stock
    bootloader just like the original Android image.
    The real operating system can be placed in the boot partition with 512 KiB
    offset or stored in a ext2 file system. It does not have to be Android or
    even Linux, any kind of kernel can be packed into an Android boot image.

  - **lk1st:** primary bootloader intended for single-board computers (SBCs)
    and expert users. In this case, it is the "first" bootloader responsible for
    loading the main operating system.

This repository is a fork of the [original open-source bootloader from Qualcomm](https://git.codelinaro.org/clo/la/kernel/lk/-/tree/lk.lnx.1.0.r54-rel),
which is a heavily modified version of the [Little Kernel Embedded Operating System].

## Supported SoCs and devices

=== partition-offset i kod:
lk2nd/device/2nd/partition.c:91:#ifdef LK2ND_PARTITION_SIZE
lk2nd/device/2nd/partition.c:92:	partition_split_mmc(LK2ND_PARTITION_BASE, LK2ND_PARTITION_NAME,
lk2nd/device/2nd/partition.c:93:			    LK2ND_PARTITION_SIZE / block_size, false);
lk2nd/device/2nd/partition.c:105:#ifdef LK2ND_PARTITION_SIZE
lk2nd/device/2nd/partition.c:106:	partition_split_flash(ptable, LK2ND_PARTITION_BASE, LK2ND_PARTITION_NAME,
lk2nd/device/2nd/partition.c:107:			      LK2ND_PARTITION_SIZE / block_size, false);
