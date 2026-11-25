1795637715143623733
fixad
219 kommandon -> /tmp/xt3_init.c
static int janam_xt3_init(struct jadard *jadard)
{
	struct mipi_dsi_multi_context dsi_ctx = { .dsi = jadard->dsi };

	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0xe0, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0xe1, 0x93);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0xe2, 0x65);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0xe3, 0xf8);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x80, 0x03);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0xe0, 0x01);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x00, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x01, 0xd6);
...
	msleep(120);
	mipi_dsi_dcs_set_display_on_multi(&dsi_ctx);
	msleep(80);
	mipi_dsi_dcs_set_tear_on_multi(&dsi_ctx, MIPI_DSI_DCS_TEAR_MODE_VBLANK);
	msleep(50);

	return dsi_ctx.accum_err;
}
