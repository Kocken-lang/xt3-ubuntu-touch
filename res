1795643649092766897
=== ramoops/reserved i stock-dtb:
	reserved-memory {
		#address-cells = <0x02>;
		#size-cells = <0x02>;
		ranges;

--
		wlan_msa_guard = "/reserved-memory/wlan_msa_guard@85600000";
		wlan_msa_mem = "/reserved-memory/wlan_msa_mem@85700000";
		smem_mem = "/reserved-memory/smem-mem@86000000";
		removed_regions = "/reserved-memory/removed_regions@85800000";
		removed_regions1 = "/reserved-memory/removed_regions@86200000";
		modem_fw_mem = "/reserved-memory/modem_fw_region@8ac00000";
		adsp_fw_mem = "/reserved-memory/adsp_fw_region@92a00000";
		pil_mba_mem = "/reserved-memory/pil_mba_region@94800000";
		cdsp_fw_mem = "/reserved-memory/cdsp_fw_region@94a00000";
		dump_mem = "/reserved-memory/mem_dump_region";
		venus_fw_mem = "/reserved-memory/venus_fw_region";
		adsp_mem = "/reserved-memory/adsp_region";
		qseecom_mem = "/reserved-memory/qseecom_region";
		secure_display_memory = "/reserved-memory/secure_region";
		cont_splash_mem = "/reserved-memory/splash_region@9d400000";
		dfps_data_mem = "/reserved-memory/dfps_data_mem@0x9f700000";
		bluetooth = "/bt_wcn3990";
		gfx_stub_vreg = "/regulator-gfx-stub";
	};
};
=== enhet:
