1795637603208520812
	mipi_dsi_dcs_set_display_on_multi(&dsi_ctx);
	msleep(60);

	return 0;
}

static const struct drm_display_mode waveshare_8_0_a_mode = {
	.clock		= (800 + 40 + 20 + 20) * (1280 + 30 + 12 + 4) * 60 / 1000,

	.hdisplay	= 800,
	.hsync_start	= 800 + 40,
	.hsync_end	= 800 + 40 + 20,
	.htotal		= 800 + 40 + 20 + 20,

	.vdisplay	= 1280,
	.vsync_start	= 1280 + 30,
	.vsync_end	= 1280 + 30 + 12,
	.vtotal		= 1280 + 30 + 12 + 4,

	.width_mm	= 107,
	.height_mm	= 172,
	.type		= DRM_MODE_TYPE_DRIVER | DRM_MODE_TYPE_PREFERRED,
};

static const struct jadard_panel_desc waveshare_8_0_inch_a_desc = {
	.mode_4ln = &waveshare_8_0_a_mode,
	.mode_2ln = &waveshare_8_0_a_mode,
	.format = MIPI_DSI_FMT_RGB888,
	.init = waveshare_8_0_a_init,
	.mode_flags = MIPI_DSI_MODE_VIDEO_HSE | MIPI_DSI_MODE_VIDEO |
		      MIPI_DSI_MODE_LPM | MIPI_DSI_CLOCK_NON_CONTINUOUS,
};

static int waveshare_10_1_b_init(struct jadard *jadard);

static const struct jadard_panel_desc waveshare_9_0_inch_b_desc = {
	.mode_4ln = &(const struct drm_display_mode) {
		.clock		= (720 + 60 + 60 + 4) * (1280 + 16 + 12 + 4) * 60 / 1000,

		.hdisplay	= 720,
		.hsync_start	= 720 + 60,
		.hsync_end	= 720 + 60 + 60,
		.htotal		= 720 + 60 + 60 + 4,

		.vdisplay	= 1280,
		.vsync_start	= 1280 + 16,
=== init-makro:
