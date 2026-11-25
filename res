1795641359405647026
unset readonly
unset resume
unset resume_offset
unset noresume
unset fastboot
unset forcefsck
unset fsckfix
unset starttime

# Move virtual filesystems over to the real filesystem
mount -n -o move /sys ${rootmnt}/sys
mount -n -o move /proc ${rootmnt}/proc

# Chain to real filesystem
# shellcheck disable=SC2086,SC2094
exec run-init ${drop_caps} "${rootmnt}" "${init}" "$@" <"${rootmnt}/dev/console" >"${rootmnt}/dev/console" 2>&1
echo "Something went badly wrong in the initramfs."
panic "Please file a bug on initramfs-tools."
