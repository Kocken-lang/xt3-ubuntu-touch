1795649341718400340
=== firehose/prog-filer:
-rw-r--r--  1 moon moon     151552 Oct 11  2023 abl.elf
-rwxr-xr-x  1 moon moon     222192 Oct 11  2023 cmnlib.mbn
-rwxr-xr-x  1 moon moon     274128 Oct 11  2023 cmnlib64.mbn
-rw-r--r--  1 moon moon      49052 Oct 11  2023 devcfg.mbn
-rwxr-xr-x  1 moon moon     278528 Oct 11  2023 hyp.mbn
-rwxr-xr-x  1 moon moon     316672 Oct 11  2023 km4.mbn
-rw-r--r--  1 moon moon       6255 Oct 11  2023 patch0.xml
-rw-r--r--  1 moon moon      39896 Oct 11  2023 pmic.elf
-rw-r--r--  1 moon moon      22865 Oct 11  2023 rawprogram0.xml
-rw-r--r--  1 moon moon     224880 Oct 11  2023 rpm.mbn
-rwxr-xr-x  1 moon moon      49168 Oct 11  2023 storsec.mbn
-rwxr-xr-x  1 moon moon    1974272 Oct 11  2023 tz.mbn
-rw-r--r--  1 moon moon    2568937 Oct 11  2023 xbl.elf

=== RunThis.bat resten:

call :FLASH bluetooth_a BTFM.bin
call :FLASH bluetooth_b BTFM.bin
call :FLASH devcfg_a devcfg.mbn
call :FLASH devcfg_b devcfg.mbn
call :FLASH dsp_a dspso.bin
call :FLASH dsp_b dspso.bin
call :FLASH xbl_a xbl.elf
call :FLASH xbl_b xbl.elf
call :FLASH pmic_a pmic.elf
call :FLASH pmic_b pmic.elf
call :FLASH rpm_a rpm.mbn
call :FLASH rpm_b rpm.mbn
call :FLASH tz_a tz.mbn
call :FLASH tz_b tz.mbn
call :FLASH hyp_a hyp.mbn
call :FLASH hyp_b hyp.mbn
call :FLASH keymaster_a km4.mbn
call :FLASH keymaster_b km4.mbn
call :FLASH cmnlib64_a cmnlib64.mbn
call :FLASH cmnlib64_b cmnlib64.mbn
call :FLASH cmnlib_a cmnlib.mbn
call :FLASH cmnlib_b cmnlib.mbn
call :FLASH storsec storsec.mbn
REM call :FLASH mdtpsecapp_a mdtpsecapp.mbn
REM call :FLASH mdtpsecapp_b mdtpsecapp.mbn
call :FLASH sec sec.dat

echo "Flash Apps..."
call :FLASH abl_a abl.elf
call :FLASH abl_b abl.elf
call :FLASH boot_a boot.img
call :FLASH boot_b boot.img
call :FLASH mdtp_a mdtp.img
call :FLASH mdtp_b mdtp.img
call :FLASH system_a system.img
call :FLASH system_b system.img
call :FLASH userdata userdata.img
call :FLASH vendor_a vendor.img
call :FLASH vendor_b vendor.img
call :FLASH splash splash.img
IF EXIST persist.img (
    call :FLASH persist persist.img
)
call :FLASH fsg study.img
call :FLASH fsgbk_a study.img
call :FLASH fsgbk_b study.img
call :FLASH vbmeta_a vbmeta.img
call :FLASH vbmeta_b vbmeta.img
call :FLASH dtbo_a dtbo.img
call :FLASH dtbo_b dtbo.img

REM call :ERASE devinfo
call :ERASE modemst1
call :ERASE modemst2
call :ERASE misc
echo "Flash Done..."

fastboot reboot

echo "Just close the windows as you wish."

pause
goto :EOF

:FLASH
fastboot flash %1 %2
IF NOT %ERRORLEVEL%==0 (
	goto :ERROR
)
exit /b

:ERASE
fastboot erase %1
IF NOT %ERRORLEVEL%==0 (
	goto :ERROR
)
exit /b

:ERROR
color c
