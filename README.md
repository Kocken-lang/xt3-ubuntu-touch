# Janam XT3 → Ubuntu Touch (mainline SDM660)

Port av Ubuntu Touch till **Janam XT3** (Android 11, firmware **91.57**, `a11/XT3/91.57_20251001.PFU`)
med **sdm660-mainline/linux 7.2.y** som kärnbasspår, med bevarade enterprise-funktioner
(skanner, RFID, SAM, MSR, tangentbord, WWAN) och full hårdvaruutnyttjning.

Status: **Fas 1 klar.** Panelen är identifierad av enheten själv (JD9365DA) och
drivrutinen är genererad ur `inventory-data/91.57/boot/from-boot.dtb`, som nu
ligger i repot. Nio tangenter, touch, PMIC, gauge, NFC och firmware är på plats.

Fas 2 (första boot) återstår och kräver enheten: bygg, flasha, läs konsolen.
Rotfilsystemet byggs ur Ubuntu-arkivet med Lomiri (se `docs/04-rootfs.md`).
`tests/selftest.sh` verifierar att de incheckade panelfilerna fortfarande
matchar DTB:n och att de kompilerar mot 7.2.y.

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

**Konsekvens:** mainline är enda spåret (Halium struket, se `docs/01-arkitektur.md`). Kvar som proprietärt: fem firmware-filer från 91.57.

## 2. Hårdvarukarta (från Point Mobile EmkitSDK A11)

Enterprise-funktionerna går via **9 binder-tjänster** i vendor/system:

```
DeviceService  ScannerService  SerialService  RFIDService  SamService
MsrService     SPIService      ExGpioService  HiJackService  (+ I2C, Hidden)
```

| Funktion | Verklig buss (ur 91.57-DTB) | Mainline-portabilitet |
|---|---|---|
| Skanner (Honeywell HSM) | **I2C `0x18` + MIPI CSI-2** (inte UART) | Kräver V4L2-subdev + camss; decode i userspace |
| RFID (RF88-sled) | USB-serial `ttyACM*` | **Enkel** – extern modul, protokoll i Java |
| SAM 1 + SAM 2 | UART via **TDA8029** + PCA9535 | Medel – ingen TDA8029-driver |
| MSR (Wiznova MMD1000) | **SPI** (BLSP1 QUP3) | Medel – SPI-kontroller saknas i 7.2.y |
| GPIO/knappar | PCA9535 + tlmm | Bra – `gpio-keys` i DTS |
| NFC (PN54x) | I2C `0x28` | Bra – `pn544-i2c` finns |

Fullständig tabell med adresser, GPIO-nummer och drivrutinsstatus: `docs/03-hardvarukarta.md`.

> Slutsats: enterprise-stacken är binder-tjänster ovanpå **I2C/SPI/UART/CSI/GPIO** – inte
> Android-HAL. Vi skriver tunna native-daemoner (systemd) som äger samma bussar och
> exponerar ett D-Bus/CLI-API.

## 3. Pipeline

```
PFU (91.57) ──► 02-extract ──► 22 partitioner (boot, dtbo, modemsda, bluetooth, dsp, ...)
                                    │
XT3 via adb ──► 01-inventory ───────┤
                                    ▼
                    04-unpack-boot ──► dtb (boot) + 12 dtb (dtbo)
                                    │
                    13-panel-from-dtb ──► panel-*.c + panel-*.dtsi
                    14-hw-from-dtb    ──► out/hw/hw.md (tangenter, bussar, rails)
                    11-collect-firmware ──► out/firmware/{qcom,wlan,bt,adreno,touch}
                    16-fetch-upstream  ──► + qcom/a630_*, ath10k/WCN3990/*
                                    │
                                    ▼
                     dts/sdm660-janam-xt3.dts + panel/panel-janam-xt3.c
                                    │
      06-fetch-mainline ──► 07-build-kernel ──► Image.gz + .dtb + 617 moduler
                                    │
   18-bootstrap-rootfs ──► out/src/xt3-lomiri-noble-arm64.tar.gz
                08-build-rootfs ──► rootfs.img │
                17-install-firmware ──► /lib/firmware i rootfs
                                    ▼
                       09-pack-boot ──► 10-flash
```

`05-gen-panel.sh` och `13-panel-from-dtb.py` är samma verktyg; det senare är
implementationen och kan köras ensamt på vilken DTB som helst.

## 4. Kör så här

```bash
# på XT3-värden (Ubuntu), en gång:
./scripts/00-bootstrap.sh

# 1) inventera enheten (USB-debug på, adb root möjligt)
./scripts/01-device-inventory.sh          # → out/inventory/

# 2) packa upp firmware (91.57 ar en Android A/B OTA-zip -> payload-dumper-go)
./scripts/02-extract-fota.sh ~/janam_fota/a11/XT3/91.57_20251001.PFU   # -> out/fota/partitions/

# 2b) Qualcomm-firmware ligger i modem/bluetooth/dsp, inte i vendor.img
./scripts/11-collect-firmware.sh --from-dir out/fota/partitions
#    tips: samma kommando med --inspect listar innehållet forst

# 3) boot.img -> kernel/dtb, dtbo -> 12 dtb-filer
./scripts/04-unpack-boot.sh out/fota/partitions/boot.img out/fota/boot
./scripts/04-unpack-boot.sh out/fota/partitions/dtbo.img out/fota/dtbo

# 4) panel + hardvarukarta ur enhetens egen DTB
make hw       # -> out/hw/hw.md
make panel    # -> out/panel/panel-xt3.c + .dtsi

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

## 7. Vad 91.57 faktiskt är (verifierat 2026-11-24)

```
PK.. zip, Android A/B OTA
  META-INF/com/android/metadata   post-build=Janam/XT3/XT3:11/RKQ1.210924.001/R141:user/release-keys
  payload.bin                     1 443 523 830 byte (update_engine-payload)
  payload_properties.txt          FILE_HASH / METADATA_HASH
  care_map.pb, META-INF/com/android/otacert   (PKCS#7 + x509 v3)
```

Signerad, **inte** krypterad. `payload-dumper-go` ger samtliga partitioner
(`boot`, `dtbo`, `system`, `vendor`, `product`, `modem`, `adsp`, `vbmeta` …).
`03-carve.py` behövs inte för denna fil utan behålls som fallback för äldre PFU:er.

## 8. Slutanvändarens installation

```
1. Ladda ner xt3-ut-<version>.zip från GitHub Releases
2. packa upp
3. ./install.sh
```

`install.sh` verifierar `SHA256SUMS`, flashar `boot.img`, flashar `rootfs.img` till
`userdata`, startar om. Ingen redigering, inga parametrar.

| Kanal | Byggs av | Betyder |
|---|---|---|
| `bringup` | CI på varje commit | kärna + dtb + boot.img bygger; **inte** garanterat bootbart |
| `release` | CI på tagg `v*` | verifierad på fysisk XT3 |

**Status:** mekanismen är klar och publicerar sig själv, men `release`-kanalen kan inte bli
bootbar förrän Fas 1-data (panel, touch, minneskarta ur `out/inventory/`) ligger i
`dts/sdm660-janam-xt3.dts`. Tills dess är zipen en bringup-build.
