1795637556541460186
panel-jadard-jd9365da-h3.c
---
drivers/gpu/drm/panel/panel-jadard-jd9365da-h3.c:56:#define jd9365da_switch_page(dsi_ctx, page) \
drivers/gpu/drm/panel/panel-jadard-jd9365da-h3.c:186:	jd9365da_switch_page(&dsi_ctx, 0x00);
drivers/gpu/drm/panel/panel-jadard-jd9365da-h3.c:189:	jd9365da_switch_page(&dsi_ctx, 0x01);
=== panel-dtsi hel:
// SPDX-License-Identifier: GPL-2.0-only
/*
 * jd9365da 720p video mode dsi panel
 * GENERERAD av scripts/13-panel-from-dtb.py. Redigera inte for hand.
 */

&mdss_dsi0 {
        #address-cells = <1>;
        #size-cells = <0>;

        panel: panel@0 {
                compatible = "janam,xt3-panel";
                reg = <0>;

                reset-gpios = <&tlmm 53 GPIO_ACTIVE_LOW>;
                backlight = <&pm660l_wled>;

                /*
                 * Downstream uses mdss_dsi_active/mdss_te_active pinctrl
                 * states.  Those labels do not exist in mainline; the reset
                 * line works as a plain GPIO and video mode needs no TE.
                 */

                port {
                        panel_in: endpoint {
                                remote-endpoint = <&mdss_dsi0_out>;
                        };
                };
        };
};

&mdss_dsi0_out {
        data-lanes = <0 1 2 3>;
        remote-endpoint = <&panel_in>;
};
