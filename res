1795647177301338864
18436
=== memory:
		rpm-memory@0x778000 {
			reg = <0x778000 0x5000>;
			compatible = "qcom,rpm-code-ram";
			phandle = <0x14c>;
--
		memory@0x778000 {
=== intc/gic:

		interrupt-controller@17a00000 {
			reg = <0x17a00000 0x10000 0x17b00000 0x100000>;
			#size-cells = <0x01>;
			compatible = "arm,gic-v3";
			redistributor-stride = <0x00 0x20000>;
--
		tpda_olc_out_funnel_apss_merg = "/soc/tpda@7b92000/ports/port@0/endpoint";
		intc = "/soc/interrupt-controller@17a00000";
		pm660l_l8 = "/soc/qcom,rpm-smd/rpm-regulator-ldob8/regulator-l8";
		cpe = "/soc/qcom,msm-cpe-lsm";
		gpio_sw_suspend = "/soc/pinctrl@03000000/tlmm_gpio_key/gpio_sw_suspend";
=== usb3:
