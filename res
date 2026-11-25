1795649322944750664
-rw-rw-r--  1 moon moon    1843480 Jul 14  2023 fastboot.exe
-rw-r--r--  1 moon moon       2923 Oct 11  2023 flash.bat
-rwxr-xr-x  1 moon moon       2488 Oct 11  2023 flash.sh
-rw-r--r--  1 moon moon       2915 Oct 11  2023 flash_partion.bat
-rwxr-xr-x  1 moon moon       2484 Oct 11  2023 flash_partion.sh
-rw-r--r--  1 moon moon      16896 Oct 11  2023 gpt_backup0.bin
-rw-r--r--  1 moon moon      34304 Oct 11  2023 gpt_both0.bin
-rw-r--r--  1 moon moon      17408 Oct 11  2023 gpt_main0.bin
-rwxr-xr-x  1 moon moon     278528 Oct 11  2023 hyp.mbn
-rwxr-xr-x  1 moon moon     316672 Oct 11  2023 km4.mbn
-rwxr-xr-x  1 moon moon   17808306 Oct 11  2023 mdtp.img
-rw-r--r--  1 moon moon       6255 Oct 11  2023 patch0.xml
-rw-r--r--  1 moon moon      39896 Oct 11  2023 pmic.elf
-rw-r--r--  1 moon moon      22865 Oct 11  2023 rawprogram0.xml
-rw-r--r--  1 moon moon     224880 Oct 11  2023 rpm.mbn
-rwxr-xr-x  1 moon moon         80 Oct 11  2023 sec.dat
-rw-r--r--  1 moon moon   10485760 Oct 11  2023 splash.img
-rwxr-xr-x  1 moon moon      49168 Oct 11  2023 storsec.mbn
-rw-r--r--  1 moon moon     358400 Oct 11  2023 study.img
-rw-r--r--  1 moon moon 2840887624 Oct 11  2023 system.img
-rwxr-xr-x  1 moon moon    1974272 Oct 11  2023 tz.mbn
-rw-r--r--  1 moon moon    1429892 Oct 11  2023 userdata.img
-rw-r--r--  1 moon moon       4096 Oct 11  2023 vbmeta.img
-rw-r--r--  1 moon moon  555569408 Oct 11  2023 vendor.img
-rw-r--r--  1 moon moon    2568937 Oct 11  2023 xbl.elf
=== extra/:
total 32776
drwxr-xr-x 2 moon moon     4096 Oct 11  2023 .
drwxrwxr-x 3 moon moon     4096 Nov 23 18:37 ..
-rw-r--r-- 1 moon moon 33554432 Oct 11  2023 persist.img
=== RunThis.bat:
@echo off
setlocal

adb kill-server
adb devices
adb reboot bootloader
fastboot devices

rem 0: wifi, 1: phone
set MODEM_FLAG=
set VAR=
for /f "delims=" %%i in ('fastboot getvar variant 2^>^&1 ^| findstr SDA') do set VAR=%%i
IF NOT "%VAR%" == "" set MODEM_FLAG=0

set VAR=
for /f "delims=" %%i in ('fastboot getvar variant 2^>^&1 ^| findstr SDM') do set VAR=%%i
IF NOT "%VAR%" == "" set MODEM_FLAG=1

IF "%MODEM_FLAG%"=="" (
    echo "Can't detect the modem."
    GOTO :ERROR
)

REM Temporary unlock fastboot flash for flashing locked unit
fastboot oem unlock-flash

echo "Partition table..."
rem call :FLASH partition gpt_both0.bin

echo "Flash nCPU..."
IF %MODEM_FLAG%==0 (
    echo "Flash NON-HLOS_SDA.bin"
    call :FLASH modem_a NON-HLOS_SDA.bin
    call :FLASH modem_b NON-HLOS_SDA.bin
) ELSE IF %MODEM_FLAG%==1 (
    echo "Flash NON-HLOS_SDM.bin"
    call :FLASH modem_a NON-HLOS_SDM.bin
    call :FLASH modem_b NON-HLOS_SDM.bin
)
