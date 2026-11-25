1795647391483297340
	page_address_init();
	pr_notice("%s", linux_banner);
	setup_arch(&command_line);
mdelay(1000);
emergency_restart();
	mm_core_init_early();
	/* Static keys and static calls are needed by LSMs */
