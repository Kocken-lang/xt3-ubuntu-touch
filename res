1795649423105261359
=== rad 1570-1600:
Var
Status
adb, fastboot
PC
används
kptools + kpimg (KernelPatch)
~/apatch/
används, fungerar
APatch (me.bmax.apatch)
enheten
installerad, root aktiv
Magisk (com.topjohnwu.magisk)
enheten
installerad men oanvänd
Termux (com.termux)
enheten
installerad
frida-server (85 MB)
/data/local/tmp/
ligger och väntar
python3, tesseract, unzip, strings
PC
används
radare2
PC
användes tidigare (disassembly av init/adbd)3. PC-verktyg som är värda att ha
Verktyg
Används till
Installation
simg2img / img2simg
sparse ↔ raw ext4

=== rad 1695,1725:
På Janams server ligger bara ett:
Fil
Syfte
http://software.janam.com/update/Tools/make_json.exe
Windows-verktyg som genererar packagelist.json
I PFU-/zip-paketen finns dessutom:
Fil
Syfte
flash.sh / flash_partion.sh
Linux-flashordning (facit för partitioner)
RunThis.bat / flash.bat
Windows-motsvarighet
rawprogram0.xml + patch0.xml
QFIL/EDL-manifest (Qualcomm)
adb.exe, fastboot.exe, AdbWinApi.dll
Windows-ADB
abl.elf, xbl.elf, tz.mbn, hyp.mbn, rpm.mbn, pmic.elf, devcfg.mbn, cmnlib*.mbn, km4.mbn, NON-HLOS_SDA.bin, dspso.bin, BTFM.bin
bootloader-, modem- och DSP-stack6. Om du vill komplettera för detta projekt
Mest värde för minst arbete, i ordning:
apktool + jadx — läsa FOTA-appens logik på riktigt i stället för att gissa 
avbtool — göra korrekt vbmeta i stället för vår handgjorda (som var trasig) 
magiskboot — packa om boot.img säkert när du går till 91.57 
scrcpy — se och styra telefonen från datorn, slipper skärmbilder via OCR 
App Manager på enheten — inspektera APatch/Magisk och systemappar 
Kör inventeringskommandot först och klistra in resultatet, så säger jag exakt vad som saknas och vad som är värt att installera för just dina nästa st
ladda hem allt
Jag kollar först vilka av apparna som faktiskt har nedladdningsbara APK:er i sina senaste releases, så du inte får döda länkar:
Aurora Store har flyttat sina releases (finns på auroraoss.com), SukiSU heter nu SukiSU-Nova. Jag verifierar även avbtool-källan innan jag skriver ned
Nu har jag verifierade länkar för allt som går att ladda ner. avbtool finns varken på PyPI eller via de vanliga speglarna, så det hoppar vi över — kpt
sudo apt update; sudo apt install -y android-sdk-libsparse-utils android-sdk-platform-tools-common adb fastboot apktool jadx aapt apksigner zipalign b
Vill du också ha Ghidra (avancerad binäranalys, ca 1,5 GB) lägger du till paketet ghidra — det är valfritt.2. Android-APK:er
