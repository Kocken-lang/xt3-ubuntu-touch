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
- Firmware (mba.mbn, modem.mdt, adsp.mdt, wlanmdsp.mbn, bdwlan*, crbtfw*) ligger i
  `vendor.img`/`/vendor/firmware_mnt/image` -> `11-collect-firmware.sh`.
- Halium är struket som fas; endast contingency om IPA/rmnet visar sig obrukbart.
- Release-flöde: `.github/workflows/build-release.yml` -> `make release` -> `install.sh`.
