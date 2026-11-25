1795637416195009116
=== var XT3-dts:
556 sdm660-janam-xt3.dts
// SPDX-License-Identifier: GPL-2.0-only
/*
 * Janam XT3 (Qualcomm SDA660) - mainline bring-up
 *
 * All values below come from one of:
 *   out/fota/dtbo/dtb/*.dts        stock 91.57 device tree overlays
 *   inventory-data/                live inventory from the device
 *   docs/02-enhetsmatris.md        Janam XT3 User Manual
 *
 * Nothing here is invented.  Where the stock DTB does not give a value the
 * line says TODO and the node stays disabled, so a wrong guess can never
 * brown out a rail or claim a bus that belongs to another device.
 *
 * Confirmed from the stock overlays:
 *   panel     JD9365DA 720p video (bekraftat: /sys/class/graphics/fb0/
 *             msm_fb_panel_info -> panel_name=jd9365da 720p video mode
 *             dsi panel), reset tlmm 53, TE tlmm 59, enable tlmm 8
 *   touch     Synaptics RMI4 @ i2c4 0x20, irq tlmm 67, reset tlmm 66
 *             (Goodix GT1x is the second source on the same pins, 0x14)
 *   expander  PCA9535 @ i2c1 0x22, irq tlmm 72, drives SAM control lines
 *   gauge     CW2015 @ i2c2 0x62, charge status tlmm 45
 *   NFC       PN54x @ i2c6 0x28, irq 28, ven 29, firm 30, clkreq pm660 gpio 4
 *   scanner   HSM imager @ i2c8 0x18, CSI2 port 2, 2 lanes, 11 GPIOs
 *   MSR       Wiznova MMD1000 on BLSP1 QUP3 SPI, irq 83, reset 63
 *   SAM       TDA8029 x2 behind PCA9535, card mux via sgm6503b
 *   keys      battery-open tlmm 76, battery-cover tlmm 40
 *   SD card   card detect tlmm 70
 */

/dts-v1/;
=== Makefile-post:
481:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
482:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
483:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
484:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
485:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
486:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
487:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
488:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
489:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
490:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
491:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
492:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
493:dtb-$(CONFIG_ARCH_QCOM) += sdm660-janam-xt3.dtb
