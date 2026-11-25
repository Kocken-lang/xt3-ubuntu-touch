1795633053996076723
=== init.solution.rc:
###[ADD][EMKIT]### Apply scanner permissions by Models.
import /vendor/etc/init/hw/init.scanner.rc
###[END][EMKIT]###

on post-fs-data
# create directory for ProgramButtons app by james.jo
	mkdir /data/system/devices 0755 system system
	chown system system /data/system/devices
	mkdir /data/system/devices/keychars 0755 system system
	chown system system /data/system/devices/keychars

# change permissions for MSR by vincent.hwang
    chmod 0664 /dev/msr_spidev
    chown system system /dev/msr_spidev

# change permissions for mfg by vincent.hwang
    chmod 0660 /dev/block/mmcblk0p4
    chown system system /dev/block/mmcblk0p4

# change permissions for bootlogo changer by vincent.hwang
    chmod 0660 /dev/block/mmcblk0p29
    chown system system /dev/block/mmcblk0p29

# change permissions for wifi detail settings by vincent.hwang
    chmod 0664 /data/misc/wifi/WCNSS_qcom_cfg.ini
    chown system wifi /data/misc/wifi/WCNSS_qcom_cfg.ini

# change permissions for vibrate intensity settings by vincent.hwang
    chmod 0664 /sys/class/timed_output/vibrator/level
    chown system system /sys/class/timed_output/vibrator/level

=== emkit-modul i vendor:
=== /sys/emkit-namn (fran modulens strings):
