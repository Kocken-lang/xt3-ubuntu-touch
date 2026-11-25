1795647391483297340
	boot_cpu_init();
	page_address_init();
	pr_notice("%s", linux_banner);
	setup_arch(&command_line);
mdelay(1000);
emergency_restart();
mdelay(1000);
