# UART-konsol på Janam XT3

Detta är den enda loggkanal som inte går genom ABL. Med UART ser vi
**ABL:s egen utskrift** (inklusive varför vår boot-image nekas), U-Boots logg
och kärnans `earlycon` — allt vi saknat.

## Varför inte USB

USB-konsol kräver att kärnan nått userspace och att `dwc3` probeat. Det gör den
inte i dagsläget, och vi kan inte felsöka det utan loggar. UART ligger före allt.

## Hårdvara

| Del | Krav |
|---|---|
| USB-C-brytplatta | Alla pinnar åtkomliga (A5/B5 = CC, A8/B8 = SBU) |
| Motstånd | 2 × 5,1 kΩ (1 %) |
| USB-UART | **1,8 V logiknivå** — CP2102N eller FT232R med VDDIO = 1,8 V, alternativt 3,3 V-adapter + nivåomvandlare |
| Kabel | Till valfri USB-port på datorn |

Färdig motsvarighet: Googles *SuzyQable* fungerar enligt samma princip.

### Koppling

```
USB-C (enheten)                 USB-UART (datorn)
  A5  CC1 ──[5,1 kΩ]── GND
  B5  CC2 ──[5,1 kΩ]── GND
  A8  SBU1 ──────────── RX
  B8  SBU2 ──────────── TX
  GND     ───────────── GND
  VBUS    ── (ej ansluten)
```

Båda CC-pinnarna med 5,1 kΩ till GND sätter enheten i **Debug Accessory Mode**,
och då förs UART ut på SBU1/SBU2.

> **Viktigt: logiknivån är 1,8 V.** En 3,3 V-adapter utan nivåomvandlare kan
> skada SoC:n. Mät mellan TX och GND innan du ansluter RX.

## Programvara på datorn

```bash
./scripts/50-uart-console.sh /dev/ttyUSB0
```

Skriptet ställer in 115200 8N1, råläge, och skriver tidsstämplad logg till
`out/uart/<datum>.log`.

## Vad vi letar efter vid första körningen

1. **ABL:s utskrift** när den laddar vår image — den innehåller den exakta
   orsaken till `Load Error` (AVB, rollback-index, signatur).
2. **`earlycon`** från vår kärna: `Booting Linux on physical CPU`, minneskarta.
3. **Var den stannar** om den startar: sista raden före hängningen pekar ut
   drivrutinen (eMMC, dwc3, pinctrl).

## Om ABL nekar även med UART

Då är det signerad AVB som gäller. Nästa steg i så fall:

```bash
avbtool add_hash_footer --image out/boot.img --partition_name boot \
  --partition_size 67108864 --algorithm SHA256_RSA2048 --key <nyckel>
```

vilket bara är möjligt om enheten accepterar vår nyckel (upplåst bootloader)
eller om vi kan återanvända en befintlig nyckel. UART-loggen avgör vilket.
