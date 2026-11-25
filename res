1795643782601240415
total 80
drwxrwxr-x 3 moon moon  4096 Nov 24 19:06 include
-rw-rw-r-- 1 moon moon 22924 Nov 24 19:06 init.c
-rw-rw-r-- 1 moon moon  2092 Nov 24 19:06 mdtp_defs.c
-rw-rw-r-- 1 moon moon  2763 Nov 24 19:06 meminfo.c
-rw-rw-r-- 1 moon moon 15034 Nov 24 19:06 oem_panel.c
-rwxrwxr-x 1 moon moon  3607 Nov 24 19:06 regulator.c
-rw-rw-r-- 1 moon moon  1213 Nov 24 19:06 rules.mk
-rw-rw-r-- 1 moon moon 13015 Nov 24 19:06 target_display.c
drwxrwxr-x 2 moon moon  4096 Nov 24 19:06 tools
=== rules.mk:
LOCAL_DIR := $(GET_LOCAL_DIR)

INCLUDES += -I$(LOCAL_DIR)/include -I$(LK_TOP_DIR)/platform/msm_shared

INCLUDES += -I$(LK_TOP_DIR)/dev/gcdb/display -I$(LK_TOP_DIR)/dev/gcdb/display/include

INCLUDES += -I$(LK_TOP_DIR)/app/aboot

PLATFORM := msm8953

MEMBASE := 0x8F600000 # SDRAM
MEMSIZE := 0x00A00000 # 10MB

ifneq (,$(findstring SECURE_CODE_MEM,$(DEFINES)))
MEMRWOFF:= 0x8F700000 # MEMBASE + 1MB(section page size)
DEFINES += MEMRWOFF=$(MEMRWOFF)
endif

BASE_ADDR        := 0x80000000
SCRATCH_ADDR     := 0xA0100000
