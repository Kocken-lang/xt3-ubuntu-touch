1795646239730394689
=== LK2ND_FORCE_FASTBOOT:
./app/aboot/aboot.c:5643:#if LK2ND_FORCE_FASTBOOT
./lk2nd/project/base.mk:55:ifeq ($(LK2ND_FORCE_FASTBOOT), 1)
./lk2nd/project/base.mk:56:	DEFINES += LK2ND_FORCE_FASTBOOT=1
=== DEBUG_FBCON:
./platform/msm_shared/debug.c:144:#if WITH_DEBUG_FBCON && WITH_DEV_FBCON
./project/msm7627_surf_nandwrite.mk:13:#DEFINES += WITH_DEBUG_FBCON=1
./project/apq8064.mk:17:#DEFINES += WITH_DEBUG_FBCON=1
=== fastboot oem log:
lk2nd/fastboot/misc.c:9:static void cmd_oem_log(const char *arg, void *data, unsigned sz)
lk2nd/fastboot/misc.c:13:FASTBOOT_REGISTER("oem log", cmd_oem_log);
