1795724678553451546

timeout 10s fastboot -s "$serial" reboot

deadline=$((SECONDS + 120))
while (( SECONDS < deadline )); do
    boot=$(timeout 4s adb -s "$serial" shell getprop sys.boot_completed 2>/dev/null |
        tr -d '\r') || boot=''
    if [[ "$boot" == 1 ]]; then
        adb -s "$serial" shell '
            printf "Slot: "; getprop ro.boot.slot_suffix
            printf "Kernel: "; uname -r
            value=$(getprop ro.boot.admin.root)
            printf "ro.boot.admin.root: %s\n" "${value:-<saknas>}"
--
fb 10 reboot
sleep 5

deadline=$((SECONDS + 120))
fastboot_seen=0

while (( SECONDS < deadline )); do
    boot=$(timeout 4s adb -s "$serial" shell getprop sys.boot_completed \
        2>/dev/null | tr -d '\r') || boot=''

    if [[ "$boot" == 1 ]]; then
        slot=$(timeout 5s adb -s "$serial" shell getprop ro.boot.slot_suffix |
            tr -d '\r')
        printf 'Android har startat. Slot: %s\n' "$slot"

--
    fb 10s reboot
    sleep 5

    deadline=$((SECONDS + 120))
    fastboot_seen=0
    while (( SECONDS < deadline )); do
        completed=$(timeout 4s adb -s "$serial" shell getprop sys.boot_completed \
            2>/dev/null | tr -d '\r') || completed=''

        if [[ "$completed" == 1 ]]; then
