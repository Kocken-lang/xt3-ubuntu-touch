1795641293628194182
335:&sdhc_1 {
336-        status = "okay";
337-        non-removable;
--
350:&sdhc_2 {
351-        status = "okay";
352-        cd-gpios = <&tlmm 70 GPIO_ACTIVE_HIGH>;
--
357:&usb3 {
358-        status = "okay";
359-};
--
361:&usb3_dwc3 {
362-        /* Endast USB2-PHY, som referensen. QMP-PHY:n (usb3) har egna
363-         * matningar som inte ar modellerade; dwc3 deferrar for evigt om den
--
370:&qusb2phy0 {
371-        /* nvmem-cells (qusb2_hstx_trim) kommer fran QFPROM. Probar inte den
372-         * sa deferrar PHY:n och da deferrar dwc3 - ingen UDC, ingen konsol.
