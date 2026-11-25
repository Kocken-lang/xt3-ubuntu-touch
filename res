1795649467699479016
=== flash.sh:
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_error()
{
    if [ $? -ne 0 ];
    then
        echo -e "${RED}Flash fail${NC}"
        echo -e "${RED}Please check the USB connector${NC}"
        exit -1
    fi
}

flash()
{
    fastboot flash $1 $2
    check_error
    echo "----------------------------------------------------"
}

erase()
{
    fastboot erase $1
    check_error
    echo "----------------------------------------------------"
}

adb kill-server
adb devices
adb reboot bootloader
fastboot devices

# 0: wifi, 1: phone
modem_flag=

if ( fastboot getvar variant 2>&1 | grep "SDA" ); then
    modem_flag=0
elif ( fastboot getvar variant 2>&1 | grep "SDM" ); then
    modem_flag=1
else
    echo "Can't detect the modem"
    exit -1

=== sdm660/jasmine-loaders:
/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/Loaders/xiaomi/jasmine_prog_emmc_firehose_Sdm660_lite.elf
/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/Loaders/xiaomi/jasmine_prog_emmc_firehose_Sdm660_ddr.elf
/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm660
/usr/src/linux-headers-7.0.0-44/include/dt-bindings/clock/qcom,gcc-sdm660.h
/usr/src/linux-headers-7.0.0-44/include/dt-bindings/clock/qcom,gpucc-sdm660.h
/usr/src/linux-headers-7.0.0-44/include/dt-bindings/clock/qcom,mmcc-sdm660.h
/usr/src/linux-headers-7.0.0-44/include/dt-bindings/interconnect/qcom,sdm660.h
/usr/src/linux-headers-7.0.0-43/include/dt-bindings/clock/qcom,gcc-sdm660.h
