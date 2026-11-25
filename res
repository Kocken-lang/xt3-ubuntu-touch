1795649497636283383
=== flash.sh partitioner:
# Temporary unlock fastboot flash for flashing locked unit
fastboot oem unlock-flash
#flash partition gpt_both0.bin
    flash modem_a NON-HLOS_SDA.bin
    flash modem_b NON-HLOS_SDA.bin
    flash modem_a NON-HLOS_SDM.bin
    flash modem_b NON-HLOS_SDM.bin
flash bluetooth_a BTFM.bin
flash bluetooth_b BTFM.bin
flash devcfg_a devcfg.mbn
flash devcfg_b devcfg.mbn
flash dsp_a dspso.bin
flash dsp_b dspso.bin
flash xbl_a xbl.elf
flash xbl_b xbl.elf
flash pmic_a pmic.elf
flash pmic_b pmic.elf
flash rpm_a rpm.mbn
flash rpm_b rpm.mbn
flash tz_a tz.mbn
flash tz_b tz.mbn
flash hyp_a hyp.mbn
flash hyp_b hyp.mbn
flash keymaster_a km4.mbn
flash keymaster_b km4.mbn
flash cmnlib64_a cmnlib64.mbn
flash cmnlib64_b cmnlib64.mbn
flash cmnlib_a cmnlib.mbn
flash cmnlib_b cmnlib.mbn
flash storsec storsec.mbn

=== sdm660-loaders:
total 2456
drwxr-xr-x  2 root root   4096 Nov 22 12:48 .
drwxr-xr-x 40 root root   4096 Nov 22 12:48 ..
-rw-r--r--  1 root root 629216 Nov 22 12:48 3006000000010000_54736aebeaaf4167_fhprg.bin
-rw-r--r--  1 root root 633952 Nov 22 12:48 3006000000010000_7e425bcb25364725_fhprg_peek.bin
-rw-r--r--  1 root root 608025 Nov 22 12:48 3006000000010000_b73514537ffc38a0_fhprg_peek.bin
-rw-r--r--  1 root root 630464 Nov 22 12:48 3006000000010000_f8ab20526358c4fa_fhprg_peek.bin

=== edl minnesstod:
    edl.py [--loader=filename] [--memory=memtype] [--portname=portname] [--serial]
    edl.py [--memory=memtype] [--skipstorageinit] [--maxpayload=bytes] [--sectorsize==bytes] [--pagesperblock=number] [--portname=portname] [--serial]
    edl.py memorydump [--partitions=partnames] [--debugmode] [--vid=vid] [--pid=pid] [--portname=portname] [--serial] [--serial_number=serial_number]
    edl.py printgpt [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--debugmode]  [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py gpt <directory> [--memory=memtype] [--lun=lun] [--genxml] [--loader=filename]  [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--pagesperblock=number] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py r <partitionname> <filename> [--memory=memtype] [--sectorsize==bytes] [--pagesperblock=number] [--lun=lun] [--loader=filename]  [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
