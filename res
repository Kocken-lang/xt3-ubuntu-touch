1795646304818759348
	lk2nd \
	lk2nd/fastboot \
	lk2nd/fastboot/debug \
	lk2nd/hw/gpio \
	lk2nd/hw/i2c \
	lk2nd/ramoops \
	lk2nd/serialno \
	lk2nd/smp \
	lk2nd/smp/spin-table \
	lk2nd/version \

# Disable SMP spin table if unsupported (without throwing errors)
LK2ND_SMP_OPTIONAL := 1

ifeq ($(ENABLE_DISPLAY), 1)
ifneq ($(LK2ND_DISPLAY),)
MODULES += lk2nd/display
else
ENABLE_DISPLAY := 0
$(info NOTE: Display support is disabled without display/panel selection)
endif
endif

# Reserve 32 KiB for the log buffer so it can be accessed via fastboot
DEFINES += WITH_DEBUG_LOG_BUF=1 LK_LOG_BUF_SIZE=32768

ifeq ($(DEBUG_FBCON), 1)
	DEFINES += WITH_DEBUG_FBCON=1
endif

ifeq ($(LK2ND_FORCE_FASTBOOT), 1)
	DEFINES += LK2ND_FORCE_FASTBOOT=1
endif

# Keep the kernel command line clean when booting other operating systems
DEFINES += GENERATE_CMDLINE_ONLY_FOR_ANDROID=1
