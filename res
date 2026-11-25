1795644407745284852
=== xhci/usb-fel:
[165788.167523] usb 1-1: New USB device found, idVendor=18d1, idProduct=d00d, bcdDevice= 1.00
[165788.167538] usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[165788.167543] usb 1-1: Product: Android
[165788.167547] usb 1-1: Manufacturer: Google
[165788.167550] usb 1-1: SerialNumber: 2303910504
[165804.361259] usb 1-1: USB disconnect, device number 9
=== adb over nat:
LISTEN 0      4096       127.0.0.1:5037       0.0.0.0:*    users:(("adb",pid=13930,fd=9))          
=== ssh-tunnlar:
moon     3772817  0.0  0.0  17044  9216 ?        Ss   23:06   0:00 /usr/bin/ssh -NT -i /home/moon/.ssh/immortalwrt_ed25519 -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o ExitOnForwardFailure=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -L 127.0.0.1:19102:127.0.0.1:9101 root@192.168.1.1
=== adb connect-test:
failed to connect to '127.0.0.1:5555': Connection refused
