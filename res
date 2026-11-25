1795634135984305979
3414491 timeout 1800 bash -c pgrep -af "bin/edl " | head -3; sudo pkill -9 -f "bin/edl " 2>/dev/null; sleep 3; echo "--- kvar:"; pgrep -af "bin/edl " | head -2; echo "--- test:"; sudo timeout 60 edl printgpt --memory=emmc 2>&1 | tail -3
3414493 bash -c pgrep -af "bin/edl " | head -3; sudo pkill -9 -f "bin/edl " 2>/dev/null; sleep 3; echo "--- kvar:"; pgrep -af "bin/edl " | head -2; echo "--- test:"; sudo timeout 60 edl printgpt --memory=emmc 2>&1 | tail -3
