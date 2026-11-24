# panel-janam-xt3

Mainline DRM-panel för XT3. Filen är **genererad** – redigera den inte för hand.

```
scripts/13-panel-from-dtb.py --dtb <dtb|dts> --name xt3 --outdir out/panel
cp out/panel/panel-xt3.c    panel/panel-janam-xt3.c
cp out/panel/panel-xt3.dtsi dts/panel-janam-xt3.dtsi
```

## Härkomst

| | |
|---|---|
| Nuvarande källa | Qualcomms QRD-referens `dsi-panel-ili9881d-720p-video.dtsi` (gcdb-genererad, GPL-2.0) |
| Panel | ILI9881D, 720×1280, 60 Hz, 24 bpp, 4 lanes |
| Init-sekvens | 196 kommandon, 2 av-kommandon, 3-stegs reset |
| Status | **provisorisk** |

Noden i `dtbo.img` innehåller bara bakgrundsbelysning, inte panelen. Panelens
init-sekvens ligger i `boot.img`-DTB:n. Tills `from-boot.dtb` har körts genom
generatorn vet vi att panelen är en 720p ILI9881D-*typ*, men inte att
register-sekvensen är exakt XT3:s variant.

Kör detta för att göra den definitiv:

```bash
./scripts/04-unpack-boot.sh out/fota/partitions/boot.img out/fota/boot
./scripts/13-panel-from-dtb.py --dtb out/fota/boot/dtb/from-boot.dtb --list
./scripts/13-panel-from-dtb.py --dtb out/fota/boot/dtb/from-boot.dtb \
    --name xt3 --outdir out/panel --panel <namn ur listan>
cp out/panel/panel-xt3.c panel/panel-janam-xt3.c
cp out/panel/panel-xt3.dtsi dts/panel-janam-xt3.dtsi
```

## Vad generatorn gör

Downstream lagrar kommandon som `struct dsi_ctrl_hdr`:

```
u8 dtype | u8 last | u8 vc | u8 ack | u8 wait | u16 dlen (big endian) | payload
```

`mdss_dsi_panel.c` läser `dlen` med `ntohs()`, så det finns inget tolkningsutrymme.
Generatorn översätter varje post till `{dtype, wait, len, data}` och skickar den
med `mipi_dsi_dcs_write_buffer()` i `enable()`.

Reset-sekvensen lagras som **fysisk** nivå (vendor-GPIO:n har flags 0). Noden
använder `GPIO_ACTIVE_LOW`, så generatorn inverterar nivåerna. Utan inversion
hålls panelen i reset.

## Verifierat

* `panel-janam-xt3.c` kompilerar med `aarch64-linux-gnu-gcc 14` mot
  `sdm660-mainline/linux` branch `qcom-sdm660-7.2.y`.
* `dts/panel-janam-xt3.dtsi` kompilerar med `dtc` och ingår i
  `sdm660-janam-xt3.dtb` (se `tests/selftest.sh`).
* Kommandoantal, klocka (71128 kHz), timing och sista kommando (0x29,
  20 ms) kontrolleras mot källfilen i självtestet.
