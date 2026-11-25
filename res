1795637150623436740
emkit.h                  1014 byte
emkit_info.h             3663 byte
mandata.h               17404 byte
module_names.txt         3402 byte
Kconfig                   267 byte
Makefile                   41 byte
emkit_info.c             8101 byte
=== Kconfig:
config EMKIT_INFO
	tristate "Detect modules for EMKIT"
	help
	  Say Y here if you want to generate a sysfs entry for
	  detecting module on Android.

	  If unsure, say N.

	  To compile this driver as a module, choose M here: the
	  module will be called emkit_info.
