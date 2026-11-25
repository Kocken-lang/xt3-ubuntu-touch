1795613044912582109
Bus 001 Device 027: ID 18d1:d00d Google Inc. Xiaomi Mi/Redmi 2 (fastboot)
2303910504	 fastboot

Finished. Total time: 0.001s
=== fastboot -w:
Erasing 'userdata'                                 OKAY [  0.523s]
mke2fs 1.47.2 (1-Jan-2025)
/tmp/TemporaryFile-sUdJl1: Unimplemented ext2 library function while setting up superblock
/usr/lib/android-sdk/platform-tools/mke2fs failed with status 1
fastboot: error: Cannot generate image for userdata
=== mke2fs-argument:
-t ext4 -b 4096 -E android_sparse,stride=2,stripe-width=2 -O uninit_bg /tmp/TemporaryFile-sUdJl1 12825595
