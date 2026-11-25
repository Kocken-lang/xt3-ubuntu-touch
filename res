1795634135984305979
3412864 /opt/pipx/venvs/edlclient/bin/python /usr/local/bin/edl r pmobile /tmp/rb_pmobile.bin --memory=emmc --loader=/home/moon/edl-venv/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm636/000cc0e100000000_7be49b72f9e43372_fhprg_bqx2_peek.bin
3414265 timeout -k 10 1500 bash -c pgrep -af "bin/edl " | head -3; sudo pkill -9 -f "bin/edl " 2>/dev/null; sleep 3; echo "--- kvar:"; pgrep -af "bin/edl " | head -2; echo "--- test:"; sudo timeout 60 edl printgpt --memory=emmc 2>&1 | tail -3
3414267 bash -c pgrep -af "bin/edl " | head -3; sudo pkill -9 -f "bin/edl " 2>/dev/null; sleep 3; echo "--- kvar:"; pgrep -af "bin/edl " | head -2; echo "--- test:"; sudo timeout 60 edl printgpt --memory=emmc 2>&1 | tail -3
