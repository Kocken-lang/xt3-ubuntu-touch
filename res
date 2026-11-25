1795646324445927374
 237352	  63548	 224760	 525660	  8055c	build-lk2nd-sdm660/lk
arm-none-eabi-objcopy -O binary build-lk2nd-sdm660/lk build-lk2nd-sdm660/lk.bin
generating size map: build-lk2nd-sdm660/lk.size
generating stripped elf: build-lk2nd-sdm660/lk_s.elf
generating image with 20 appended DTBs: build-lk2nd-sdm660/lk.bin-dtb
cp -f ./build-lk2nd-sdm660/lk_s.elf ./build-lk2nd-sdm660/emmc_appsboot.mbn
generating Android boot image: build-lk2nd-sdm660/lk2nd.img
make[1]: Leaving directory '/home/moon/xt3/out/src/lk2nd'
