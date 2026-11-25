1795645213798769707
                framebuffer_mem: memory@9d400000 {
                        /* ABL:s splash-buffer. Reserverad sa karnan inte
                         * allokerar den, men UTAN no-map - simpledrm maste
                         * kunna ioremap:a regionen for att ta over den. */
--
        memory@80000000 {
                device_type = "memory";
                reg = <0x0 0x80000000 0x0 0xC0000000>;
=== chosen:
        chosen {
		#address-cells = <2>;
		#size-cells = <2>;
                stdout-path = "serial0:115200n8";

                /* Textkonsol pa den skarm ABL redan tandit. 720x1280 ARGB8888,
