1795637621075018279
rad 1604
static int waveshare_3_4_c_init(struct jadard *jadard)
{
	struct mipi_dsi_multi_context dsi_ctx = { .dsi = jadard->dsi };

	jd9365da_switch_page(&dsi_ctx, 0x00);
	jadard_enable_standard_cmds(&dsi_ctx);

	jd9365da_switch_page(&dsi_ctx, 0x01);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x00, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x01, 0x41);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x03, 0x10);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x04, 0x44);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x17, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x18, 0xd0);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x19, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x1a, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x1b, 0xd0);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x1c, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x24, 0xfe);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x35, 0x26);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x37, 0x09);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x38, 0x04);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x39, 0x08);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x3a, 0x0a);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x3c, 0x78);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x3d, 0xff);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x3e, 0xff);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x3f, 0xff);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x40, 0x00);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x41, 0x64);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x42, 0xc7);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x43, 0x18);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x44, 0x0b);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x45, 0x14);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x55, 0x02);
	mipi_dsi_dcs_write_seq_multi(&dsi_ctx, 0x57, 0x49);
