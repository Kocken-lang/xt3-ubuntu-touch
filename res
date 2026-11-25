1795633037138176295
=== /etc/init/hw:
init.qcom.factory.rc
init.qcom.rc
init.qcom.usb.rc
init.scanner.rc
init.solution.rc
init.target.rc
init.target_ota.rc

=== init.scanner.rc:
on post-fs-data

# control permissions for service
	chmod 0666          /sys/emkit/ctrl/camlock
	chown system system /sys/emkit/ctrl/camlock
