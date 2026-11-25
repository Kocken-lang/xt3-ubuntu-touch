1795636244516760921
uid=2000(shell) gid=2000(shell) groups=2000(shell),1004(input),1007(log),1011(adb),1015(sdcard_rw),1028(sdcard_r),1078(ext_data_rw),1079(ext_obb_rw),3001(net_bt_admin),3002(net_bt),3003(inet),3006(net_bw_stats),3009(readproc),3011(uhid) context=u:r:shell:s0
=== cmdline:
cat: /proc/cmdline: Permission denied
=== dmesg (sista 25):
[   43.529042] board_revision:5
[   43.529448] healthd: same as previous value, isUsbChgEnabled = 1.
[   43.678123] init: starting service 'tombstoned'...
[   43.678652] init: Created socket '/dev/socket/tombstoned_crash', mode 666, user 1000, group 1000
[   43.678966] init: Created socket '/dev/socket/tombstoned_intercept', mode 666, user 1000, group 1000
[   43.679243] init: Created socket '/dev/socket/tombstoned_java_trace', mode 666, user 1000, group 1000
[   43.693514] init: Service 'tombstoned' (pid 1268) exited with status 1
[   43.693537] init: Sending signal 9 to service 'tombstoned' (pid 1268) process group...
[   43.693680] libprocessgroup: Successfully killed process cgroup uid 1058 pid 1268 in 0ms
[   43.760196] mmd1000: mmd1000_power():446: ON--
[   44.777961] init: starting service 'credstore'...
[   44.800232] mmd1000: calculate_checksum():1026: calculate_checksum()+++
[   44.800232] 
[   44.800241] mmd1000: calculate_checksum():1032: checksum = 0x71
[   44.800241] 
[   44.800245] mmd1000: calculate_checksum():1033: calculate_checksum()---
[   44.800245] 
[   44.800252] idtech: idtech_check_device():1079: calculated checksum for check fw ver command = 0x71
[   44.800252] 
[   44.843729] logd: logdr: UID=1076 GID=1076 PID=1272 n tail=50 logMask=8 pid=1269 start=0ns timeout=0ns
[   44.845795] logd: logdr: UID=1076 GID=1076 PID=1272 n tail=50 logMask=1 pid=1269 start=0ns timeout=0ns
[   44.847149] logd: logdr: UID=1076 GID=1076 PID=1272 n tail=0 logMask=8 pid=1269 start=0ns timeout=0ns
[   44.848091] logd: logdr: UID=1076 GID=1076 PID=1272 n tail=0 logMask=1 pid=1269 start=0ns timeout=0ns
[   44.850331] init: Untracked pid 1272 exited with status 0
[   44.851056] init: Untracked pid 1274 exited with status 0
