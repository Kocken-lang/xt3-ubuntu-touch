1795617634270892609
hej
Wed Nov 25 15:40:39 CET 2026
1128963 timeout 1800 bash -c echo "=== oem help:"; sudo timeout 15 fastboot oem help 2>&1 | head -30; echo "=== getvar all (urval):"; sudo timeout 15 fastboot getvar all 2>&1 | grep -iE "edl|secure|unlock|variant|product|version-baseband" | head -10
1128965 bash -c echo "=== oem help:"; sudo timeout 15 fastboot oem help 2>&1 | head -30; echo "=== getvar all (urval):"; sudo timeout 15 fastboot getvar all 2>&1 | grep -iE "edl|secure|unlock|variant|product|version-baseband" | head -10
1128966 sudo timeout 15 fastboot oem help
