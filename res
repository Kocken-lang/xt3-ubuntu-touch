1795637873353048688

        chosen {
                stdout-path = "serial0:115200n8";

                /* Textkonsol pa den skarm ABL redan tandit. 720x1280 ARGB8888,
                 * stride 2880. simpledrm tar over bufferten och fbcon skriver
                 * karnloggen dit - var enda loggkanal eftersom dwc3 inte probar. */
                framebuffer@9d400000 {
                        compatible = "simple-framebuffer";
                        reg = <0x0 0x9d400000 0x0 0x384000>;
                        width = <720>;
                        height = <1280>;
                        stride = <2880>;
                        format = "a8r8g8b8";
                };
        };

        battery: battery {
                compatible = "simple-battery";
=== i2c/spi-barn med reg:
86:                ramoops@a0000000 {
96:        memory@80000000 {
119:                framebuffer@9d400000 {
406:        touchscreen@20 {
421:                rmi4-f01@1 {
426:                rmi4-f12@12 {
455:        fuel-gauge@62 {
467:        nfc@28 {
