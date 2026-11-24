# Revision: hårdvara och bygge (2026-11-24)

Skriven efter att enheten föll tillbaka till fastboot direkt vid första
bootförsöket. Fyra fynd, alla verifierade mot enhetens egna filer.

## Symptom

`fastboot flash` svarar OKAY på boot, vbmeta och userdata. Vid omstart går
enheten tillbaka till fastboot inom några sekunder. Ingen skärmbild, ingen
Panel-notis. Det betyder att **ABL avvisar bilden innan kärnan startar** -
inte att kärnan kraschar (då hade enhetens watchdog startat om efter ~20 s
och splash hade synts).

## Fynd 1: DTB:n saknade Qualcomm-id (blockerande)

Stock-DTB:n (ur `boot.img` i 91.57) har i roten:

```
compatible      = "qcom,sda660"
qcom,msm-id     = <0x144 0x00>
qcom,pmic-id    = <0x1001b 0x101011a 0 0 ...>
qcom,board-id   = <0x30008 0x00>      (i dtbo, variant per tillverkning)
```

Vår mainline-DTS hade **inga** av dessa. ABL matchar dem mot SoC och
plattform; utan matchning laddas ingen DTB och ABL faller tillbaka till
fastboot. Åtgärd: värdena är nu inlagda i `dts/sdm660-janam-xt3.dts`,
lästa ur `inventory-data/91.57/boot/from-boot.dtb` - inte gissade.

## Fynd 2: ingen /memory-nod (blockerande om ABL inte patchar)

Stock-DTB:n har `memory { device_type = "memory"; }` **utan** `reg` -
ABL fyller i storleken själv strax före hoppet. Vår DTS hade ingen
`/memory` alls, alltså hade kärnan fått 0 MB RAM även om ABL släppt igenom
bilden. Noden finns nu, utan `reg`, exakt som stock.

## Fynd 3: rootfs-img var sparse (åtgärdat i install.sh)

`truncate -s 6G` + `mkfs.ext4` ger en fil med hål. fastboot gör om den till
sparse och räknade fel: `image size: 140726158252816` (128 TB) och skickade
2,5 GB av 6 GB. Nu skickar `install.sh` en `cp --sparse=never`-kopia.

## Fynd 4: initramfs kunde sakna lagringsdrivrutiner

`MODULES=dep` härleder ur `/etc/fstab`, där roten står som `LABEL=ut-rootfs`.
Etiketten går inte att slå upp vid byggtid, så listan kan bli tom. Nu namnges
`mmc_block`, `sdhci`, `sdhci_msm`, `ext4` explicit i
`/etc/initramfs-tools/modules`.

## Vad som är verifierat om hårdvaran

| Område | Källa | Status |
|---|---|---|
| SoC | DT `compatible`, `soc0/machine` | SDA660 (WiFi-variant), PM660L |
| Panel | DTB `mdss_dsi0` | JD9365DA, 720×1280, 4 lanes, burst |
| Touch | DTB `i2c` | Synaptics RMI4 (`syna,rmi4-i2c`) |
| Knappar | DTB `gpio-keys` | 9 tangenter (kodade i DTS) |
| Skanner | `/dev/ttyHSL0` (inventering) | protokoll ej utvintrat än |
| RFID | extern RF88 via ttyACM | protokoll ej utvintrat än |
| Lagring | `mmcblk0`, 71 partitioner | eMMC, A/B utan super |
| Modem | `ro.baseband=apq`, `noril=yes` | **ingen modemstack** |
| Batteri | `33-battery.txt` | 4340 mV, 2,84 Ah |

## Kvar att verifiera på hårdvara

Panel-init, touch, de nio tangenterna, skanner, RFID, SAM/MSR. Alla kräver
en lyckad boot först.

## Reservplan om ABL fortfarande avvisar bilden

`sdm660-mainline/lk2nd` finns redan klonad i `out/src/`. lk2nd är en
andra-stegs-bootloader som ersätter ABL:s kernel-laddning, patchar minne
och ger egna loggar. Den används av postmarketOS på sdm660 av precis det
skäl vi nu ser.
