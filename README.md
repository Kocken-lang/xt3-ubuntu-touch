# Janam XT3 → Ubuntu Touch (mainline SDM660)

Port av Ubuntu Touch till **Janam XT3** (Android 11, firmware **91.57**, `a11/XT3/91.57_20251001.PFU`)
med **sdm660-mainline/linux 7.2.y** som kärnbasspår, med bevarade enterprise-funktioner
(skanner, RFID, SAM, MSR, tangentbord, WWAN) och full hårdvaruutnyttjning.

Status: **Fas 1 – utvinning & inventering** (inget är byggt ännu).

---

## 1. Verklighetscheck (verifierat 2026-11-24)

| Påstående | Utfall | Bevis |
|---|---|---|
| `sdm660-mainline/linux` har 7.x | ✅ Sant | branch `qcom-sdm660-7.2.y`, tag `v7.2.15-sdm660` |
| `sdm660_defconfig` finns och är förberedd | ✅ Sant | `arch/arm64/configs/sdm660_defconfig` (1016 rader) |
| Freedreno / WCN3990-WiFi / QMI / IPA på | ✅ Sant | `ATH10K_SNOC=m`, `QRTR*`, `QCOM_IPA=m` |
| `ANDROID_BINDER_IPC` på (Waydroid-möjligt) | ✅ Sant | `CONFIG_ANDROID_BINDER_IPC=y` |
| LXC / AppArmor / namespaces förkonfigurerat | ❌ **Nej** | saknas i defconfig → måste läggas till (fragment finns i `scripts/`) |
| Ubuntu Touch "officiellt" på mainline | ❌ **Nej** | UBports porter använder Halium + libhybris. Mainline-UT = egen port (PinePhone-undantaget) |

**Konsekvens:** två spår, se `docs/01-arkitektur.md`. Fas 1–3 är gemensamma för båda.

## 2. Hårdvarukarta (från Point Mobile EmkitSDK A11)

Enterprise-funktionerna går via **9 binder-tjänster** i vendor/system:

```
DeviceService  ScannerService  SerialService  RFIDService  SamService
MsrService     SPIService      ExGpioService  HiJackService  (+ I2C, Hidden)
```

| Funktion | Gränssnitt | Mainline-portabilitet |
|---|---|---|
| Skannermotor | `/dev/ttyHSL0` (msm_serial_hs) via `SerialService`/`ScannerService` | **Bra** – rå UART, protokoll i SDK |
| RFID (RF88-sled) | `ex.dev.sdk.rf88_3.1.4` → USB-serial `/dev/ttyACM*` | **Bra** – extern modul, protokoll i Java |
| SAM-kort | `SamService` → I2C/SPI | Medel – kräver I2C-protokoll från vendor |
| MSR (kortläsare) | `MsrService` → I2C | Medel |
| GPIO/knappar | `ExGpioService`, `HiJackService` (key-hijack) | Bra – `gpio-keys` i DTS |
| Extern serial | `/dev/ttyACM0/1`, `/dev/ttyXRUSB0/1` | Trivialt |

> Slutsats: enterprise-stacken är **inte** i Android-HAL:en i någon avgörande grad – den är
> binder-tjänster ovanpå **serial/I2C/SPI/GPIO**. Det gör mainline-spåret realistiskt: vi skriver
> tunna native-daemoner (systemd) som äger samma `/dev`-noder och exponerar ett D-Bus/CLI-API.

## 3. Pipeline

```
PFU (91.57) ──► 02-extract ──► boot/dtbo/super/firmware
                                    │
XT3 via adb ──► 01-inventory ───────┤
                                    ▼
                            04-unpack-boot ──► DTB ──► 05-gen-panel ──► panel-driver + dtsi
                                                          │
                                                          ▼
                                           dts/sdm660-janam-xt3.dts
                                                          │
                    06-fetch-mainline ──► 07-build-kernel ──► Image.gz + .dtb
                                                          │
                            08-build-rootfs ──► rootfs.img │
                                                          ▼
                                              09-pack-boot ──► 10-flash
```

## 4. Kör så här

```bash
# på XT3-värden (Ubuntu), en gång:
./scripts/00-bootstrap.sh

# 1) inventera enheten (USB-debug på, adb root möjligt)
./scripts/01-device-inventory.sh          # → out/inventory/

# 2) packa upp firmware
./scripts/02-extract-fota.sh ~/janam_fota/a11/XT3/91.57_20251001.PFU   # → out/fota/

# 3) boot.img → kernel/dtb/ramdisk, dtbo → dtb-filer
./scripts/04-unpack-boot.sh out/fota/boot.img

# 4) paneldrivrutin
./scripts/05-gen-panel.sh out/fota/dtb/*.dtb                            # → out/panel/

# 5) kärna
./scripts/06-fetch-mainline.sh && ./scripts/07-build-kernel.sh

# 6) rootfs + boot-image + flash
./scripts/08-build-rootfs.sh && ./scripts/09-pack-boot.sh && ./scripts/10-flash.sh
```

Allt hamnar under `out/` (git-ignorerat). Inget skrivs utanför projektkatalogen.

## 5. Vad som behövs från enheten

`01-device-inventory.sh` samlar allt maskinellt. Komplettera med:

* `adb shell getprop ro.boot.*` (visar om `abl`/`xbl` är låst, slot-suffix, `androidboot.*`)
* Bekräfta skannermotor (SE4710 / SE4750 / SE5500) – syns i `dmesg` + `ScannerService`-konfig
* Bekräfta panel (tillverkare + upplösning) – syns i stock-DTB:ns `qcom,mdss-dsi-panel-name`

## 6. Riskregister

| Risk | Sannolikhet | Motåtgärd |
|---|---|---|
| PFU är signerad/krypterad → carving ger inget | Medel | `02` rapporterar magics; då används `Tools/make_json.exe`-analys + ev. OTA-applikation på enhet |
| Panelen har okänd kontroller utan mainline-driver | Medel | `lmdpdg` genererar från DSI-kommandosekvenserna; fallback `panel-simple` |
| Vendor-DTB använder `qcom,mdss-dsi-*` som mainline inte förstår | Hög | Normaliseras i `05`/`dts` |
| Ingen mainline-driver för skanner-UART | Låg | `ttyHSL0` = `msm_serial_hs`, mainline har `qcom,geni`/`msm`-serial; annars bitbang/8250 |
| Enterprise-appar kräver binder-tjänster | Hög | Daemoner + Waydroid för originalappar (kräver namespace/binderfs-fragment) |
