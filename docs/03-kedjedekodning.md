# XT3 — fullständig dekodning av boot- och enterprise-kedjan

Allt nedan är utläst ur filerna med respektive officiellt verktyg. Inget är antaget.

## 1. Verktyg per länk

| Länk | Verktyg |
|---|---|
| Partitionstabell | `edl printgpt` (Qualcomm Firehose) |
| Bootloader | `file`, `binwalk`, `strings`, LZMA-avkodning |
| boot.img | AOSP `unpack_bootimg.py`, `avbtool info_image/verify_image` |
| dtbo.img | AOSP `mkdtboimg.py dump`, `dtc` |
| vbmeta | AOSP `avbtool info_image` |
| system/vendor | `mount -o loop,ro`, `debugfs`, `e2fsck` |
| SDK/protokoll | `unzip` + dex-strängar + `strings` på JNI-bibliotek |
| Jämförelse enhet↔fil | EDL-läsning + `cmp` (byte för byte) |

## 2. Verifierat: flashningen är byte-exakt

| Partition | Storlek | Resultat |
|---|---|---|
| boot_a | 67 108 864 | identisk |
| dtbo_a | 8 388 608 | identisk |
| vbmeta_a | 8 192 (+padding) | identisk |
| vendor_a | 838 860 800 | identisk |
| system_a | 3 221 225 472 | identisk i 3,19 GB (99,2 %), resten ej läst |

AVB: `boot` (sha256), `dtbo` (sha256), `system`/`vendor` (sha1 hashtree) verifierar alla
med `avbtool verify_image`. Stock-vbmeta har `Flags: 0` → verifiering och verity påslagna.

## 3. boot.img (91.57)

- header v2, os 11.0.0, patch 2025-08
- kernel 14 679 524 B, ramdisk 8 388 670 B, dtb 802 464 B
- cmdline: `console=ttyMSM0,115200,n8 earlycon=msm_serial_dm,0xc170000 androidboot.hardware=qcom ...`
- Paneldrivrutiner i DTB: `ili9881d_720p_video` (+`_evt`), `jd9365da_720p_video` (+`_s`),
  `nt35521sh_720p_video`, `hx8399_truly_fhd_video`, `lgd_incell_sw49106_fhd_video`,
  `nt35597_dsc_cmd_truly` samt simulator-paneler.

## 4. dtbo.img (91.57) — 12 overlays

Alla 12 är overlays (`fragment@`) med `id=0 rev=0`.

| # | model | msm-id |
|---|---|---|
| 00 | SDA 660 MTP DVT2 | 0x144 0x00 |
| 01 | SDA 660 MTP DVT | 0x144 0x00 |
| 02 | SDA 660 MTP DVT1-2 | 0x144 0x00 |
| 03 | SDM 660 MTP DVT2 | — |
| 04 | SDA 660 MTP PVT | 0x144 0x00 |
| 05 | SDA 660 MTP PVT4 | 0x144 0x00 |
| 06 | SDM 660 MTP PVT | — |
| 07 | SDM 660 MTP PVT4 | — |
| 08 | SDA 660 MTP EVT | 0x144 0x00 |
| 09 | SDM 660 MTP EVT | — |
| 10 | SDM 660 MTP DVT1-2 | — |
| 11 | SDM 660 MTP DVT | — |

Alla SDA-poster har **identiskt msm-id**, alltså kan ABL inte skilja dem åt utan
extra urval. Touch i samtliga: `synaptics,rmi4`.

Skillnad mellan revisionerna ligger i charger (`bq2589x` backup-int), pinctrl och
interrupt-map — inte i panel eller touch.

## 5. vendor (91.57)

- `ro.product.board=XT3`, `ro.product.first_api_level=28` (enheten skeppades med Android 9)
- `ro.build.fingerprint=Janam/XT3/XT3:11/RKQ1.210924.001/R141`
- fstab.qcom: `system ... wait,slotselect,avb` (verity krävs), `userdata` med
  `fileencryption=ice,quota,reservedsize=128M`
- **`/dev/block/bootdevice/by-name/pmobile  /enterprise  ext4  wait,formattable,nofail`**
- `init.solution.rc`: `/dev/msr_spidev` (MSR över SPI), `/data/system/devices`
  (ProgramButtons), bootlogo på `mmcblk0p29`, vibratornivå
- `init.scanner.rc`: `/sys/emkit/ctrl/camlock`

## 6. system (91.57) — Janams SDK och appar

`/system/framework`: `device.sdk.jar`, `device.server.jar`, `device.internal.jar`,
`device.jni.jar`, `ex.dev.sdk.jar`, `boot-device.jni.vdex`

Binder-tjänster (12): `DeviceService`, `ScannerService`, `SerialService`, `RFIDService`,
`SamService`, `MsrService`, `SPIService`, `ExGpioService`, `HiJackService`,
`BeaconService`, `IdtechService`, `HiddenService`

Appar i `/system/app` (15): `ScanDemo_janam`, `ScanSetting_janam`, `SamDemo_janam`,
`MsrDemo_janam`, `NfcDemo_janam`, `GPSDemo_janam`, `ICCRDemo_janam`, `ImageDemo_janam`,
`PrintDemo_janam`, `PingDemo_janam`, `BugReport_janam`, `CoverInstruction_janam`,
`PmBackupRestore_janam`, `SystemInformation_janam`, `TouchSensitivityShortcut_janam`,
samt `PmButtons`.

## 7. Enterprise-hårdvaran — exakta noder

| Funktion | Nod / buss |
|---|---|
| Skanner | `/dev/ttyHS2`, `/sys/emkit/info/scanner`, `/sys/n5600/model` (motor: **N5600**) |
| Skanner-HAL | `libjni_barcode.so` (läser `/sys/emkit/*`, `/sys/n5600/model`) |
| MSR (magstripe) | `/dev/msr_spidev` (SPI); modeller `IDTECH`, `MMD1000`, `PM1100` |
| SAM | `SAM_SELECT_0`, `SAM_SELECT_1`, `SAM_SELECT_POWER` (GPIO) |
| RFID | `RFIDService` + `ex.dev.sdk.jar` |
| MDB | `/sys/emkit/mdb/block`, `/sys/emkit/mdb/partx` |
| HSM/krypto | `libHSMDecoderBAPI.so`, `libHSMDummy.so`, `KmInstallKeybox` |
| NFC | `pn54x` (`ro.hardware.nfc_nci=pn54x`) |
| Knappar | `HiJackService`, `PmButtons` |
| Feature-matris | `/sys/emkit/info/{scanner,msr,nfc,phone,gps,keyboard,touch,display,cpu,memory,revision,temperature,acceleration,gyroscope,magnetic,light,proximity,pressure,sar,beacon,bluetooth,camera_f,camera_b,fingerprint,features,title}` |
| Kontroll | `/sys/emkit/ctrl/{camlock,ethernet_tempmac,ethernet_tempmac_mode,gpio_ethernet_en}` |

## 8. Hårdvarurevisionen

Läses av drivrutinen via fyra GPIO-bitar:
`emkit,gpio-hw-rev-b0`, `b1`, `b2`, `b3`, samt `emkit,gpio-batt-cover`,
`emkit,gpio-pogo-5v-en`, `emkit,sys-info`.

Drivrutinen är **inbyggd i stock-kärnan** — den finns inte som modul i
`vendor/lib/modules/modules.load`.

## 9. Kvarstående luckor (och exakt metod)

1. `pmobile` (500 MB) — Janams enterprise-partition, läses med
   `edl r pmobile` när enheten är i EDL. Innehåller apparna och konfigurationen
   som inte ligger i system.
2. SoC-revision — läses som `/sys/devices/soc0/revision` när systemet bootar, eller
   via `fastboot getvar hw-revision`.
3. ABL-version — ABL är en UEFI-volym med LZMA-komprimerad kod; kräver
   `uefi-firmware-parser` för full utvinning.
4. Vilken dtbo-overlay ABL faktiskt väljer — mäts genom att skriva en dtbo.img med
   en post i taget (EDL `w dtbo_a`), eller via `androidboot.dtbo_idx=N` i cmdline.
