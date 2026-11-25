1795637208662069813
24959 panel/panel-jadard-jd9365da-h3.c
585 pm90/point-mobile-pm90.json
11511 pm90/sda660-inforce-ifc6560.dts
=== panel-driver:
31:	const struct drm_display_mode mode;
144:	const struct drm_display_mode *desc_mode = &jadard->desc->mode;
145:	struct drm_display_mode *mode;
892:		.compatible = "chongzhou,cz101b4001",
896:		.compatible = "radxa,display-10hd-ad001",
900:		.compatible = "radxa,display-8hd-ad002",
904:		.compatible = "BNS,BNS080B40HD9650113A", // csvke
909:MODULE_DEVICE_TABLE(of, jadard_of_match);
=== ifc6560-dts:
16:	model = "Inforce 6560 Single Board Computer";
17:	compatible = "inforce,ifc6560", "qcom,sda660";
30:		compatible = "gpio-keys";
45:		compatible = "linux,extcon-usb-gpio";
50:		compatible = "hdmi-connector";
