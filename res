1795645443979231819
ROT: /home/moon/xt3/out/src/lk2nd
=== projekt (makefile):
spotless:
make-make:
all:: $(OUTBIN) $(OUTELF).lst $(OUTELF).debug.lst $(OUTELF).sym $(OUTELF).size $(OUTELF_STRIP) APPSBOOTHEADER
all:: $(EXTRA_BUILDDEPS)
clean: $(EXTRA_CLEANDEPS)
install: all
configheader:
=== project/:
aboot-surf7k.mk
aboot-surf8k.mk
apq8064.mk
apq8084.mk
armemu-test.mk
beagle-test.mk
fsm9010.mk
fsm9900.mk
lk1st-apq8084.mk
lk1st-mdm9607.mk
lk1st-mdm9640.mk
lk1st-msm8226.mk
=== target/msm8953/rules.mk (hel):
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
SCRATCH_SIZE     := 510 # 510MB

DEFINES += PMI_CONFIGURED=1
DEFINES += DISPLAY_TYPE_MIPI=1
DEFINES += DISPLAY_TYPE_DSI6G=1

MODULES += \
	dev/keys \
	dev/vib \
	lib/ptable \
	dev/pmic/pm8x41 \
	dev/pmic/pmi8994 \
	dev/qpnp_haptic \
	lib/libfdt \
	dev/qpnp_wled \
	dev/gcdb/display

DEFINES += \
	MEMSIZE=$(MEMSIZE) \
	MEMBASE=$(MEMBASE) \
	BASE_ADDR=$(BASE_ADDR) \
	SCRATCH_ADDR=$(SCRATCH_ADDR) \
	SCRATCH_SIZE=$(SCRATCH_SIZE)

OBJS += \
	$(LOCAL_DIR)/init.o \
	$(LOCAL_DIR)/meminfo.o \
	$(LOCAL_DIR)/target_display.o \
	$(LOCAL_DIR)/oem_panel.o
ifeq ($(ENABLE_SMD_SUPPORT),1)
OBJS += \
	$(LOCAL_DIR)/regulator.o
endif

ifeq ($(ENABLE_MDTP_SUPPORT),1)
OBJS += \
	$(LOCAL_DIR)/mdtp_defs.o
endif
