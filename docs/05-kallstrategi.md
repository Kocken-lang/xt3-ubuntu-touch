# Källstrategi — vad som återanvänds och vad som måste skrivas

## Fynd (verifierade i källkod, inte antagna)

| Behov | Källa | Fil |
|---|---|---|
| Enhetsidentitet | Point Mobile PM90 (samma hårdvara) | `third_party/pm90/point-mobile-pm90.json` |
| SDA660-referens | Inforce IFC6560 (industriell SDA660) | `third_party/pm90/sda660-inforce-ifc6560.dts` |
| Panel | Jadard JD9365DA-H3, mainline DRM | `third_party/panel/panel-jadard-jd9365da-h3.c` |
| Enterprise-info (revision, modell, CPU, tangentbord) | emkit, öppen källkod | `third_party/emkit/*` |

emkit är sju filer och stöder uttryckligen `SDA660` samt tangentbord `NUMERIC_PM40`,
`QWERTY_PM40`, `NUMERIC_PM60`, `QWERTY_PM60`. Revisionen läses från
`androidboot.hardware.revision=` (som ABL sätter) med GPIO som fallback.

## Vad som inte finns som öppen källkod

| Funktion | Downstream-drivrutin | Lösning på mainline |
|---|---|---|
| Skanner N5600 | inbyggd i 4.19 | daemon på `/dev/ttyHS2` + `/sys/emkit/info/scanner` |
| MSR (MMD1000 / IDTECH) | `mmd1000`, `idtech` i 4.19 | daemon på `spidev` |
| SAM (2 kortplatser) | GPIO-select + I2C/SPI | daemon på `i2c-dev` + gpiod |
| MDB | `/sys/emkit/mdb/*` | daemon |

Detta är samma slutsats som i `docs/01-arkitektur.md`: enterprise-lagret är
binder-tjänster över råa noder, och noderna finns på mainline.

## Nästa steg, i ordning

1. `dts/sdm660-janam-xt3.dts` byggs om från `sda660-inforce-ifc6560.dts` med:
   - `compatible = "janam,xt3", "qcom,sda660"`
   - panel `jadard,jd9365da-h3` med init-sekvensen ur dtbo-post 4
   - hw-rev 5, LCD-ID 2, `dtbo_idx=4` som referens
2. emkit-drivrutinen in i `drivers/emkit` (Kconfig/Makefile finns).
3. Panel-drivrutinen anpassas med XT3:s `qcom,mdss-dsi-on-command` ur dtbo.
4. Daemons för skanner, MSR, SAM, MDB (userspace, systemd).

## Kontrollkanaler under arbetet

Se `docs/04-kontrollkanaler.md`. Kort: `adb root` (permanent, `ro.debuggable=1`),
`fastboot`, `edl` (rå eMMC).
