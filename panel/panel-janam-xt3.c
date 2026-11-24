// SPDX-License-Identifier: GPL-2.0-only
/*
 * jd9365da 720p video mode dsi panel
 *
 * GENERERAD av scripts/13-panel-from-dtb.py ur qcom,mdss_dsi_jd9365da_720p_video.
 * Redigera inte for hand: kor om generatorn nar DTB:n andras.
 *
 * Panel:    720x1280 @ 60 Hz, 24 bpp, 4 lanes
 * Typ:      dsi_video_mode
 * Timing:   h 27/18/23  v 13/7/11
 * Klocka:   61984 kHz
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
        0xe0, 0x00,
};

static const u8 xt3_on_1[] = {
        0xe1, 0x93,
};

static const u8 xt3_on_2[] = {
        0xe2, 0x65,
};

static const u8 xt3_on_3[] = {
        0xe3, 0xf8,
};

static const u8 xt3_on_4[] = {
        0x80, 0x03,
};

static const u8 xt3_on_5[] = {
        0xe0, 0x01,
};

static const u8 xt3_on_6[] = {
        0x00, 0x00,
};

static const u8 xt3_on_7[] = {
        0x01, 0xd6,
};

static const u8 xt3_on_8[] = {
        0x03, 0x00,
};

static const u8 xt3_on_9[] = {
        0x04, 0xe7,
};

static const u8 xt3_on_10[] = {
        0x0c, 0x66,
};

static const u8 xt3_on_11[] = {
        0x17, 0x00,
};

static const u8 xt3_on_12[] = {
        0x18, 0xef,
};

static const u8 xt3_on_13[] = {
        0x19, 0x01,
};

static const u8 xt3_on_14[] = {
        0x1a, 0x00,
};

static const u8 xt3_on_15[] = {
        0x1b, 0xef,
};

static const u8 xt3_on_16[] = {
        0x1c, 0x01,
};

static const u8 xt3_on_17[] = {
        0x1f, 0x6b,
};

static const u8 xt3_on_18[] = {
        0x20, 0x24,
};

static const u8 xt3_on_19[] = {
        0x21, 0x24,
};

static const u8 xt3_on_20[] = {
        0x22, 0x4e,
};

static const u8 xt3_on_21[] = {
        0x24, 0xfe,
};

static const u8 xt3_on_22[] = {
        0x37, 0x09,
};

static const u8 xt3_on_23[] = {
        0x38, 0x04,
};

static const u8 xt3_on_24[] = {
        0x39, 0x08,
};

static const u8 xt3_on_25[] = {
        0x3a, 0x12,
};

static const u8 xt3_on_26[] = {
        0x3c, 0x78,
};

static const u8 xt3_on_27[] = {
        0x3d, 0xff,
};

static const u8 xt3_on_28[] = {
        0x3e, 0xff,
};

static const u8 xt3_on_29[] = {
        0x3f, 0x7f,
};

static const u8 xt3_on_30[] = {
        0x40, 0x04,
};

static const u8 xt3_on_31[] = {
        0x41, 0xa0,
};

static const u8 xt3_on_32[] = {
        0x43, 0x0f,
};

static const u8 xt3_on_33[] = {
        0x44, 0x17,
};

static const u8 xt3_on_34[] = {
        0x45, 0x46,
};

static const u8 xt3_on_35[] = {
        0x55, 0x02,
};

static const u8 xt3_on_36[] = {
        0x56, 0x01,
};

static const u8 xt3_on_37[] = {
        0x57, 0x49,
};

static const u8 xt3_on_38[] = {
        0x58, 0x00,
};

static const u8 xt3_on_39[] = {
        0x59, 0x20,
};

static const u8 xt3_on_40[] = {
        0x5a, 0x70,
};

static const u8 xt3_on_41[] = {
        0x5b, 0x0d,
};

static const u8 xt3_on_42[] = {
        0x5d, 0x57,
};

static const u8 xt3_on_43[] = {
        0x5e, 0x4a,
};

static const u8 xt3_on_44[] = {
        0x5f, 0x3f,
};

static const u8 xt3_on_45[] = {
        0x60, 0x36,
};

static const u8 xt3_on_46[] = {
        0x61, 0x36,
};

static const u8 xt3_on_47[] = {
        0x62, 0x28,
};

static const u8 xt3_on_48[] = {
        0x63, 0x2f,
};

static const u8 xt3_on_49[] = {
        0x64, 0x1b,
};

static const u8 xt3_on_50[] = {
        0x65, 0x34,
};

static const u8 xt3_on_51[] = {
        0x66, 0x33,
};

static const u8 xt3_on_52[] = {
        0x67, 0x32,
};

static const u8 xt3_on_53[] = {
        0x68, 0x4f,
};

static const u8 xt3_on_54[] = {
        0x69, 0x3c,
};

static const u8 xt3_on_55[] = {
        0x6a, 0x43,
};

static const u8 xt3_on_56[] = {
        0x6b, 0x35,
};

static const u8 xt3_on_57[] = {
        0x6c, 0x31,
};

static const u8 xt3_on_58[] = {
        0x6d, 0x24,
};

static const u8 xt3_on_59[] = {
        0x6e, 0x15,
};

static const u8 xt3_on_60[] = {
        0x6f, 0x09,
};

static const u8 xt3_on_61[] = {
        0x70, 0x57,
};

static const u8 xt3_on_62[] = {
        0x71, 0x4a,
};

static const u8 xt3_on_63[] = {
        0x72, 0x3f,
};

static const u8 xt3_on_64[] = {
        0x73, 0x36,
};

static const u8 xt3_on_65[] = {
        0x74, 0x36,
};

static const u8 xt3_on_66[] = {
        0x75, 0x28,
};

static const u8 xt3_on_67[] = {
        0x76, 0x2f,
};

static const u8 xt3_on_68[] = {
        0x77, 0x1b,
};

static const u8 xt3_on_69[] = {
        0x78, 0x34,
};

static const u8 xt3_on_70[] = {
        0x79, 0x33,
};

static const u8 xt3_on_71[] = {
        0x7a, 0x32,
};

static const u8 xt3_on_72[] = {
        0x7b, 0x4f,
};

static const u8 xt3_on_73[] = {
        0x7c, 0x3c,
};

static const u8 xt3_on_74[] = {
        0x7d, 0x43,
};

static const u8 xt3_on_75[] = {
        0x7e, 0x35,
};

static const u8 xt3_on_76[] = {
        0x7f, 0x31,
};

static const u8 xt3_on_77[] = {
        0x80, 0x24,
};

static const u8 xt3_on_78[] = {
        0x81, 0x15,
};

static const u8 xt3_on_79[] = {
        0x82, 0x09,
};

static const u8 xt3_on_80[] = {
        0xe0, 0x02,
};

static const u8 xt3_on_81[] = {
        0x00, 0x5e,
};

static const u8 xt3_on_82[] = {
        0x01, 0x5f,
};

static const u8 xt3_on_83[] = {
        0x02, 0x57,
};

static const u8 xt3_on_84[] = {
        0x03, 0x58,
};

static const u8 xt3_on_85[] = {
        0x04, 0x48,
};

static const u8 xt3_on_86[] = {
        0x05, 0x4a,
};

static const u8 xt3_on_87[] = {
        0x06, 0x44,
};

static const u8 xt3_on_88[] = {
        0x07, 0x46,
};

static const u8 xt3_on_89[] = {
        0x08, 0x40,
};

static const u8 xt3_on_90[] = {
        0x09, 0x5f,
};

static const u8 xt3_on_91[] = {
        0x0a, 0x42,
};

static const u8 xt3_on_92[] = {
        0x0b, 0x5f,
};

static const u8 xt3_on_93[] = {
        0x0c, 0x5f,
};

static const u8 xt3_on_94[] = {
        0x0d, 0x5f,
};

static const u8 xt3_on_95[] = {
        0x0e, 0x5f,
};

static const u8 xt3_on_96[] = {
        0x0f, 0x5f,
};

static const u8 xt3_on_97[] = {
        0x10, 0x5f,
};

static const u8 xt3_on_98[] = {
        0x11, 0x5f,
};

static const u8 xt3_on_99[] = {
        0x12, 0x5f,
};

static const u8 xt3_on_100[] = {
        0x13, 0x5f,
};

static const u8 xt3_on_101[] = {
        0x14, 0x5f,
};

static const u8 xt3_on_102[] = {
        0x15, 0x5f,
};

static const u8 xt3_on_103[] = {
        0x16, 0x5e,
};

static const u8 xt3_on_104[] = {
        0x17, 0x5f,
};

static const u8 xt3_on_105[] = {
        0x18, 0x57,
};

static const u8 xt3_on_106[] = {
        0x19, 0x58,
};

static const u8 xt3_on_107[] = {
        0x1a, 0x49,
};

static const u8 xt3_on_108[] = {
        0x1b, 0x4b,
};

static const u8 xt3_on_109[] = {
        0x1c, 0x45,
};

static const u8 xt3_on_110[] = {
        0x1d, 0x47,
};

static const u8 xt3_on_111[] = {
        0x1e, 0x41,
};

static const u8 xt3_on_112[] = {
        0x1f, 0x5f,
};

static const u8 xt3_on_113[] = {
        0x20, 0x43,
};

static const u8 xt3_on_114[] = {
        0x21, 0x5f,
};

static const u8 xt3_on_115[] = {
        0x22, 0x5f,
};

static const u8 xt3_on_116[] = {
        0x23, 0x5f,
};

static const u8 xt3_on_117[] = {
        0x24, 0x5f,
};

static const u8 xt3_on_118[] = {
        0x25, 0x5f,
};

static const u8 xt3_on_119[] = {
        0x26, 0x5f,
};

static const u8 xt3_on_120[] = {
        0x27, 0x5f,
};

static const u8 xt3_on_121[] = {
        0x28, 0x5f,
};

static const u8 xt3_on_122[] = {
        0x29, 0x5f,
};

static const u8 xt3_on_123[] = {
        0x2a, 0x5f,
};

static const u8 xt3_on_124[] = {
        0x2b, 0x5f,
};

static const u8 xt3_on_125[] = {
        0x2c, 0x1f,
};

static const u8 xt3_on_126[] = {
        0x2d, 0x1e,
};

static const u8 xt3_on_127[] = {
        0x2e, 0x17,
};

static const u8 xt3_on_128[] = {
        0x2f, 0x18,
};

static const u8 xt3_on_129[] = {
        0x30, 0x07,
};

static const u8 xt3_on_130[] = {
        0x31, 0x05,
};

static const u8 xt3_on_131[] = {
        0x32, 0x0b,
};

static const u8 xt3_on_132[] = {
        0x33, 0x09,
};

static const u8 xt3_on_133[] = {
        0x34, 0x03,
};

static const u8 xt3_on_134[] = {
        0x35, 0x1f,
};

static const u8 xt3_on_135[] = {
        0x36, 0x01,
};

static const u8 xt3_on_136[] = {
        0x37, 0x1f,
};

static const u8 xt3_on_137[] = {
        0x38, 0x1f,
};

static const u8 xt3_on_138[] = {
        0x39, 0x1f,
};

static const u8 xt3_on_139[] = {
        0x3a, 0x1f,
};

static const u8 xt3_on_140[] = {
        0x3b, 0x1f,
};

static const u8 xt3_on_141[] = {
        0x3c, 0x1f,
};

static const u8 xt3_on_142[] = {
        0x3d, 0x1f,
};

static const u8 xt3_on_143[] = {
        0x3e, 0x1f,
};

static const u8 xt3_on_144[] = {
        0x3f, 0x1f,
};

static const u8 xt3_on_145[] = {
        0x40, 0x1f,
};

static const u8 xt3_on_146[] = {
        0x41, 0x1f,
};

static const u8 xt3_on_147[] = {
        0x42, 0x1f,
};

static const u8 xt3_on_148[] = {
        0x43, 0x1e,
};

static const u8 xt3_on_149[] = {
        0x44, 0x17,
};

static const u8 xt3_on_150[] = {
        0x45, 0x18,
};

static const u8 xt3_on_151[] = {
        0x46, 0x06,
};

static const u8 xt3_on_152[] = {
        0x47, 0x04,
};

static const u8 xt3_on_153[] = {
        0x48, 0x0a,
};

static const u8 xt3_on_154[] = {
        0x49, 0x08,
};

static const u8 xt3_on_155[] = {
        0x4a, 0x02,
};

static const u8 xt3_on_156[] = {
        0x4b, 0x1f,
};

static const u8 xt3_on_157[] = {
        0x4c, 0x00,
};

static const u8 xt3_on_158[] = {
        0x4d, 0x1f,
};

static const u8 xt3_on_159[] = {
        0x4e, 0x1f,
};

static const u8 xt3_on_160[] = {
        0x4f, 0x1f,
};

static const u8 xt3_on_161[] = {
        0x50, 0x1f,
};

static const u8 xt3_on_162[] = {
        0x51, 0x1f,
};

static const u8 xt3_on_163[] = {
        0x52, 0x1f,
};

static const u8 xt3_on_164[] = {
        0x53, 0x1f,
};

static const u8 xt3_on_165[] = {
        0x54, 0x1f,
};

static const u8 xt3_on_166[] = {
        0x55, 0x1f,
};

static const u8 xt3_on_167[] = {
        0x56, 0x1f,
};

static const u8 xt3_on_168[] = {
        0x57, 0x1f,
};

static const u8 xt3_on_169[] = {
        0x58, 0x40,
};

static const u8 xt3_on_170[] = {
        0x59, 0x00,
};

static const u8 xt3_on_171[] = {
        0x5a, 0x00,
};

static const u8 xt3_on_172[] = {
        0x5b, 0x30,
};

static const u8 xt3_on_173[] = {
        0x5c, 0x0d,
};

static const u8 xt3_on_174[] = {
        0x5d, 0x30,
};

static const u8 xt3_on_175[] = {
        0x5e, 0x01,
};

static const u8 xt3_on_176[] = {
        0x5f, 0x02,
};

static const u8 xt3_on_177[] = {
        0x60, 0x20,
};

static const u8 xt3_on_178[] = {
        0x61, 0x01,
};

static const u8 xt3_on_179[] = {
        0x62, 0x02,
};

static const u8 xt3_on_180[] = {
        0x63, 0x03,
};

static const u8 xt3_on_181[] = {
        0x64, 0x5e,
};

static const u8 xt3_on_182[] = {
        0x65, 0x35,
};

static const u8 xt3_on_183[] = {
        0x66, 0x16,
};

static const u8 xt3_on_184[] = {
        0x67, 0x73,
};

static const u8 xt3_on_185[] = {
        0x68, 0x11,
};

static const u8 xt3_on_186[] = {
        0x69, 0x03,
};

static const u8 xt3_on_187[] = {
        0x6a, 0x5e,
};

static const u8 xt3_on_188[] = {
        0x6b, 0x08,
};

static const u8 xt3_on_189[] = {
        0x6c, 0x00,
};

static const u8 xt3_on_190[] = {
        0x6d, 0x00,
};

static const u8 xt3_on_191[] = {
        0x6e, 0x00,
};

static const u8 xt3_on_192[] = {
        0x6f, 0x88,
};

static const u8 xt3_on_193[] = {
        0x70, 0x00,
};

static const u8 xt3_on_194[] = {
        0x71, 0x00,
};

static const u8 xt3_on_195[] = {
        0x72, 0x06,
};

static const u8 xt3_on_196[] = {
        0x73, 0x7b,
};

static const u8 xt3_on_197[] = {
        0x74, 0x00,
};

static const u8 xt3_on_198[] = {
        0x75, 0xbc,
};

static const u8 xt3_on_199[] = {
        0x76, 0x00,
};

static const u8 xt3_on_200[] = {
        0x77, 0x0d,
};

static const u8 xt3_on_201[] = {
        0x78, 0x28,
};

static const u8 xt3_on_202[] = {
        0x79, 0x00,
};

static const u8 xt3_on_203[] = {
        0x7a, 0x00,
};

static const u8 xt3_on_204[] = {
        0x7b, 0x00,
};

static const u8 xt3_on_205[] = {
        0x7c, 0x00,
};

static const u8 xt3_on_206[] = {
        0x7d, 0x03,
};

static const u8 xt3_on_207[] = {
        0x7e, 0x7b,
};

static const u8 xt3_on_208[] = {
        0xe0, 0x00,
};

static const u8 xt3_on_209[] = {
        0xe6, 0x02,
};

static const u8 xt3_on_210[] = {
        0xe7, 0x02,
};

static const u8 xt3_on_211[] = {
        0xe0, 0x00,
};

static const u8 xt3_on_212[] = {
        0x00, 0x0e,
};

static const u8 xt3_on_213[] = {
        0x02, 0xb3,
};

static const u8 xt3_on_214[] = {
        0x09, 0x60,
};

static const u8 xt3_on_215[] = {
        0xe0, 0x00,
};

static const u8 xt3_on_216[] = {
        0x11, 0x00,
};

static const u8 xt3_on_217[] = {
        0x29, 0x00,
};

static const u8 xt3_on_218[] = {
        0x35, 0x00,
};

static const u8 xt3_off_0[] = {
        0x28, 0x00,
};

static const u8 xt3_off_1[] = {
        0x10, 0x00,
};

static const struct xt3_dsi_cmd xt3_on_cmds[] = {
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_0 },
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
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_128 },
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
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_143 },
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
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_191 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_192 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_193 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_194 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_195 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_196 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_197 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_198 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_199 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_200 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_201 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_202 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_203 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_204 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_205 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_206 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_207 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_208 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_209 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_210 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_211 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_212 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_213 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_214 },
        { .dtype = 0x39, .wait = 0, .len = 2, .data = xt3_on_215 },
        { .dtype = 0x05, .wait = 120, .len = 2, .data = xt3_on_216 },
        { .dtype = 0x05, .wait = 80, .len = 2, .data = xt3_on_217 },
        { .dtype = 0x05, .wait = 50, .len = 2, .data = xt3_on_218 },
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
        msleep(20);

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

        mode->clock = 61984;
        mode->hdisplay = 720;
        mode->hsync_start = 747;
        mode->hsync_end = 765;
        mode->htotal = 788;
        mode->vdisplay = 1280;
        mode->vsync_start = 1293;
        mode->vsync_end = 1300;
        mode->vtotal = 1311;
        mode->width_mm = 62;
        mode->height_mm = 110;
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
MODULE_DESCRIPTION("jd9365da 720p video mode dsi panel");
MODULE_LICENSE("GPL");
