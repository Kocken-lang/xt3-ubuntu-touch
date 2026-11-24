# XT3 – verifierad hårdvarumatris

Källor, i prioritetsordning:

1. **Janam XT3 User Manual**, v1 mars 2020 (`janam.com/docs/.../xt3_user-manual.pdf`)
2. **FOTA 91.57** – `META-INF/com/android/metadata` + `payload.bin`
3. **adb-inventering** från enheten (`inventory-data/`)

Där källorna säger olika gäller manualen för hårdvara, inventeringen för vad
som faktiskt är monterat i den här enheten.

## Tekniskt

| Egenskap | Manualen | Inventeringen | Mainline |
|---|---|---|---|
| SoC | Snapdragon SDM660, Adreno 512 | `SDA660` (`/sys/devices/soc0/machine`) | `qcom,sda660` (finns i qcom.yaml) |
| CPU | 2,2 GHz octa-core | lilla 633–1843 MHz, stora 1113–2208 MHz | `ARM_QCOM_CPUFREQ_NVMEM` |
| RAM/lagring | 3 GB/32 GB (WLAN) **eller** 4 GB/64 GB (WWAN) | *ej insamlat* | – |
| Lagring | microSD/SDXC | eMMC `mmcblk0`, 71 partitioner | `sdhc_1` |
| Skärm | **5" 720×1280** WXGA, 500 nits, GG3 | `ro.sf.lcd_density=320` | `mdss_dsi0` + paneldriver |
| Touch | kapacitiv multi-touch | *ej insamlat* | beror på kontroller |
| OS i paketet | Android 9 (upgraderbar) | enheten kör **91.16 / Android 9** | – |
| OS i FOTA | – | **91.57 / Android 11**, SDK 30 | – |

> **Rättelse:** SurfaceFlinger rapporterade `size=(2560,2560)`. Det är *inte*
> panelen – manualen säger 720×1280 och density 320 stämmer med 5" 720p.
> 2560×2560 kom från en virtuell/extern display (DisplayLink: `persist.sys.
> displaylink.resolution`). Panelnoden ska alltså byggas för 720×1280.

## Datainsamling

| Funktion | Hårdvara | Buss (indikation) | Mainline |
|---|---|---|---|
| Streckkod | **Honeywell N6703** 1D/2D imager | okänd – `HiJackService` tyder på keyboard-wedge, dvs USB-HID eller UART | `usbhid` / `SERIAL_MSM` |
| RFID/NFC | NXP **pn54x** (NFC Forum 1–5, ISO14443 A/B, ISO15693, MIFARE, FeliCa) | I²C (`ro.hardware.nfc_nci=pn54x`) | `nxp-nci-i2c` |
| SAM | **2 × microSAM** (SmartCard) | okänd – I²C/SPI mot kortkontroller | kräver kartläggning |
| MSR | magnetkortsläsare (tillval) | USB | `usbhid` |
| Knappar | 4 hårda + 1 programmerbar | `gpio-keys` | `gpio-keys` |

## Radio

| Funktion | Manualen | Inventeringen |
|---|---|---|
| WLAN | 802.11a/b/g/n/ac, snabb roaming | `phy1`, `wlan0` → WCN3990 (`ath10k_snoc`) |
| BT | v5 + BLE | `libbluetooth_qti.so`, `ttyHS0` → `btqca` |
| WWAN | **tillval**: EDGE/GPRS/GSM, WCDMA, LTE | `ro.baseband=apq`, `ro.radio.noril=yes`; men `modem_a`/`modem_b` finns och FOTA skeppar `modemsda.img` + `modemsdm.img` (111 MB vardera) |
| GNSS | A-GPS: GPS, QZSS, GLONASS, Galileo, Beidou | – |

### SKU-frågan

Manualen skiljer på två SKU:er och **endast WWAN-varianten har micro-SIM**:

| SKU | RAM/lagring | SIM |
|---|---|---|
| WLAN | 3 GB / 32 GB | nej |
| WWAN | 4 GB / 64 GB | micro-SIM |

Avgörs på en rad:

```bash
adb shell cat /proc/meminfo | head -1
```

`MemTotal` ≈ 2,8 GB → WLAN-SKU. ≈ 3,8 GB → WWAN-SKU.

**DTS:en aktiverar modemstacken oavsett** (`remoteproc_mss`, `adsp_pil`).
Saknas modemet failar bara remoteproc-proben med en loggrad – inget hindrar boot.
Det är billigare än att gissa fel.

## FOTA-layout (91.57)

- A/B, `ro.boot.slot_suffix=_a`, `ab_update=true`
- **Inga dynamiska partitioner** – ingen `super.img`; `system` (3 GB) och
  `vendor` (800 MB) är egna ext4-partitioner
- `vbmeta.img` finns → AVB-verifiering påslagen, måste stängas av vid flash
- 22 partitioner i payload: `boot`, `dtbo`, `system`, `vendor`, `abl`, `xbl`,
  `tz`, `hyp`, `rpm`, `pmic`, `devcfg`, `keymaster`, `cmnlib(64)`, `mdtp`,
  `dsp`, `modemsda`, `modemsdm`, `bluetooth`, `fsgbk`, `vbmeta`

## Öppna punkter

- [ ] RAM-storlek → SKU (ett adb-kommando)
- [ ] Panelnod: namn, timing, init-sekvens (ur `dtbo.img`)
- [ ] Touchkontroller: modell + I²C-buss
- [ ] SAM-kontroller: buss + adress
- [ ] Skanner: USB-HID eller UART
- [ ] Minneskarta (ur `dtbo.img`)
