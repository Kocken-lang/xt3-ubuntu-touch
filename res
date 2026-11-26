1795724544435955492
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp4s0           DOWN           
wlo1             UP             172.20.10.9/28 2a00:801:7b5:cd8:8183:6deb:1a6:f417/64 2a00:801:7b5:cd8:dece:1bd5:71d9:ea6c/64 fe80::d80f:a8c7:a6c2:1589/64 
virbr0           DOWN           192.168.122.1/24 
docker0          DOWN           172.17.0.1/16 
br-ab018499dc62  UP             172.18.0.1/16 fe80::b8c7:ff:fe80:226f/64 
vethbddac07@if2  UP             fe80::901a:e2ff:fe09:3843/64 
veth5ce0f33@if2  UP             fe80::b8a9:c6ff:fe70:e871/64 
veth8e26f71@if2  UP             fe80::ec1c:50ff:fe16:68ba/64 
vethed979e9@if2  UP             fe80::cc37:95ff:fea0:5b0/64 
=== rutter:
default via 172.20.10.1 dev wlo1 proto dhcp src 172.20.10.9 metric 600 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
172.18.0.0/16 dev br-ab018499dc62 proto kernel scope link src 172.18.0.1 
172.20.10.0/28 dev wlo1 proto kernel scope link src 172.20.10.9 metric 600 
192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1 linkdown 
=== usb-nat:
br-ab018499dc62 docker0 enp4s0 lo veth00017bf veth5ce0f33 veth87903fa veth8e26f71 vethbddac07 vethed979e9 virbr0 wlo1 
