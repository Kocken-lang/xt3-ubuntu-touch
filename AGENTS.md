# AGENTS.md — projektminne

## Vad detta är
Port av Ubuntu Touch till Janam XT3 (SDM660, Android 11-bas 91.57) på sdm660-mainline/linux 7.2.y.

## Fasta fakta
- Kärna: `https://github.com/sdm660-mainline/linux`, branch `qcom-sdm660-7.2.y` (tag `v7.2.15-sdm660`).
- defconfig: `sdm660_defconfig`. Saknar namespaces/AppArmor → fragment i `scripts/60-waydroid.config`.
- Bootloader: `sdm660-mainline/lk2nd` (branch `main`) finns som alternativ/fallback.
- Paneldrivrutiner genereras med `msm8916-mainline/linux-mdss-dsi-panel-driver-generator`.
- Firmware: `~/janam_fota/a11/XT3/91.57_20251001.PFU` (1.34 GB) + `.md5`.
- Enterprise-API: `DevAndroidPointMobile/EmkitSDK.A11` (9 binder-tjänster, se README §2).

## Konventioner
- Allt arbetsmaterial i `out/` (git-ignorerat). Inga binärer i git.
- Skript: bash, `set -euo pipefail`, idempotenta, `--help` där det är rimligt.
- Dokumentation på svenska, kod/kommentarer på engelska.
- Verifiera alltid med checksumma (`*.md5` finns för alla PFU:er).

## Byggkommandon
```bash
make inventory   # adb-inventering
make extract PFU=~/janam_fota/a11/XT3/91.57_20251001.PFU
make dtb         # boot/dtbo -> dtb
make panel       # lmdpdg
make kernel      # Image.gz + dtb
make rootfs      # Ubuntu Touch arm64
make image       # boot.img
```

## Uppdateringar 2026-11-24 (efter analys av 91.57)
- 91.57 är en **Android A/B OTA-zip** (payload.bin 1.44 GB), inte ett eget PFU-format.
  Extrahering sker med `payload-dumper-go` (laddas ner automatiskt av 02-extract-fota.sh).
- Firmware (mba.mbn, modem.mdt, adsp.mdt, wlanmdsp.mbn, bdwlan*, crbtfw*) ligger **inte**
  i `vendor.img` – `/vendor/firmware_mnt` är en monteringspunkt. Filerna finns i
  `modemsda.img`/`modemsdm.img` (FAT), `bluetooth.img` (FAT) och `dsp.img` (ext4).
  `11-collect-firmware.sh --from-dir out/fota/partitions` hanterar alla tre.
- Halium är struket som fas; endast contingency om IPA/rmnet visar sig obrukbart.
- Release-flöde: `.github/workflows/build-release.yml` -> `make release` -> `install.sh`.

## Hårdvarufakta som rättats (2026-11-24, ur stock-DTB)
- Skannern är **inte** UART. Det är en Honeywell HSM-imager på i2c8 `0x18` +
  MIPI CSI-2 (2 lanes), med 11 GPIO på PM660L. `ttyHS1` i inventeringen är BT/aux.
- MSR är **SPI** (Wiznova MMD1000, BLSP1 QUP3 `0xc177000`, 960 kHz).
- SAM är **TDA8029 via UART**, två stycken, styrda av PCA9535 på i2c1 `0x22`.
- NFC är PN54x på i2c6 `0x28`.
- Panel: **JD9365DA** 720x1280 video (burst), reset tlmm 53, TE 59, en 8.
  Bekraftat av enheten: fb0/msm_fb_panel_info -> panel_name=jd9365da ...
  Fel panel (ILI9881D finns i samma DTB) ger svart skarm utan felmeddelande.
- Touch: Synaptics RMI4 på i2c4 `0x20`, irq 67, reset 66.

## Formatfakta (dyra att lära om)
- `dtbo.img`-headern är **big-endian** (12 poster i 91.57).
- Vendor `qcom,mdss-dsi-*-command` har 7-byte header, `dlen` **big-endian** (`ntohs`).
- `dtc` skriver ut en byte-array som **sträng** om alla byte är utskrivbara. Parsern
  måste därför acceptera `[05 01 ..]`, `<0x05 0x01 ..>` och `"\x05\x01.."`.
- Vendor `qcom,mdss-dsi-reset-sequence` anger **fysisk** nivå (gpio-flags 0). Mainline
  noden använder `GPIO_ACTIVE_LOW`, så logiska värdet är inverterat.
- `vendor.img` innehåller HAL-bibliotek, inte firmware. Se ovan.
- Vendor `bdwlan*.bin`/`WCNSS_qcom_cfg.ini` är qcacld-filer och **går inte** att
  använda med mainline ath10k. WiFi-firmware hämtas i stället av
  `16-fetch-upstream-firmware.sh` (pinnad linux-firmware-commit + sha256).
- GPU-firmware `qcom/a630_{sqe.fw,gmu.bin}` finns inte i vendor-imagen; samma
  script hämtar dem.

## Verifieringsregel
Testa aldrig en parser mot en fil som byggts med samma antagande som parsern.
Tre buggar (DTBO-magic, DTBO-header, 7z-fallback) överlevde just därför.
Använd riktiga producenter (`mkfs.vfat`, `mke2fs`, `dtc`, `payload-dumper-go`) och
`tests/selftest.sh`, som nu också bygger DTB mot en riktig 7.2.y-källa.
