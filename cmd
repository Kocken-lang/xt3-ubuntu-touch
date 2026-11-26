1795724853042995431
echo "=== alla USB:"; lsusb | head -12; echo "=== adb:"; adb devices -l 2>/dev/null | head -4; echo "=== fastboot:"; sudo timeout 5 fastboot devices 2>/dev/null | head -3
