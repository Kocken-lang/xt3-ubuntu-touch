1795632221399022091
### vendor:
Verifying image out/fota/partitions/vendor.img using embedded public key
vbmeta: Successfully verified footer and NONE vbmeta struct in out/fota/partitions/vendor.img
vendor: Successfully verified sha1 hashtree of out/fota/partitions/vendor.img for image of 825540608 bytes
### dtbo:
Verifying image out/fota/partitions/dtbo.img using embedded public key
vbmeta: Successfully verified footer and NONE vbmeta struct in out/fota/partitions/dtbo.img
dtbo: Successfully verified sha256 hash of out/fota/partitions/dtbo.img for image of 499382 bytes

### boot header (AOSP):
boot magic: ANDROID!
kernel_size: 14679524
kernel load address: 0x00008000
ramdisk size: 8388670
ramdisk load address: 0x01000000
second bootloader size: 0
second bootloader load address: 0x00000000
kernel tags load address: 0x00000100
page size: 4096
os version: 11.0.0
os patch level: 2025-08
boot image header version: 2
product name: 
command line args: console=ttyMSM0,115200,n8 androidboot.console=ttyMSM0 earlycon=msm_serial_dm,0xc170000 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 sched_enable_hmp=1 sched_enable_power_aware=1 service_locator.enable=1 loop.max_part=7 buildvariant=user
additional command line args: 
recovery dtbo size: 0
recovery dtbo offset: 0x0000000000000000
boot header size: 1660
dtb size: 802464
dtb address: 0x0000000001f00000

### fstab i vendor:
# Android fstab file.
# The filesystem that contains the filesystem checker binary (typically /system) cannot
# specify MF_CHECK, and must come before any filesystems that do specify MF_CHECK

#TODO: Add 'check' as fs_mgr_flags with data partition.
# Currently we dont have e2fsck compiled. So fs check would failed.

# A/B fstab.qcom variant
#<src>                                   <mnt_point>           <type> <mnt_flags and options>                          <fs_mgr_flags>
/dev/block/bootdevice/by-name/system     /                     ext4   ro,barrier=1,discard                             wait,slotselect,avb
/dev/block/bootdevice/by-name/userdata   /data                 ext4   nosuid,nodev,barrier=1,noauto_da_alloc,discard,noatime,lazytime   wait,check,fileencryption=ice,quota,reservedsize=128M
/devices/platform/soc/c084000.sdhci/mmc_host*     /storage/sdcard1      vfat   nosuid,nodev                                     wait,voldmanaged=sdcard1:auto
/dev/block/bootdevice/by-name/misc       /misc                 emmc   defaults                                         defaults
/dev/block/bootdevice/by-name/modem      /vendor/firmware_mnt  vfat   ro,shortname=lower,uid=1000,gid=1000,dmask=227,fmask=337,context=u:object_r:firmware_file:s0 wait,slotselect
/dev/block/bootdevice/by-name/bluetooth  /vendor/bt_firmware   vfat   ro,shortname=lower,uid=1002,gid=3002,dmask=227,fmask=337,context=u:object_r:bt_firmware_file:s0 wait,slotselect
/devices/platform/soc/a800000.ssusb/a800000.dwc3/xhci-hcd.0.auto*     /storage/usbotg    vfat    nosuid,nodev         wait,voldmanaged=usbotg:auto
/dev/block/bootdevice/by-name/dsp        /vendor/dsp           ext4   ro,nosuid,nodev,barrier=1                        wait,slotselect
/dev/block/bootdevice/by-name/persist    /mnt/vendor/persist   ext4   noatime,nosuid,nodev,barrier=1                   wait
/dev/block/bootdevice/by-name/pmobile      /enterprise        ext4    noatime,nosuid,nodev,barrier=1,data=ordered  wait,formattable,nofail
#/devices/platform/soc/c200000.hsusb/c200000.dwc3/xhci-hcd.0.auto*     /storage/usbotg    vfat    nosuid,nodev         wait,voldmanaged=usbotg:auto
