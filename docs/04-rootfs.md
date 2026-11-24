# Rootfs: Lomiri på Ubuntu noble (arm64)

## Varför inte UBports system-image

UBports publicerar inga generiska arm64-rotfiler. Deras bilder byggs per enhet
i CI (`ci.ubports.com/job/rootfs-<enhet>`) och levereras genom system-image,
inte som en tarball man kan ladda ner och packa upp. `cdimage.ubports.com`
innehåller enhetskataloger, `build/` och `deb/` — ingen `rootfs/`.

Att pinna en artefakt från en annan enhets CI-jobb hade fungerat i praktiken
(användarrymden är arm64 och enhetsoberoende), men det är en odokumenterad
beroendekedja som går sönder tyst vid nästa ombyggnad.

## Vad vi gör i stället

Vi bygger rotfilsystemet ur **Ubuntu-arkivet** med `debootstrap` och lägger
Lomiri ovanpå. Lomiri-paketen finns i noble universe, med *Debian UBports Team*
som maintainer, och de drar in `mir-platform-graphics-gbm-kms` — exakt den väg
mainline använder (DRM/GBM + Mesa/Freedreno, ingen libhybris).

```bash
make rootfs-bootstrap     # sudo, ~1,5 GB, 15-25 min
make rootfs
make release
```

`18-bootstrap-rootfs.sh` gör fyra saker:

1. `debootstrap --arch=arm64 --foreign --variant=minbase noble` från
   `ports.ubuntu.com/ubuntu-ports`
2. andra steget under `qemu-aarch64-static` (binfmt)
3. `apt install` av Lomiri, sessionen, systeminställningarna, greetern och
   Lomiri-apparna (kalkylator, klocka, filhanterare, galleri, media, musik,
   dokumentvisare), plus `network-manager`, `bluez`, `openssh-server`
4. packar `out/src/xt3-lomiri-noble-arm64.tar.gz`

`08-build-rootfs.sh` hittar tarballen automatiskt, lägger till kärnmodulerna
och installerar firmware med `17-install-firmware.sh`.

## Verifierat

Dependency-resolution mot arm64-index för noble + noble-updates + noble-security:

```
705 newly installed, 0 to remove and 0 not upgraded
0 libreoffice-/openjdk-paket
```

Listan är medvetet smal (`--no-install-recommends`). `ubuntu-standard` drar in
LibreOffice + JDK som rekommendationer, och `lomiri-docviewer-app` hard-drar
`libreoffice-core`. Ingen av dem behövs för att få enheten att boota; de går
att `apt install` senare. Mir-backenderna däremot är *rekommendationer* till
`lomiri` och måste därför namnges explicit — utan `mir-platform-graphics-gbm-kms`
startar compositorn inte på DRM/GBM.

Alltså går paketmassan att lösa. Själva installationen kräver binfmt
(`qemu-user-static` + `binfmt-support`), som `make bootstrap` installerar.
I sandlådor med read-only `/proc/sys/fs/binfmt_misc` kan steget inte köras —
gör det på värden.

## Konsekvenser, ärligt

| | UBports system-image | denna rootfs |
|---|---|---|
| Uppdateringar | vänta på ombyggd bild | `apt full-upgrade` |
| Enhetsberoende | per enhet | ingen |
| Androids appar | via Waydroid | via Waydroid (installeras separat) |
| Första boot | färdig bild | du bygger själv en gång |

Skillnaden mot en UBports-bild är image-maskineriet, inte skrivbordet: det är
samma Lomiri, samma Mir, samma appar.
