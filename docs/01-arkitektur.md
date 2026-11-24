# Arkitekturbeslut: XT3 på Ubuntu Touch

## 1. Problemet i en mening

XT3:s enterprise-funktioner exponeras som **Android binder-tjänster**
(`DeviceService`, `ScannerService`, `SerialService`, `RFIDService`, `SamService`,
`MsrService`, `SPIService`, `ExGpioService`, `HiJackService`), men de vilar alla på
hårdvara som mainline kan äga direkt: I2C, SPI, UART, GPIO, USB och MIPI CSI-2.
Frågan är inte *om* de går att återskapa, utan *hur mycket som måste skrivas*.

## 2. Vad hårdvaran faktiskt är (verifierat ur 91.57)

Detta ändrades när stock-DTB:n lästes. Den tidigare beskrivningen ("skanner på
`/dev/ttyHSL0`", "SAM/MSR på I2C") var fel.

| Funktion | Verklig buss | Adress / GPIO | Mainline-status |
|---|---|---|---|
| Skanner (Honeywell HSM-imager) | **I2C + MIPI CSI-2** | i2c8 `0x18`, CSI2 port 2, 2 lanes, 11 GPIO | V4L2-subdev måste skrivas; camss finns |
| MSR (Wiznova MMD1000) | **SPI** (BLSP1 QUP3) | 960 kHz, irq 83, reset 63, 3V3-en pm660 gpio 6 | SPI-kontroller saknas i 7.2.y; spidev först |
| SAM 1 + SAM 2 | **UART via TDA8029** | enable/shutdown/reset på PCA9535, irq 43 | TDA8029-driver saknas; UART okänd |
| RFID (RF88) | **USB** (extern sled) | `ttyACM*` / `ttyXRUSB*` | Fungerar redan i userspace |
| NFC | I2C | i2c6 `0x28`, irq 28, ven 29, firm 30 | `pn544-i2c` finns |
| GPIO-expander | I2C | i2c1 `0x22` (PCA9535), irq 72 | `gpio-pca953x` finns |
| Gasmätare (bränslemätare) | I2C | i2c2 `0x62` (CW2015), chg-sts 45 | `cw2015_battery` finns |
| Panel | DSI | ILI9881D 720p, reset 53, TE 59, en 8 | driver genereras ur DTB |
| Touch | I2C | i2c4 `0x20` (RMI4), irq 67, reset 66 | `rmi4-i2c` finns |
| SD-kort | SDHC | CD gpio 70 | `sdhci-msm` finns |

Slutsats: **ingen av enterprise-funktionerna är en HAL-fråga.** De är bussar.
Halium skulle ge noll hjälp med dem.

## 3. Tre spår, och varför B valdes

| | A. Halium 11 | B. mainline 7.2.y + UT-rootfs | C. mainline + pmOS |
|---|---|---|---|
| Kärna | stock 4.19 | `qcom-sdm660-7.2.y` | samma som B |
| Skal | Lomiri | Lomiri | Phosh/Plasma |
| Skanner | vendor-HAL | egen V4L2-subdev + userspace-decode | samma |
| RFID | vendor-HAL | userspace över USB | samma |
| SAM/MSR | vendor-HAL | egna drivrutiner/daemoner | samma |
| Framtidssäkerhet | låg | **hög** | hög |
| Tid till bootbar enhet | 2–4 veckor | 6–12 veckor | 3–6 veckor |

**Beslut: B är enda spåret. Halium är struket, kvar bara som contingency** om
modem-datapath (IPA/rmnet) visar sig obrukbar *och* mobildata måste levereras.
Återställningsväg är stock 91.57-PFU, som redan finns lokalt.

C är inte ett alternativ utan ett verktyg: pmOS-paketen används för att snabbt
validera drivrutiner, och Waydroid kör Janams Android-SDK-appar oavsett skal.

## 4. Firmware: det enda som är proprietärt

"Utan Android-blobs" gäller userspace. Kvar finns fem firmware-beroenden, och
**de ligger inte i `vendor.img`** – `/vendor/firmware_mnt` är en monteringspunkt.
Filerna finns i modem- och bluetooth-partitionerna:

| Fil | Konsument | Källa |
|---|---|---|
| `mba.mbn`, `modem.mdt`, `modem.b0*` | `remoteproc_mss` | `modemsda.img` (FAT, SDA660) |
| `adsp.mdt`, `adsp.b0*` | `adsp_pil` | `modemsda.img` / `dsp.img` |
| `ath10k/WCN3990/hw1.0/{firmware-5.bin,wlanmdsp.mbn,board-2.bin}` | `ath10k_snoc` | linux-firmware (pinnad i `16-fetch-upstream-firmware.sh`) |
| `bdwlan*.bin`, `WCNSS_qcom_cfg.ini` | **qcacld (Android) — används inte** | `modemsda.img` |
| `crbtfw*.tlv`, `crbtnv*.bin` | `btqca` | `bluetooth.img` (FAT) |
| `a630_sqe.fw`, `a630_gmu.bin` | freedreno | `modemsda.img` / linux-firmware |
| `venus*.mbn` | `venus` | `modemsda.img` |

`scripts/11-collect-firmware.sh` känner igen FAT, ext4, tar och sparse, och dumpar
**bara** firmware-katalogerna ur ext4-images. Den har testats mot riktiga
`mkfs.vfat`- och `mke2fs`-images, inte mot handskrivna antaganden.

## 5. Panel: genererad, inte gissad

Downstream lagrar panelens init-sekvens som ett byte-fält. Formatet är
`struct dsi_ctrl_hdr` från vendor-kärnan:

```
u8 dtype | u8 last | u8 vc | u8 ack | u8 wait | u16 dlen (big endian) | payload
```

`mdss_dsi_panel.c` läser `dlen` med `ntohs()`, så det finns inget utrymme för
tolkning. `scripts/13-panel-from-dtb.py` parsar exakt detta och genererar:

* `panel-janam-xt3.c` – mainline DRM-panel med Linux 7.x-API:t
  (`devm_drm_panel_alloc`, inte borttagna `drm_panel_init`)
* `panel-janam-xt3.dtsi` – noden under `&mdss_dsi0`

Den incheckade drivrutinen är genererad ur Qualcomms QRD-referens för
**ILI9881D 720p video** – samma panel som XT3:s stock-DTB pekar ut
(`dsi_ili9881d_720p_video`). Den är märkt *provisorisk*: när `from-boot.dtb`
finns körs generatorn om mot enhetens egen nod, och då är sekvensen definitiv.

## 6. Fasplan

| Fas | Innehåll | Bevis på klart | Est. |
|---|---|---|---|
| 0 | Verktyg, PFU-utvinning, enhetsinventering | manifest + inventory komplett | klar |
| 1 | Stock-DTB: partitioner, firmware, panel, bussar | `out/firmware/`, `out/panel/`, `out/hw/` | nästan klar |
| 2 | Kernel bootar mainline till UART/USB-nät | `uname -r` visar 7.x över `usb0` | 1 vecka |
| 3 | eMMC, USB, knappar | `lsblk`, `evtest` | 1 vecka |
| 4 | Panel + touch | bild på skärmen, `libinput debug-events` | 1–2 veckor |
| 5 | Rootfs: Ubuntu Touch, boot till Lomiri | inloggningsskärm | 2 veckor |
| 6 | Enterprise: RFID (USB) → MSR (SPI) → SAM (UART) → skanner (CSI) | `xt3-rfid`, `xt3-msr`, `xt3-sam`, `xt3-scan` | 4–8 veckor |
| 7 | Modem/WWAN, audio, kamera, ström/termik | `mmcli -L`, inspelning, batteritid | 3–4 veckor |
| 8 | Waydroid, härdning, OTA | APK startar, `apt full-upgrade` överlever | 2 veckor |

## 7. Enterprise-daemoner, i rätt ordning

Binder-tjänsterna ersätts av systemd-tjänster med D-Bus-API. Ordningen är vald
efter risk, inte efter funktion:

```
xt3-rfidd    /dev/ttyACM*              RF88, protokollet ligger i Java-AAR:en
xt3-msrd     spidev (BLSP1 QUP3)       MMD1000, enklast att verifiera med logik
xt3-samd     /dev/ttyHS* + PCA9535     TDA8029 x2, kortmux via sgm6503b
xt3-scand    /dev/video* (CSI2)        HSM-imager, V4L2-subdev + decode i userspace
xt3-gpiod    gpio-keys + PCA9535       knappar, batterilucka, pogo
```

Protokollen utvinns ur:

* `ex.dev.sdk.rf88_3.1.4.aar` (Java, jadx) – RFID är bäst dokumenterat.
* `EmkitSDK.A11` AIDL + `sdk_impl_a11.jar` – anropsflöden, inte protokoll.
* Vendor-partitionens `libdevice*.so` / `libmmcamera_HsmImager.so` – de riktiga
  protokollen, särskilt för skannern.

Uppskattning: 200–600 rader C per daemon, plus V4L2-subdev (~800 rader) för skannern.

## 8. "Ta bort strypning" – konkret

| Strypning | Var | Åtgärd |
|---|---|---|
| CPU-klampning | `/vendor/etc/thermal-engine*.conf` | mainline `thermal_zone` + `cpufreq` |
| GPU på låg frekvens | KGSL powerlevel | freedreno + `devfreq` `simple_ondemand` |
| LMK | `lowmemorykiller` | `zram` + `systemd-oomd` |
| I/O-scheduler | `cfq`/vendor-tuning | `mq-deadline` + `noatime` |
| FBE-overhead | Android FBE | LUKS2 med `adiantum`/`xts-aes` + AES-CE |

Verifiering: jämför `inventory-data/31-cpufreq.txt` med
`/sys/devices/system/cpu/cpu*/cpufreq/scaling_available_frequencies` i mainline.
Samma lista = ingen strypning kvar.

## 9. Vad som INTE är realistiskt

* **Kamera**: sensorn (gc5035 fram, okänd bak) saknar mainline-driver. Räkna bort.
* **Secure boot / attestation**: försvinner med upplåst bootloader.
* **Widevine L1**: nej. L3 via Waydroid i bästa fall.
* **Janams MDM-agent**: Android-only, kräver Waydroid.

## 10. Nästa hårda blockerare

`from-boot.dtb` (802 kB) ur `boot.img`. Den innehåller:

* de fem panelvarianterna med fullständiga init-sekvenser
* de riktiga gpio-keys-noderna (volym, skanning, PTT)
* regulatorernas faktiska spänningar och vilka rails WiFi/BT/USB använder
* SAM- och MSR-bussarnas instanser
* minneskartan (mpss/adsp/venus-reservationer)

En kommandorad räcker:

```bash
cd ~/xt3
make hw            # skriver out/hw/hw.md ur out/fota/boot/dtb/from-boot.dtb
make panel         # listar alla paneler och genererar ur enhetens egen nod
```

Därefter är DTS:en komplett utan gissningar.
