# Arkitekturbeslut: XT3 på Ubuntu Touch

## 1. Problemet i en mening

XT3:s enterprise-funktioner (skanner, RFID, SAM, MSR, knapphijack) exponeras som
**Android binder-tjänster** (`DeviceService`, `ScannerService`, `SerialService`,
`RFIDService`, `SamService`, `MsrService`, `SPIService`, `ExGpioService`, `HiJackService`),
och Ubuntu Touch är antingen *Halium* (Android-kärna + blobs via libhybris) eller
*mainline* (ren Linux, inga blobs). Valet avgör vad som fungerar dag 1.

## 2. Tre spår

| | A. Halium 11 (UBports officiellt) | B. mainline 7.2.y + UT-rootfs | C. mainline + pmOS + Waydroid |
|---|---|---|---|
| Kärna | XT3 stock 4.19/4.14 | `qcom-sdm660-7.2.y` | samma som B |
| Skal | Lomiri | Lomiri | Phosh/Plasma |
| Skanner | via vendor-HAL (fungerar) | egen daemon på `/dev/ttyHSL0` | egen daemon |
| RFID (RF88) | via vendor-HAL | egen daemon på `/dev/ttyACM*` | egen daemon |
| SAM/MSR | via vendor-HAL | I2C/SPI-daemon (protokoll måste utvinnas) | samma |
| Android-appar | nej | Waydroid | Waydroid (mogen väg) |
| Framtidssäkerhet | låg (låst kärna, inga säkerhetsfixar) | **hög** | hög |
| Tid till bootbar enhet | 2–4 veckor | 6–12 veckor | 3–6 veckor |
| Tid till "allt fungerar" | 4–6 veckor | 3–6 månader | 2–4 månader |

### Beslut (reviderat 2026-11-24, efter verifiering)

**B är enda spåret. Halium är struket som fas.**

Skäl: Lomiri/Mir kör på DRM/GBM + Mesa utan libhybris (bevisat på PinePhone, Allwinner A64,
mainline). Det finns inget i Lomiri som kräver Android. Halium ger dessutom **noll** hjälp med
enterprise-funktionerna, eftersom de är binder-tjänster ovanpå `/dev`-noder som vi ändå måste
återskapa som daemoner. Halium skulle bara spara kamera/sensor/GPS/RIL-glue – och det är
billigare att lösa de fyra sakerna direkt än att underhålla en död kärna.

Halium 11 behålls som **contingency**, inte fas: om modem-datapath (IPA/rmnet) visar sig
obrukbar i 7.2.y *och* enheten måste leverera mobildata, är Halium 11 enda vägen.
Återställningsväg i övrigt = stock 91.57-PFU, som vi redan har lokalt och kan flasha om.

C (pmOS + Waydroid) är inte ett alternativ till B utan ett **verktyg**: pmOS har färdiga
sdm660-paket för att snabbt validera drivrutiner, och Waydroid är den mogna vägen för att
köra Janams Android-SDK-appar oavsett skal.

### Firmware: det enda som fortfarande är proprietärt

"Utan Android-blobs" gäller **userspace**. Kvar finns fyra firmware-beroenden som bara
Qualcomm kan leverera, och alla hämtas ur 91.57 (se `scripts/11-collect-firmware.sh`):

| Fil | Konsument | Källa |
|---|---|---|
| `mba.mbn`, `modem.mdt` | `remoteproc_mss` | `/vendor/firmware_mnt/image` |
| `adsp.mdt` | `adsp_pil` | samma |
| `wlanmdsp.mbn`, `bdwlan*.bin`, `crbtfw*.tlv` | `ath10k_snoc` / BT | samma |
| `a630_sqe.fw`, `a630_gmu.bin` | freedreno | linux-firmware |
| `venus*.mbn` | `venus` | `/vendor/firmware` |

## 3. Fasplan

| Fas | Innehåll | Bevis på klart | Est. |
|---|---|---|---|
| 0 | Verktyg, repo, PFU-utvinning, enhetsinventering | `out/fota/manifest.json` + `out/inventory/` komplett | 1 dag |
| 1 | Stock-DTB analyserad, panel identifierad, partitioner + firmware utvunna | `out/panel/panel-*.c`, `out/firmware/` komplett | 2 dagar |
| 2 | Kernel bootar mainline till UART/USB-nät, ingen Android-ramdisk | `uname -r` visar 7.x över `usb0` | 1 vecka |
| 3 | eMMC, USB, knappar, WiFi | `lsblk`, `iw dev`, `evtest` | 1 vecka |
| 4 | Panel + touch (DRM/Freedreno) | bild på skärmen, `libinput debug-events` | 1–2 veckor |
| 5 | Rootfs: Ubuntu Touch, boot till Lomiri | inloggningsskärm | 2 veckor |
| 6 | Enterprise-daemoner: serial → skanner → RFID → SAM/MSR | `xt3-scan` CLI ger streckkod | 3–6 veckor |
| 7 | Modem/WWAN, audio, kamera, ström/termik, trimning | `mmcli -L`, inspelning, batteritid | 3–4 veckor |
| 8 | Waydroid för originalappar, härdning, OTA | APK startar, `apt full-upgrade` överlever | 2 veckor |

## 4. Enterprise-daemoner (mainline)

Binder-tjänsterna ersätts av fem systemd-tjänster med D-Bus-API. De äger var sin
`/dev`-nod, precis som vendor-tjänsterna gör i dag:

```
xt3-seriald   /dev/ttyHSL0, /dev/ttyACM*    rå UART, låsning, strömsekvens
xt3-scand     -> xt3-seriald                skannerprotokoll (SE47xx/SE55xx)
xt3-rfidd     /dev/ttyACM*                  RF88-protokoll (finns i ex.dev.sdk.rf88 AAR)
xt3-i2cd      /dev/i2c-*                    SAM + MSR
xt3-gpiod     gpio-keys + HiJack             knapphändelser -> D-Bus-signal
```

Protokollen utvinns ur:
* `ex.dev.sdk.rf88_3.1.4.aar` (Java, dekompileras med jadx) – RFID är klart mest väldokumenterat.
* `EmkitSDK.A11` AIDL + `sdk_impl_a11.jar` (Java) – visar anropsflöden, inte protokoll.
* Vendor-partitionens `libdevice*.so` / `device.default.so` (från PFU:n) – de riktiga protokollen.

Detta är den enda delen som inte kan "sys ihop av färdiga repon" – den måste skrivas.
Uppskattning: 200–600 rader C per daemon.

## 5. "Ta bort strypning" – konkret

Stock-ROM:en begränsar enheten på fem sätt. Alla åtgärdas i mainline:

| Strypning | Var | Åtgärd |
|---|---|---|
| CPU-fastklamring (thermal-engine) | `/vendor/etc/thermal-engine*.conf` | mainline: `thermal_zone` + `cpufreq` styr sig själv; inga vendor-gränser |
| GPU på låg frekvens | KGSL "powerlevel" | Freedreno + `devfreq` (msm-adreno) med `simple_ondemand` |
| Minnesgräns / LMK | `lowmemorykiller` | `zram` + `systemd-oomd` i stället |
| Begränsad I/O-scheduler | `cfq`/`noop` + vendor-tuning | `mq-deadline` + `noatime` |
| Storage-strypning (FDE-overhead) | Android FBE | LUKS2 med `adiantum`/`xts-aes` och AES-CE |

Verifiering: `out/inventory/31-cpufreq.txt` (tillgängliga frekvenser i stock) jämförs med
`/sys/devices/system/cpu/cpu*/cpufreq/scaling_available_frequencies` i mainline – samma lista
= ingen strypning kvar. Termik: `out/inventory/30-thermal.txt` jämförs med `thermal_zone*/type`.

## 6. Vad som INTE är realistiskt

* **Kamera**: sdm660-mainline har libcamera-fork, men XT3:s sensorn kan sakna mainline-driver.
  Räkna med "fungerar inte" i Fas 7 om sensorn är udda.
* **Secure boot / attestation**: försvinner med upplåst bootloader. Enterprise-MDM som
  kräver hårdvaruattestering går inte att behålla.
* **Widevine L1**: nej på mainline. L3 via Waydroid i bästa fall.
* **Janams egna MDM-agent**: Android-only, kräver Waydroid.
