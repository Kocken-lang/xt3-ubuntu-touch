1795620172837047268
--- fastboot-pids:
2921010 fastboot erase metadata
--- phaseA:
2915247 sudo /tmp/phaseA.sh
2915252 /bin/bash /tmp/phaseA.sh
2922120 timeout -k 10 1500 bash -c echo "--- fastboot-pids:"; pgrep -ax fastboot; echo "--- phaseA:"; pgrep -af phaseA | head -3; echo "--- alla som anvander usb:"; sudo lsof /dev/bus/usb/001/* 2>/dev/null | grep -E "fastboot|COMMAND" | head -5
--- alla som anvander usb:
COMMAND      PID USER FD   TYPE DEVICE SIZE/OFF NODE NAME
fastboot 2921010 root 4u   CHR 189,44     0t50 2876 /dev/bus/usb/001/045
