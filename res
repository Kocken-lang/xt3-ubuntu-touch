1795633902179129664
=== processer:
3404407 timeout -k 10 1500 bash -c lsusb | grep -icE "05c6:9008"; L=/home/moon/edl-venv/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm636/000cc0e100000000_7be49b72f9e43372_fhprg_bqx2_peek.bin; sudo timeout 90 edl printgpt --memory=emmc --loader=$L 2>&1 | tail -3
3404409 bash -c lsusb | grep -icE "05c6:9008"; L=/home/moon/edl-venv/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm636/000cc0e100000000_7be49b72f9e43372_fhprg_bqx2_peek.bin; sudo timeout 90 edl printgpt --memory=emmc --loader=$L 2>&1 | tail -3
3404413 sudo timeout 90 edl printgpt --memory=emmc --loader=/home/moon/edl-venv/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm636/000cc0e100000000_7be49b72f9e43372_fhprg_bqx2_peek.bin
3404416 timeout 90 edl printgpt --memory=emmc --loader=/home/moon/edl-venv/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm636/000cc0e100000000_7be49b72f9e43372_fhprg_bqx2_peek.bin
3404417 /opt/pipx/venvs/edlclient/bin/python /usr/local/bin/edl printgpt --memory=emmc --loader=/home/moon/edl-venv/lib/python3.14/site-packages/Loaders/qualcomm/factory/sdm636/000cc0e100000000_7be49b72f9e43372_fhprg_bqx2_peek.bin
=== fuser:
                     USER        PID ACCESS COMMAND
/dev/bus/usb/001/071:
                     root      3404417 F.... edl
=== stanger ModemManager:
