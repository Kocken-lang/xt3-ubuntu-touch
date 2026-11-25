1795637643121188623
81:		mipi_dsi_msleep(&dsi_ctx, jadard->desc->backlight_off_to_display_off_delay_ms);
86:		mipi_dsi_msleep(&dsi_ctx, jadard->desc->display_off_to_enter_sleep_delay_ms);
91:		mipi_dsi_msleep(&dsi_ctx, jadard->desc->enter_sleep_to_reset_down_delay_ms);
96:static int jadard_prepare(struct drm_panel *panel)
110:		msleep(jadard->desc->vcioo_to_lp11_delay_ms);
119:		msleep(jadard->desc->lp11_to_reset_delay_ms);
122:	msleep(5);
125:	msleep(10);
128:	msleep(130);
142:	msleep(120);
357:	mipi_dsi_msleep(&dsi_ctx, 120);
589:	mipi_dsi_msleep(&dsi_ctx, 120);
=== slutet av en init-funktion:
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x6e, 0x04);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x6f, 0x88);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x75, 0xd9);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x76, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x77, 0x33);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x78, 0x43);

	jd9365da_switch_page(&dsi_ctx, 0x00);

	mipi_dsi_dcs_exit_sleep_mode_multi(&dsi_ctx);
	msleep(120);
	mipi_dsi_dcs_set_display_on_multi(&dsi_ctx);
	msleep(5);
	mipi_dsi_dcs_set_tear_on_multi(&dsi_ctx, MIPI_DSI_DCS_TEAR_MODE_VBLANK);

	return dsi_ctx.accum_err;
}

static const struct jadard_panel_desc waveshare_3_4_inch_c_desc = {
	.mode_2ln = &(const struct drm_display_mode) {
		.clock		= (800 + 40 + 20 + 20) * (800 + 24 + 4 + 12) * 60 / 1000,
