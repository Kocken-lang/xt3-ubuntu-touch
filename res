1795645585475786106
project/sdm660.mk skapad
linking build-lk2nd-sdm660/lk
generating listing: build-lk2nd-sdm660/lk.debug.lst
generating symbols: build-lk2nd-sdm660/lk.sym
generating listing: build-lk2nd-sdm660/lk.lst
generating image: build-lk2nd-sdm660/lk.bin
   text	   data	    bss	    dec	    hex	filename
 236312	  60744	 224772	 521828	  7f664	build-lk2nd-sdm660/lk
arm-none-eabi-objcopy -O binary build-lk2nd-sdm660/lk build-lk2nd-sdm660/lk.bin
generating size map: build-lk2nd-sdm660/lk.size
generating stripped elf: build-lk2nd-sdm660/lk_s.elf
generating image with 20 appended DTBs: build-lk2nd-sdm660/lk.bin-dtb
cp -f ./build-lk2nd-sdm660/lk_s.elf ./build-lk2nd-sdm660/emmc_appsboot.mbn
generating Android boot image: build-lk2nd-sdm660/lk2nd.img
make[1]: Leaving directory '/home/moon/xt3/out/src/lk2nd'
