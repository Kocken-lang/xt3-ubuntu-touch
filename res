1795641337851792381
195-         * tells which LDO feeds each rail.
196-         */
197:        xt3_vreg_vdd_0p925: regulator-vdd-0p925 {
198-                compatible = "regulator-fixed";
199-                regulator-name = "xt3_vdd_0p925";
200-                regulator-min-microvolt = <925000>;
201-                regulator-max-microvolt = <925000>;
202-                regulator-always-on;
203-                regulator-boot-on;
--
373-         * Trimvardet ar en finjustering; utan det anvands default. */
374-        /delete-property/ nvmem-cells;
375:        vdd-supply = <&xt3_vreg_vdd_0p925>;
376-        vdda-pll-supply = <&xt3_vreg_vdda_1p8>;
377-        vdda-phy-dpdm-supply = <&xt3_vreg_vdda_3p125>;
378-        status = "okay";
379-};
380-
381-/* --- Display / GPU -------------------------------------------------- */
--
385-
386-&mdss_dsi0 {
387:        vdd-supply = <&xt3_vreg_vdd_0p925>;
388-        vdda-supply = <&xt3_vreg_vdda_1p225>;
