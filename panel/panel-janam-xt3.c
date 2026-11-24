// SPDX-License-Identifier: GPL-2.0-only
/*
 * ili9881d 720p video mode dsi panel
 *
 * GENERERAD av scripts/13-panel-from-dtb.py ur qcom,mdss_dsi_ili9881d_720p_video.
 * Redigera inte for hand: kor om generatorn nar DTB:n andras.
 *
 * Panel:    720x1280 @ 60 Hz, 24 bpp, 4 lanes
 * Typ:      dsi_video_mode
 * Timing:   h 60/20/90  v 24/4/24
 * Klocka:   71128 kHz
 *
 * Kommandoformatet ar Qualcomm ``struct dsi_ctrl_hdr`` (7 byte, dlen big
 * endian).  Se filens huvud i generatorn for harledningen.
 */

#include <linux/backlight.h>
#include <linux/delay.h>
#include <linux/gpio/consumer.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/regulator/consumer.h>

#include <drm/drm_mipi_dsi.h>
#include <drm/drm_modes.h>
#include <drm/drm_panel.h>

#include <video/mipi_display.h>

struct xt3_dsi_cmd {
        u8 dtype;
        u8 wait;
        u16 len;
        const u8 *data;
};

struct xt3_panel {
        struct drm_panel panel;
        struct mipi_dsi_device *dsi;
        struct gpio_desc *reset_gpio;
        struct regulator *power;
        bool prepared;
};

static inline struct xt3_panel *to_xt3_panel(struct drm_panel *panel)
{
        return container_of(panel, struct xt3_panel, panel);
}

static const u8 xt3_on_0[] = {
        0xff, 0x98, 0x81, 0x03,
};

static const u8 xt3_on_1[] = {
        0x01, 0x00,
};

static const u8 xt3_on_2[] = {
        0x02, 0x00,
};

static const u8 xt3_on_3[] = {
        0x03, 0x73,
};

static const u8 xt3_on_4[] = {
        0x04, 0x00,
};

static const u8 xt3_on_5[] = {
        0x05, 0x00,
};

static const u8 xt3_on_6[] = {
        0x06, 0x0a,
};

static const u8 xt3_on_7[] = {
        0x07, 0x00,
};

static const u8 xt3_on_8[] = {
        0x08, 0x00,
};

static const u8 xt3_on_9[] = {
        0x09, 0x01,
};

static const u8 xt3_on_10[] = {
        0x0a, 0x00,
};

static const u8 xt3_on_11[] = {
        0x0b, 0x00,
};

static const u8 xt3_on_12[] = {
        0x0c, 0x01,
};

static const u8 xt3_on_13[] = {
        0x0d, 0x00,
};

static const u8 xt3_on_14[] = {
        0x0e, 0x00,
};

static const u8 xt3_on_15[] = {
        0x0f, 0x1d,
};

static const u8 xt3_on_16[] = {
        0x10, 0x0d,
};

static const u8 xt3_on_17[] = {
        0x11, 0x00,
};

static const u8 xt3_on_18[] = {
        0x12, 0x00,
};

static const u8 xt3_on_19[] = {
        0x13, 0x00,
};

static const u8 xt3_on_20[] = {
        0x14, 0x00,
};

static const u8 xt3_on_21[] = {
        0x15, 0x00,
};

static const u8 xt3_on_22[] = {
        0x16, 0x00,
};

static const u8 xt3_on_23[] = {
        0x17, 0x00,
};

static const u8 xt3_on_24[] = {
        0x18, 0x00,
};

static const u8 xt3_on_25[] = {
        0x19, 0x00,
};

static const u8 xt3_on_26[] = {
        0x1a, 0x00,
};

static const u8 xt3_on_27[] = {
        0x1b, 0x00,
};

static const u8 xt3_on_28[] = {
        0x1c, 0x00,
};

static const u8 xt3_on_29[] = {
        0x1d, 0x00,
};

static const u8 xt3_on_30[] = {
        0x1e, 0x40,
};

static const u8 xt3_on_31[] = {
        0x1f, 0x80,
};

static const u8 xt3_on_32[] = {
        0x20, 0x06,
};

static const u8 xt3_on_33[] = {
        0x21, 0x02,
};

static const u8 xt3_on_34[] = {
        0x22, 0x00,
};

static const u8 xt3_on_35[] = {
        0x23, 0x00,
};

static const u8 xt3_on_36[] = {
        0x24, 0x00,
};

static const u8 xt3_on_37[] = {
        0x25, 0x00,
};

static const u8 xt3_on_38[] = {
        0x26, 0x00,
};

static const u8 xt3_on_39[] = {
        0x27, 0x00,
};

static const u8 xt3_on_40[] = {
        0x28, 0x33,
};

static const u8 xt3_on_41[] = {
        0x29, 0x03,
};

static const u8 xt3_on_42[] = {
        0x2a, 0x00,
};

static const u8 xt3_on_43[] = {
        0x2b, 0x00,
};

static const u8 xt3_on_44[] = {
        0x2c, 0x00,
};

static const u8 xt3_on_45[] = {
        0x2d, 0x00,
};

static const u8 xt3_on_46[] = {
        0x2e, 0x00,
};

static const u8 xt3_on_47[] = {
        0x2f, 0x00,
};

static const u8 xt3_on_48[] = {
        0x30, 0x00,
};

static const u8 xt3_on_49[] = {
        0x31, 0x00,
};

static const u8 xt3_on_50[] = {
        0x32, 0x00,
};

static const u8 xt3_on_51[] = {
        0x33, 0x00,
};

static const u8 xt3_on_52[] = {
        0x34, 0x04,
};

static const u8 xt3_on_53[] = {
        0x35, 0x00,
};

static const u8 xt3_on_54[] = {
        0x36, 0x00,
};

static const u8 xt3_on_55[] = {
        0x37, 0x00,
};

static const u8 xt3_on_56[] = {
        0x38, 0x3c,
};

static const u8 xt3_on_57[] = {
        0x39, 0x35,
};

static const u8 xt3_on_58[] = {
        0x3a, 0x01,
};

static const u8 xt3_on_59[] = {
        0x3b, 0x40,
};

static const u8 xt3_on_60[] = {
        0x3c, 0x00,
};

static const u8 xt3_on_61[] = {
        0x3d, 0x01,
};

static const u8 xt3_on_62[] = {
        0x3e, 0x00,
};

static const u8 xt3_on_63[] = {
        0x3f, 0x00,
};

static const u8 xt3_on_64[] = {
        0x40, 0x00,
};

static const u8 xt3_on_65[] = {
        0x41, 0x88,
};

static const u8 xt3_on_66[] = {
        0x42, 0x00,
};

static const u8 xt3_on_67[] = {
        0x43, 0x00,
};

static const u8 xt3_on_68[] = {
        0x44, 0x1f,
};

static const u8 xt3_on_69[] = {
        0x50, 0x01,
};

static const u8 xt3_on_70[] = {
        0x51, 0x23,
};

static const u8 xt3_on_71[] = {
        0x52, 0x45,
};

static const u8 xt3_on_72[] = {
        0x53, 0x67,
};

static const u8 xt3_on_73[] = {
        0x54, 0x89,
};

static const u8 xt3_on_74[] = {
        0x55, 0xab,
};

static const u8 xt3_on_75[] = {
        0x56, 0x01,
};

static const u8 xt3_on_76[] = {
        0x57, 0x23,
};

static const u8 xt3_on_77[] = {
        0x58, 0x45,
};

static const u8 xt3_on_78[] = {
        0x59, 0x67,
};

static const u8 xt3_on_79[] = {
        0x5a, 0x89,
};

static const u8 xt3_on_80[] = {
        0x5b, 0xab,
};

static const u8 xt3_on_81[] = {
        0x5c, 0xcd,
};

static const u8 xt3_on_82[] = {
        0x5d, 0xef,
};

static const u8 xt3_on_83[] = {
        0x5e, 0x11,
};

static const u8 xt3_on_84[] = {
        0x5f, 0x01,
};

static const u8 xt3_on_85[] = {
        0x60, 0x00,
};

static const u8 xt3_on_86[] = {
        0x61, 0x15,
};

static const u8 xt3_on_87[] = {
        0x62, 0x14,
};

static const u8 xt3_on_88[] = {
        0x63, 0x0e,
};

static const u8 xt3_on_89[] = {
        0x64, 0x0f,
};

static const u8 xt3_on_90[] = {
        0x65, 0x0c,
};

static const u8 xt3_on_91[] = {
        0x66, 0x0d,
};

static const u8 xt3_on_92[] = {
        0x67, 0x06,
};

static const u8 xt3_on_93[] = {
        0x68, 0x02,
};

static const u8 xt3_on_94[] = {
        0x69, 0x07,
};

static const u8 xt3_on_95[] = {
        0x6a, 0x02,
};

static const u8 xt3_on_96[] = {
        0x6b, 0x02,
};

static const u8 xt3_on_97[] = {
        0x6c, 0x02,
};

static const u8 xt3_on_98[] = {
        0x6d, 0x02,
};

static const u8 xt3_on_99[] = {
        0x6e, 0x02,
};

static const u8 xt3_on_100[] = {
        0x6f, 0x02,
};

static const u8 xt3_on_101[] = {
        0x70, 0x02,
};

static const u8 xt3_on_102[] = {
        0x71, 0x02,
};

static const u8 xt3_on_103[] = {
        0x72, 0x02,
};

static const u8 xt3_on_104[] = {
        0x73, 0x02,
};

static const u8 xt3_on_105[] = {
        0x74, 0x02,
};

static const u8 xt3_on_106[] = {
        0x75, 0x01,
};

static const u8 xt3_on_107[] = {
        0x76, 0x00,
};

static const u8 xt3_on_108[] = {
        0x77, 0x14,
};

static const u8 xt3_on_109[] = {
        0x78, 0x15,
};

static const u8 xt3_on_110[] = {
        0x79, 0x0e,
};

static const u8 xt3_on_111[] = {
        0x7a, 0x0f,
};

static const u8 xt3_on_112[] = {
        0x7b, 0x0c,
};

static const u8 xt3_on_113[] = {
        0x7c, 0x0d,
};

static const u8 xt3_on_114[] = {
        0x7d, 0x06,
};

static const u8 xt3_on_115[] = {
        0x7e, 0x02,
};

static const u8 xt3_on_116[] = {
        0x7f, 0x07,
};

static const u8 xt3_on_117[] = {
        0x80, 0x02,
};

static const u8 xt3_on_118[] = {
        0x81, 0x02,
};

static const u8 xt3_on_119[] = {
        0x82, 0x02,
};

static const u8 xt3_on_120[] = {
        0x83, 0x02,
};

static const u8 xt3_on_121[] = {
        0x84, 0x02,
};

static const u8 xt3_on_122[] = {
        0x85, 0x02,
};

static const u8 xt3_on_123[] = {
        0x86, 0x02,
};

static const u8 xt3_on_124[] = {
        0x87, 0x02,
};

static const u8 xt3_on_125[] = {
        0x88, 0x02,
};

static const u8 xt3_on_126[] = {
        0x89, 0x02,
};

static const u8 xt3_on_127[] = {
        0x8a, 0x02,
};

static const u8 xt3_on_128[] = {
        0xff, 0x98, 0x81, 0x04,
};

static const u8 xt3_on_129[] = {
        0x6d, 0x08,
};

static const u8 xt3_on_130[] = {
        0x6f, 0x05,
};

static const u8 xt3_on_131[] = {
        0x70, 0x00,
};

static const u8 xt3_on_132[] = {
        0x71, 0x00,
};

static const u8 xt3_on_133[] = {
        0x82, 0x0f,
};

static const u8 xt3_on_134[] = {
        0x84, 0x0f,
};

static const u8 xt3_on_135[] = {
        0x85, 0x0d,
};

static const u8 xt3_on_136[] = {
        0x32, 0xac,
};

static const u8 xt3_on_137[] = {
        0x8c, 0x80,
};

static const u8 xt3_on_138[] = {
        0x3c, 0xf5,
};

static const u8 xt3_on_139[] = {
        0x3a, 0x24,
};

static const u8 xt3_on_140[] = {
        0xb5, 0x07,
};

static const u8 xt3_on_141[] = {
        0x31, 0x45,
};

static const u8 xt3_on_142[] = {
        0x88, 0x33,
};

static const u8 xt3_on_143[] = {
        0xff, 0x98, 0x81, 0x01,
};

static const u8 xt3_on_144[] = {
        0x22, 0x09,
};

static const u8 xt3_on_145[] = {
        0x31, 0x00,
};

static const u8 xt3_on_146[] = {
        0x53, 0x8a,
};

static const u8 xt3_on_147[] = {
        0x55, 0xa2,
};

static const u8 xt3_on_148[] = {
        0x50, 0x81,
};

static const u8 xt3_on_149[] = {
        0x51, 0x85,
};

static const u8 xt3_on_150[] = {
        0x60, 0x20,
};

static const u8 xt3_on_151[] = {
        0xa0, 0x00,
};

static const u8 xt3_on_152[] = {
        0xa1, 0x1a,
};

static const u8 xt3_on_153[] = {
        0xa2, 0x28,
};

static const u8 xt3_on_154[] = {
        0xa3, 0x13,
};

static const u8 xt3_on_155[] = {
        0xa4, 0x16,
};

static const u8 xt3_on_156[] = {
        0xa5, 0x29,
};

static const u8 xt3_on_157[] = {
        0xa6, 0x1d,
};

static const u8 xt3_on_158[] = {
        0xa7, 0x1e,
};

static const u8 xt3_on_159[] = {
        0xa8, 0x84,
};

static const u8 xt3_on_160[] = {
        0xa9, 0x1c,
};

static const u8 xt3_on_161[] = {
        0xaa, 0x28,
};

static const u8 xt3_on_162[] = {
        0xab, 0x75,
};

static const u8 xt3_on_163[] = {
        0xac, 0x1a,
};

static const u8 xt3_on_164[] = {
        0xad, 0x19,
};

static const u8 xt3_on_165[] = {
        0xae, 0x4d,
};

static const u8 xt3_on_166[] = {
        0xaf, 0x22,
};

static const u8 xt3_on_167[] = {
        0xb0, 0x28,
};

static const u8 xt3_on_168[] = {
        0xb1, 0x54,
};

static const u8 xt3_on_169[] = {
        0xb2, 0x66,
};

static const u8 xt3_on_170[] = {
        0xb3, 0x39,
};

static const u8 xt3_on_171[] = {
        0xc0, 0x00,
};

static const u8 xt3_on_172[] = {
        0xc1, 0x1a,
};

static const u8 xt3_on_173[] = {
        0xc2, 0x28,
};

static const u8 xt3_on_174[] = {
        0xc3, 0x13,
};

static const u8 xt3_on_175[] = {
        0xc4, 0x16,
};

static const u8 xt3_on_176[] = {
        0xc5, 0x29,
};

static const u8 xt3_on_177[] = {
        0xc6, 0x1d,
};

static const u8 xt3_on_178[] = {
        0xc7, 0x1e,
};

static const u8 xt3_on_179[] = {
        0xc8, 0x84,
};

static const u8 xt3_on_180[] = {
        0xc9, 0x1c,
};

static const u8 xt3_on_181[] = {
        0xca, 0x28,
};

static const u8 xt3_on_182[] = {
        0xcb, 0x75,
};

static const u8 xt3_on_183[] = {
        0xcc, 0x1a,
};

static const u8 xt3_on_184[] = {
        0xcd, 0x19,
};

static const u8 xt3_on_185[] = {
        0xce, 0x4d,
};

static const u8 xt3_on_186[] = {
        0xcf, 0x22,
};

static const u8 xt3_on_187[] = {
        0xd0, 0x28,
};

static const u8 xt3_on_188[] = {
        0xd1, 0x54,
};

static const u8 xt3_on_189[] = {
        0xd2, 0x66,
};

static const u8 xt3_on_190[] = {
        0xd3, 0x39,
};

static const u8 xt3_on_191[] = {
        0xff, 0x98, 0x81, 0x00,
};

static const u8 xt3_on_192[] = {
        0x35, 0x00,
};

static const u8 xt3_on_193[] = {
        0x36, 0x03,
};

static const u8 xt3_on_194[] = {
        0x11, 0x00,
};

static const u8 xt3_on_195[] = {
        0x29, 0x00,
};

static const u8 xt3_off_0[] = {
        0x28, 0x00,
};

static const u8 xt3_off_1[] = {
        0x10, 0x00,
};

static const struct xt3_dsi_cmd xt3_on_cmds[] = {
        { .dtype = 0x39, .wait = 0, .len = 4, .data = xt3_on_0 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_1 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_2 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_3 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_4 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_5 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_6 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_7 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_8 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_9 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_10 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_11 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_12 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_13 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_14 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_15 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_16 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_17 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_18 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_19 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_20 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_21 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_22 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_23 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_24 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_25 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_26 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_27 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_28 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_29 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_30 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_31 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_32 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_33 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_34 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_35 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_36 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_37 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_38 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_39 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_40 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_41 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_42 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_43 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_44 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_45 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_46 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_47 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_48 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_49 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_50 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_51 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_52 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_53 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_54 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_55 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_56 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_57 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_58 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_59 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_60 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_61 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_62 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_63 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_64 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_65 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_66 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_67 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_68 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_69 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_70 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_71 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_72 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_73 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_74 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_75 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_76 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_77 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_78 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_79 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_80 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_81 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_82 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_83 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_84 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_85 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_86 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_87 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_88 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_89 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_90 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_91 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_92 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_93 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_94 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_95 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_96 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_97 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_98 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_99 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_100 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_101 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_102 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_103 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_104 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_105 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_106 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_107 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_108 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_109 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_110 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_111 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_112 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_113 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_114 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_115 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_116 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_117 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_118 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_119 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_120 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_121 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_122 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_123 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_124 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_125 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_126 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_127 },
        { .dtype = 0x39, .wait = 0, .len = 4, .data = xt3_on_128 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_129 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_130 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_131 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_132 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_133 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_134 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_135 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_136 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_137 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_138 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_139 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_140 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_141 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_142 },
        { .dtype = 0x39, .wait = 0, .len = 4, .data = xt3_on_143 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_144 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_145 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_146 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_147 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_148 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_149 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_150 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_151 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_152 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_153 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_154 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_155 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_156 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_157 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_158 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_159 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_160 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_161 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_162 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_163 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_164 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_165 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_166 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_167 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_168 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_169 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_170 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_171 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_172 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_173 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_174 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_175 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_176 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_177 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_178 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_179 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_180 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_181 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_182 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_183 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_184 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_185 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_186 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_187 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_188 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_189 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_190 },
        { .dtype = 0x39, .wait = 0, .len = 4, .data = xt3_on_191 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_192 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_193 },
        { .dtype = 0x05, .wait = 120, .len = 2, .data = xt3_on_194 },
        { .dtype = 0x05, .wait = 20, .len = 2, .data = xt3_on_195 },
};

static const struct xt3_dsi_cmd xt3_off_cmds[] = {
        { .dtype = 0x05, .wait = 50, .len = 2, .data = xt3_off_0 },
        { .dtype = 0x05, .wait = 120, .len = 2, .data = xt3_off_1 },
};


static int xt3_send_cmds(struct mipi_dsi_device *dsi,
                         const struct xt3_dsi_cmd *cmds, size_t count)
{
        size_t i;
        int ret;

        for (i = 0; i < count; i++) {
                const struct xt3_dsi_cmd *cmd = &cmds[i];

                if (cmd->dtype == 0xff) {
                        msleep(cmd->wait);
                        continue;
                }

                switch (cmd->dtype) {
                case MIPI_DSI_DCS_SHORT_WRITE:
                case MIPI_DSI_DCS_SHORT_WRITE_PARAM:
                case MIPI_DSI_DCS_LONG_WRITE:
                        ret = mipi_dsi_dcs_write_buffer(dsi, cmd->data, cmd->len);
                        break;
                case MIPI_DSI_GENERIC_SHORT_WRITE_0_PARAM:
                case MIPI_DSI_GENERIC_SHORT_WRITE_1_PARAM:
                case MIPI_DSI_GENERIC_SHORT_WRITE_2_PARAM:
                case MIPI_DSI_GENERIC_LONG_WRITE:
                        ret = mipi_dsi_generic_write(dsi, cmd->data, cmd->len);
                        break;
                default:
                        return -EINVAL;
                }
                if (ret < 0)
                        return ret;

                if (cmd->wait)
                        msleep(cmd->wait);
        }

        return 0;
}

static int xt3_panel_prepare(struct drm_panel *panel)
{
        struct xt3_panel *ctx = to_xt3_panel(panel);
        int ret;

        if (ctx->prepared)
                return 0;

        if (ctx->power) {
                ret = regulator_enable(ctx->power);
                if (ret)
                        return ret;
        }

        gpiod_set_value_cansleep(ctx->reset_gpio, 0);
        msleep(5);
        gpiod_set_value_cansleep(ctx->reset_gpio, 1);
        msleep(10);
        gpiod_set_value_cansleep(ctx->reset_gpio, 0);
        msleep(120);

        ctx->prepared = true;
        return 0;
}

static int xt3_panel_enable(struct drm_panel *panel)
{
        struct xt3_panel *ctx = to_xt3_panel(panel);
        int ret;

        ret = xt3_send_cmds(ctx->dsi, xt3_on_cmds, ARRAY_SIZE(xt3_on_cmds));
        if (ret) {
                dev_err(&ctx->dsi->dev, "panel init misslyckades: %d\n", ret);
                return ret;
        }

        msleep(4);
        return 0;
}

static int xt3_panel_disable(struct drm_panel *panel)
{
        struct xt3_panel *ctx = to_xt3_panel(panel);

        return xt3_send_cmds(ctx->dsi, xt3_off_cmds, ARRAY_SIZE(xt3_off_cmds));
}

static int xt3_panel_unprepare(struct drm_panel *panel)
{
        struct xt3_panel *ctx = to_xt3_panel(panel);

        if (!ctx->prepared)
                return 0;

        gpiod_set_value_cansleep(ctx->reset_gpio, 0);
        if (ctx->power)
                regulator_disable(ctx->power);
        ctx->prepared = false;
        return 0;
}

static int xt3_panel_get_modes(struct drm_panel *panel,
                               struct drm_connector *connector)
{
        struct drm_display_mode *mode;

        mode = drm_mode_create(connector->dev);
        if (!mode)
                return -ENOMEM;

        mode->clock = 71128;
        mode->hdisplay = 720;
        mode->hsync_start = 780;
        mode->hsync_end = 800;
        mode->htotal = 890;
        mode->vdisplay = 1280;
        mode->vsync_start = 1304;
        mode->vsync_end = 1308;
        mode->vtotal = 1332;
        mode->width_mm = 59;
        mode->height_mm = 104;
        mode->type = DRM_MODE_TYPE_DRIVER | DRM_MODE_TYPE_PREFERRED;

        drm_mode_set_name(mode);
        drm_mode_probed_add(connector, mode);
        return 1;
}

static const struct drm_panel_funcs xt3_panel_funcs = {
        .prepare = xt3_panel_prepare,
        .enable = xt3_panel_enable,
        .disable = xt3_panel_disable,
        .unprepare = xt3_panel_unprepare,
        .get_modes = xt3_panel_get_modes,
};

static int xt3_panel_probe(struct mipi_dsi_device *dsi)
{
        struct device *dev = &dsi->dev;
        struct xt3_panel *ctx;
        int ret;

        /* Linux 7.x: drm_panel_init() ar borta, allokera via devm. */
        ctx = devm_drm_panel_alloc(dev, struct xt3_panel, panel,
                                   &xt3_panel_funcs, DRM_MODE_CONNECTOR_DSI);
        if (IS_ERR(ctx))
                return PTR_ERR(ctx);

        mipi_dsi_set_drvdata(dsi, ctx);
        ctx->dsi = dsi;

        ctx->power = devm_regulator_get_optional(dev, "power");
        if (IS_ERR(ctx->power)) {
                if (PTR_ERR(ctx->power) != -ENODEV)
                        return dev_err_probe(dev, PTR_ERR(ctx->power),
                                             "kunde inte ta power-regulator\n");
                ctx->power = NULL;
        }

        ctx->reset_gpio = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
        if (IS_ERR(ctx->reset_gpio))
                return dev_err_probe(dev, PTR_ERR(ctx->reset_gpio),
                                     "kunde inte ta reset-gpio\n");

        ctx->panel.prepare_prev_first = true;

        ret = drm_panel_of_backlight(&ctx->panel);
        if (ret)
                return ret;

        drm_panel_add(&ctx->panel);

        dsi->mode_flags = MIPI_DSI_MODE_VIDEO
                | MIPI_DSI_MODE_VIDEO_BURST
                | MIPI_DSI_MODE_VIDEO_SYNC_PULSE
                | MIPI_DSI_MODE_LPM;
        dsi->format = MIPI_DSI_FMT_RGB888;
        dsi->lanes = 4;

        return mipi_dsi_attach(dsi);
}

static void xt3_panel_remove(struct mipi_dsi_device *dsi)
{
        struct xt3_panel *ctx = mipi_dsi_get_drvdata(dsi);

        mipi_dsi_detach(dsi);
        drm_panel_remove(&ctx->panel);
}

static const struct of_device_id xt3_panel_of_match[] = {
        { .compatible = "janam,xt3-panel" },
        { }
};
MODULE_DEVICE_TABLE(of, xt3_panel_of_match);

static struct mipi_dsi_driver xt3_panel_driver = {
        .probe = xt3_panel_probe,
        .remove = xt3_panel_remove,
        .driver = {
                .name = "panel-janam-xt3",
                .of_match_table = xt3_panel_of_match,
        },
};
module_mipi_dsi_driver(xt3_panel_driver);

MODULE_AUTHOR("OpenHands");
MODULE_DESCRIPTION("ili9881d 720p video mode dsi panel");
MODULE_LICENSE("GPL");
