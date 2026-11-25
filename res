1795650224645648617
if [ $modem_flag == 0 ]; then
    echo "Flash NON-HLOS_SDA.bin"
    flash modem_a NON-HLOS_SDA.bin
    flash modem_b NON-HLOS_SDA.bin
elif [ $modem_flag == 1 ]; then
    echo "Flash NON-HLOS_SDM.bin"
    flash modem_a NON-HLOS_SDM.bin
    flash modem_b NON-HLOS_SDM.bin
fi
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
# flash mdtpsecapp_a mdtpsecapp.mbn
# flash mdtpsecapp_b mdtpsecapp.mbn
flash sec sec.dat
echo "Flash Apps..."
flash abl_a abl.elf
flash abl_b abl.elf
flash boot_a boot.img
flash boot_b boot.img
flash mdtp_a mdtp.img
flash mdtp_b mdtp.img
flash system_a system.img
flash system_b system.img
flash userdata userdata.img
flash vendor_a vendor.img
flash vendor_b vendor.img
flash splash splash.img
if [ -f "./persist.img" ]; then
    flash persist persist.img
fi
flash fsg study.img
flash fsgbk_a study.img
flash fsgbk_b study.img
flash vbmeta_a vbmeta.img
flash vbmeta_b vbmeta.img
flash dtbo_a dtbo.img
flash dtbo_b dtbo.img
# erase devinfo
erase modemst1
