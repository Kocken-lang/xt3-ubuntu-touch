1795632645044021431
3366154 timeout 1800 bash -c pgrep -af "edl r system_a" | head -2; stat -c%s /tmp/rb_system_a.bin; tail -2 /tmp/readbig.log | cut -c1-120
3366156 bash -c pgrep -af "edl r system_a" | head -2; stat -c%s /tmp/rb_system_a.bin; tail -2 /tmp/readbig.log | cut -c1-120
3194638336
Progress: |██████████| 100.0% Read (Sector 0x5FF6C0 of 0x600000, ) 25.01 MB/s 
Progress: |████████�
