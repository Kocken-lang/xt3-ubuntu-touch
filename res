1795724398816942089
=== lyssnande portar:
State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess                                  
LISTEN 0      4096   127.0.0.53%lo:53         0.0.0.0:*                                            
LISTEN 0      4096       127.0.0.1:44861      0.0.0.0:*                                            
LISTEN 0      4096       127.0.0.1:8317       0.0.0.0:*    users:(("cli-proxy-api",pid=3415,fd=11))
LISTEN 0      4096       127.0.0.1:9090       0.0.0.0:*    users:(("prometheus",pid=3427,fd=6))    
LISTEN 0      5          127.0.0.1:8081       0.0.0.0:*    users:(("python3",pid=3781,fd=3))       
LISTEN 0      511        127.0.0.1:8000       0.0.0.0:*    users:(("MainThread",pid=6241,fd=21))   
LISTEN 0      4096      127.0.0.54:53         0.0.0.0:*                                            
LISTEN 0      511          0.0.0.0:19000      0.0.0.0:*    users:(("MainThread",pid=6160,fd=22))   
LISTEN 0      4096       127.0.0.1:20241      0.0.0.0:*    users:(("cloudflared",pid=3417,fd=10))  
LISTEN 0      4096       127.0.0.1:3030       0.0.0.0:*                                            
LISTEN 0      511        127.0.0.1:3001       0.0.0.0:*    users:(("MainThread",pid=6215,fd=21))   
=== processer:
root        2582  0.0  0.0  10740  6828 ?        Ss   Nov24   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
moon        6795  0.0  0.0 236828  6844 ?        Ssl  Nov24   0:00 /usr/libexec/gcr-ssh-agent --base-dir /run/user/1000/gcr
moon        6797  0.0  0.0  10484  5844 ?        Ss   Nov24   0:00 /usr/bin/ssh-agent -D
moon      122134  0.0  0.0  10484  7024 ?        S    Nov24   0:00 /usr/bin/ssh-agent -D -a /run/user/1000/gcr/.ssh
moon     1405685  0.0  0.0  17044  9088 ?        Ss   21:20   0:00 /usr/bin/ssh -NT -i /home/moon/.ssh/immortalwrt_ed25519 -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes -o ExitOnForwardFailure=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -L 127.0.0.1:19102:127.0.0.1:9101 root@192.168.1.1
=== filer:
drwx------  9 moon moon   4096 Nov 15 01:40 .gradle
drwxrwxr-x  4 moon moon   4096 Nov 22 11:26 .openhands-backup
drwxrwxr-x  4 moon moon   4096 Nov 16 01:07 industrial-builder-backups
drwxrwxr-x  3 moon moon   4096 Nov 24 03:41 xt3_backup
