1795637168994040194
 
267 Kconfig
41 Makefile
1014 emkit.h
8101 emkit_info.c
3663 emkit_info.h
17404 mandata.h
3402 module_names.txt
=== emkit_info.c (nyckeldelar):
16:#include <linux/of_gpio.h>
28:	.gpio_phone_id = -1,
29:	.gpio_key_id = -1,
31:	.board_revision = HW_REV_DEF,
32:	.board_model_name = {0,},
33:	.board_title_name = {0,},
37:static int __init get_android_boot_hardware_revision(char *str)
39:	get_option(&str, &g_emkit_info.board_revision);
40:	EMLOG("DETECT: REVISION = %d", g_emkit_info.board_revision);
43:__setup("androidboot.hardware.revision=", get_android_boot_hardware_revision);
47:	g_emkit_info.board_revision = hw_rev;
48:	EMLOG("DETECT: REVISION = %d", g_emkit_info.board_revision);
54:	pr_info("board_revision:%d\n", g_emkit_info.board_revision);
55:	return g_emkit_info.board_revision;
68:	return GetGpioValue(g_emkit_info.gpio_phone_id, "gpio_phone_id");
72:static void board_check_cpu(void)
132:INFO_FUNC(g_emkit_info.board_module_name[MODULE_CPU], emkit_cpu);
153:	__ATTR(emkit_cpu, S_IRUGO|S_IWUSR|S_IWGRP, emkit_cpu_show, emkit_cpu_store),
193:		ret = sysfs_create_file(g_emkit_info.kobj, &emkit_attrs[i].attr);
195:			EMLOG("sysfs_create_group() failed! (ret=%d)", ret);
196:			goto err_create_sysfs;
200:	board_check_cpu();
205:err_create_sysfs:
215:		sysfs_remove_file(g_emkit_info.kobj, &emkit_attrs[i].attr);
