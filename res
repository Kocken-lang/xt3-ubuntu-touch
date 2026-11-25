1795637509224996756
        status = "okay";
};

/* --- Display / GPU -------------------------------------------------- */
&mdss {
        status = "okay";
};

&mdss_dsi0 {
        vdd-supply = <&xt3_vreg_vdd_0p925>;
        vdda-supply = <&xt3_vreg_vdda_1p225>;
        status = "okay";
};

&mdss_dsi0_phy {
        vcca-supply = <&xt3_vreg_vdd_0p925>;
        status = "okay";
};

&adreno_gpu {
        status = "okay";
};

&mmss_smmu {
        status = "okay";
};

/* --- Touch (Synaptics RMI4, second source Goodix GT1x) -------------- */
&blsp_i2c4 {
        status = "okay";

=== panel-dtsi:
985
12:                compatible = "janam,xt3-panel";
13:                reg = <0>;
15:                reset-gpios = <&tlmm 53 GPIO_ACTIVE_LOW>;
