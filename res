1795639156915594071
#!/bin/sh

# Default PATH differs between shells, and is not automatically exported
# by klibc dash.  Make it consistent.
# Furthermore, this PATH ends up being used by the init, set it to the
# Standard PATH, without /snap/bin as documented in
# https://wiki.ubuntu.com/PATH
# This also matches /etc/environment, but without games path
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[ -d /dev ] || mkdir -m 0755 /dev
[ -d /root ] || mkdir -m 0700 /root
[ -d /sys ] || mkdir /sys
[ -d /proc ] || mkdir /proc
[ -d /tmp ] || mkdir /tmp
mkdir -p /var/lock
mount -t sysfs -o nodev,noexec,nosuid sysfs /sys
mount -t proc -o nodev,noexec,nosuid proc /proc

# shellcheck disable=SC2013
for x in $(cat /proc/cmdline); do
	case $x in
	initramfs.clear)
		clear
		;;
	quiet)
		quiet=y
		;;
	esac
done
=== ramoops i dts:
87:                ramoops@a0000000 {
88:                        compatible = "ramoops";
89-                        reg = <0x0 0xa0000000 0x0 0x400000>;
90-                        console-size = <0x20000>;
91-                        record-size = <0x20000>;
92-                        pmsg-size = <0x20000>;
93-                        ftrace-size = <0x0>;
94-                };
