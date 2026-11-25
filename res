1795565321264296657
from-boot.dtb
from-boot.dts
=== STOCK memory:
		memory@0x778000 {
			compatible = "qcom,rpm-msg-ram";
			reg = <0x778000 0x7000>;
			phandle = <0xc8>;
		};

		rpm-memory@0x778000 {
			compatible = "qcom,rpm-code-ram";
			reg = <0x778000 0x5000>;
			phandle = <0x14c>;
		};

--
		rpm_msg_ram = "/soc/memory@0x778000";
		rpm_code_ram = "/soc/rpm-memory@0x778000";
		modem_pa = "/soc/qmi-tmd-devices/modem/modem_pa";
		modem_proc = "/soc/qmi-tmd-devices/modem/modem_proc";
		modem_current = "/soc/qmi-tmd-devices/modem/modem_current";
		modem_skin = "/soc/qmi-tmd-devices/modem/modem_skin";
		modem_vdd = "/soc/qmi-tmd-devices/modem/modem_vdd";
=== VAR memory:
	memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0xc0000000>;
	};

	opp-table-dsi {
--
		memory@85e00000 {
			compatible = "qcom,rmtfs-mem";
			reg = <0x00 0x85e00000 0x00 0x200000>;
			no-map;
			qcom,client-id = <0x01>;
			qcom,vmid = <0x0f>;
--
		memory@86200000 {
			reg = <0x00 0x86200000 0x00 0x3300000>;
			no-map;
		};

		mpss@8ac00000 {
--
		memory@9d400000 {
			reg = <0x00 0x9d400000 0x00 0x23ff000>;
			no-map;
		};

		ramoops@a0000000 {
=== VAR model/compat:
	model = "Janam XT3";
			compatible = "qcom,kryo260";
			compatible = "qcom,kryo260";
			compatible = "qcom,kryo260";
