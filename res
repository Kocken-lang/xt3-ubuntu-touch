1795647194349892163
=== top-level memory:
	memory {
		reg = <0x00 0x80000000 0x00 0x80000000 0x01 0x00 0x00 0x7e400000>;
		device_type = "memory";
	};
=== usb-noder:
632:		ssusb@a800000 {
8133:		qusb@c012000 {
14998:		qusb@c014000 {
16829:		hsusb@c200000 {
17166:		usb2s = "/soc/hsusb@c200000";
17385:		usb3 = "/soc/ssusb@a800000";
17517:		qusb_phy1 = "/soc/qusb@c014000";
17573:		qusb_phy0 = "/soc/qusb@c012000";
=== soc ranges:
		compatible = "simple-bus";
		ranges = <0x00 0x00 0x00 0xffffffff>;
