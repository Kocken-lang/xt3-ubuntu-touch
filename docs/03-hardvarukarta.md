# XT3 hårdvarukarta

Allt i den här filen är läst ur stock 91.57 (`out/fota/dtbo/dtb/*.dts` och
`from-boot.dtb`) eller ur inventeringen. Siffror inom parentes är decimala
GPIO-nummer; stock-DTB:n anger dem hexadecimalt.

SoC: **SDA660** (`/sys/devices/soc0/machine`), PM660 + PM660L.
12 DTB-varianter i `dtbo.img`: SDA/SDM × EVT/DVT/DVT1-2/DVT2/PVT/PVT4.

## Display

| Signal | Stock | Mainline |
|---|---|---|
| Panel | JD9365DA 720×1280 video, 4 lanes, 60 Hz (burst) | `panel-janam-xt3.c` (genererad ur from-boot.dtb) |
| Panelvarianter | `dsi_ili9881d_720p_video`, `_evt`, `jd9365da`, `nt35521sh` | generatorn väljer ur DTB |
| Reset | tlmm 53, aktiv låg | `reset-gpios` |
| TE | tlmm 59 | `pinctrl`/te-gpio |
| Enable | pm660l gpio 8 | TODO: panel-supply |
| Bakgrundsljus | PM660L WLED, `bl_ctrl_wled`, max 0xfff | `pm660l_wled` |
| Fysik | 59 × 104 mm | `width_mm`/`height_mm` |

## Touch

| Signal | Stock | Mainline |
|---|---|---|
| Primär | Synaptics RMI4, i2c4 `0x20` | `syna,rmi4-i2c` |
| Sekundär | Goodix GT1x, i2c4 `0x14` | `goodix,gt1x` (ej i mainline) |
| IRQ | tlmm 67, låg nivå | `interrupts` |
| Reset | tlmm 66, aktiv låg | `reset-gpios` |
| VDD | pm660l L3 (3,3 V) | `vreg_l3b_3p3` |
| VIO | pm660 L11 (1,8 V) | `vreg_l11a_1p8` |
| Koordinater | display 720×1280, panel 720×1380 | RMI4 F12 läser själv |

## Tangenter och switchar

| Signal | GPIO | Kod | Mainline |
|---|---|---|---|
| Batterilucka öppen | tlmm 76 | EV_SW 0x1f | `gpio-keys` |
| Batterilucka borttagen | tlmm 40 | EV_SW (vendor 0x1e) | `gpio-keys`, `SW_MACHINE_COVER` |
| Volym upp/ned, skanning, PTT | **finns i from-boot.dtb** | — | `make hw` |
| Pwrkey | PM660 PON | KEY_POWER | `pon_pwrkey` |
| Resin | PM660 PON | KEY_VOLUMEDOWN (antagande) | `pon_resin` |
| HiJack (extern trigger) | via `HiJackService` | — | `xt3-gpiod` |

## Bussar

| Buss | Adress | Enhet |
|---|---|---|
| i2c1 | `0xc175000` | PCA9535 `0x22` |
| i2c2 | `0xc176000` | CW2015 `0x62`, SMB1351 `0x1d` (disabled) |
| i2c4 | `0xc178000` | Synaptics `0x20`, Goodix `0x14` |
| i2c6 | `0xc1b6000` | PN54x NFC `0x28` |
| i2c8 | `0xc1b8000` | HSM-imager `0x18`, kameror/eeprom |
| SPI3 | `0xc177000` | Wiznova MMD1000 (MSR) |
| UART1/2 | `0xc16f000` / `0xc170000` | konsol + ev. TDA8029 |
| UART BLSP2 | `0xc1af000` | WCN3990 Bluetooth |
| CI2 (CCI) | — | kameror |

## Enterprise

### Skanner – Honeywell HSM-imager

| Egenskap | Värde |
|---|---|
| Compatible | `hsm,imager` |
| Buss | i2c8 `0x18` + MIPI CSI-2 |
| CSI | csiphy 1 / csid 1, port 2, 2 lanes |
| GPIO (pm660l) | 1 power-en, 2 aimer, 3 illuminator, 4 engine-reset, 5 3v3-laser, 6 3v3-imager, 7 flash-out, 8 level-shift-3v3-en, 9 scan-io-level-shift-en, 10 i2c-level-shift-en, 11 scan-buf-dir |
| Vendor-komponent | `libmmcamera_HsmImager.so` |
| Mainline | V4L2-subdev + camss capture, decode i userspace |

Detta är **inte** en seriell skanner. `ttyHS1` i inventeringen är BT/aux, inte skannern.

### MSR – Wiznova MMD1000

| Egenskap | Värde |
|---|---|
| Compatible | `wiznova,mmd1000` |
| Buss | SPI3, max 960 kHz |
| IRQ | tlmm 83 |
| Reset | tlmm 63 |
| 3V3-en | pm660l gpio 6 (variant: pm660 gpio 3) |
| Mainline | SPI-kontroller saknas i 7.2.y; `spidev` + `xt3-msrd` |

### SAM – två TDA8029

| Egenskap | Värde |
|---|---|
| Kortläsare | NXP TDA8029 (UART-gränssnitt) |
| Enable | PCA9535 rad 0 |
| Shutdown | PCA9535 rad 5 |
| Reset | PCA9535 rad 4 |
| IRQ | tlmm 43 |
| Kortmux | SGM6503B, select PCA9535 rad 3 |
| Mainline | ingen TDA8029-driver; UART-instans i from-boot.dtb |

### RFID – RF88

Extern sled på USB (`ttyACM*`/`ttyXRUSB*`). Protokollet ligger i
`ex.dev.sdk.rf88_3.1.4.aar`. Ingen on-board-hårdvara.

## Kringkretsar

| Enhet | Buss | Adress | GPIO | Mainline |
|---|---|---|---|---|
| PCA9535 | i2c1 | `0x22` | irq 72, pwr-en 27 | `gpio-pca953x` |
| CW2015 | i2c2 | `0x62` | chg-sts 45 | `cw2015_battery` |
| BQ27541 | HDQ | — | 20 | `bq27xxx` HDQ (kräver bindning) |
| BQ24086 | GPIO | — | boost 80, chg-det 90, boot-ind 12, backup-int 54 | ingen driver |
| PN54x NFC | i2c6 | `0x28` | irq 28, ven 29, firm 30, clkreq pm660 4 | `pn544-i2c` |
| PM660 charger | SPMI | — | otg-en 0, pwr-switch 62 | `pm660_charger` |
| PM660 haptics | SPMI | — | — | `pm660_haptics` |
| PM660L WLED | SPMI | — | — | `pm660l_wled` |
| Emkit board-id | GPIO | — | 84, 85, 86, 61 | `gpio-keys`/userspace |
| Pogo 5V | GPIO | — | 12, 34 | `regulator-fixed` |
| OTG VBUS | GPIO | — | 0 | `regulator-fixed` |

## Lagring, USB, radio

| Enhet | Stock | Mainline |
|---|---|---|
| eMMC | `sdhc_1`, non-removable | `sdhc_1` + TODO-rails |
| SD-kort | `sdhc_2`, CD tlmm 70 | `sdhc_2` + TODO-rails |
| USB | dwc3, qusb2phy0 | `usb3`/`usb3_dwc3` |
| WiFi | WCN3990 (`ath10k_snoc`), phy1/wlan0 | `&wifi` + TODO-rails |
| BT | WCN3990 (`btqca`) på BLSP2 UART | `&blsp2_uart1` + `bluetooth` |
| Modem | SDA660, `modemsda.img`, SIM + 2×SAM | `remoteproc_mss` |
| GNSS | Qualcomm GNSS via SLPI | svårt; kräver remoteproc + qrtr |
| Sensorer | `qcom,msm-ssc-sensors` (SLPI/ADSP) | inget SSC i mainline; mät först |

## Kameror

| Kamera | Sensor | MCLK | Reset | PWDN |
|---|---|---|---|---|
| Bak | okänd | tlmm 32 | tlmm 46 | tlmm 44 |
| Fram | GC5035 | tlmm 33 | tlmm 47 | tlmm 49 |

Kamera räknas bort i mainline (se `01-arkitektur.md` §9), men skannern använder
samma CSI-block och är därför ändå relevant.

## Vad som saknas för att fylla sista raderna

`from-boot.dtb` ger: gpio-keys-noderna, regulatorernas spänningar, SAM/MSR-bussarnas
instanser och minneskartan. Kör:

```bash
make hw      # -> out/hw/hw.md
make panel   # -> out/panel/panel-xt3.c ur enhetens egen nod
```
