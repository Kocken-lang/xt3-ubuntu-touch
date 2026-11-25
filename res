1795641315431764425

/* --- USB (adb/fastboot + external RF88/MSR sled) --------------------- */
&usb3 {
        status = "okay";
};

&usb3_dwc3 {
        /* Endast USB2-PHY, som referensen. QMP-PHY:n (usb3) har egna
         * matningar som inte ar modellerade; dwc3 deferrar for evigt om den
         * ar med i phys-listan. USB2 racker for ACM-konsol och adb. */
        phys = <&qusb2phy0>;
        phy-names = "usb2-phy";
        dr_mode = "peripheral";
};

&qusb2phy0 {
        /* nvmem-cells (qusb2_hstx_trim) kommer fran QFPROM. Probar inte den
         * sa deferrar PHY:n och da deferrar dwc3 - ingen UDC, ingen konsol.
         * Trimvardet ar en finjustering; utan det anvands default. */
        /delete-property/ nvmem-cells;
        vdd-supply = <&xt3_vreg_vdd_0p925>;
        vdda-pll-supply = <&xt3_vreg_vdda_1p8>;
        vdda-phy-dpdm-supply = <&xt3_vreg_vdda_3p125>;
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
