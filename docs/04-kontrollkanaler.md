# Kontrollkanaler — XT3 (Point Mobile PM90)

## Nivåer, lägst först

| Nivå | Gränssnitt | Vad den ger | Verktyg |
|---|---|---|---|
| PBL / Sahara | USB 05c6:9008 | start av Firehose | `edl` |
| Firehose (EDL) | USB 05c6:900e | **rå läs/skriv av hela eMMC**, även `abl_a` | `edl r/w` |
| XBL → ABL (Janams UEFI) | fastboot 18d1:d00d | flasha, radera, OEM-kommandon | `fastboot` |
| Kärnan (4.19.157) | adb/root | moduler, ftrace, /proc/kmsg, block-enheter | `adb root` |
| Android 11 (91.57) | adb | allt i userspace | `adb` |

## Verifierat på enheten (inte antaget)

| Fakta | Värde | Källa |
|---|---|---|
| Modell | **pm90**, titel **xt3** | `EMKIT: board_check_model()` |
| CPU | **SDA660**, CPU ID 324 | `board_check_cpu()` |
| Hårdvarurevision | **5** (revid 4) | `SetRevision()`, GPIO 1250/1251/1252/1227 |
| LCD-ID | **2** | `androidboot.lcdid=2` |
| Panel | **jd9365da_720p_video** | `mdss_mdp.panel=...` |
| dtbo-val | **idx 4** = SDA660 PVT | `androidboot.dtbo_idx=4` |
| Root-flagga | `androidboot.admin.root=1` | ABL efter `oem enable-root` |
| Initramfs | **hoppas över** (`skip_initramfs`) | cmdline |
| Verity | `veritymode=enforcing`, vbmeta `unlocked` | cmdline |

Slutsats: XT3 är en rebrandad **Point Mobile PM90**. Referens-källor för porten ska sökas på PM90.

## Root

```
fastboot oem enable-root      # sätter androidboot.admin.root=1
fastboot oem enable-rooting
adb root                      # adbd startar om som root
adb shell id                  # uid=0(root) context=u:r:su:s0
```

## Läs och skriv (fungerar i alla lägen)

```
# Läs partition (Android igång, root)
adb exec-out "dd if=/dev/block/by-name/persist" > persist.img

# Skriv partition (Android igång, root)
adb push boot.img /data/local/tmp/ && adb shell "dd if=/data/local/tmp/boot.img of=/dev/block/by-name/boot_a"

# Skriv via ABL
fastboot flash boot_a boot.img

# Rå skrivning under ABL (lägsta nivån)
edl w boot_a boot.img --memory=emmc --loader=$LOADER
edl r pmobile pmobile.img --memory=emmc --loader=$LOADER
```

## När inget bootar

| Symptom | Väg in |
|---|---|
| Android hänger | Vol ned + power → fastboot |
| fastboot svarar inte | Vol upp + Vol ned → EDL (Sahara) |
| EDL "Sahara error" | strömlös 25 s, sedan kombinationen igen |

## emkit — enterprise-gränssnittet (kräver root)

```
/sys/emkit/info/   scanner msr nfc phone gps keyboard touch display cpu memory
                   revision temperature acceleration gyroscope magnetic light
                   proximity pressure sar beacon bluetooth camera_f camera_b
                   fingerprint features title
/sys/emkit/ctrl/   camlock bat_cover bat_cover_ex bl_ext boot_ind hot_swap
                   pogo_5v_en1 pogo_5v_en2 wlan_antenna wlan_generation
                   wlan_version_configuration ethernet_tempmac gpio_ethernet_en
/sys/emkit/mdb/    block partx
```

Drivrutinen är inbyggd i stock-kärnan (ingen .ko). Den loggar allt vid uppstart:

```
EMKIT: GetGpioValue(): GPIO#1250/1251/1252/1227
board_check_revision(): revid :: 4
SetRevision(): REVISION = 5
```

## Fynd som påverkar porten

1. Panelen är **jd9365da 720p**, inte simulator-panelen. DTS:en ska använda den.
2. ABL kräver att dtbo innehåller posten som matchar hw-rev 5 → **post 4**. En dtbo med
   en enda post saknar matchning och enheten hänger.
3. `skip_initramfs` sätts av ABL, så en egen ramdisk körs inte utan vidare.
4. `pmobile` (500 MB) är tom — enterprise-apparna ligger i `/system/app`.
5. `rawdump` är nollad; kärnan har `PSTORE=n`, så det finns ingen kraschlogg i flash.
