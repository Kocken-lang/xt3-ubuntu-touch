1795649094287147716
3848
=== första 80 raderna:
moon@moon-Thin-GF63-12UCX:~/tools$ for c in simg2img apktool aapt apksigner zipalign binwalk mitmproxy scrcpy dtc tcpdump clang java 7z jadx; do printf &quot;%-12s &quot; &quot;$c&quot;; command -v &quot;$c&quot; &gt;/dev/null &amp;&amp; echo OK || echo &quot;-&quot;; done
simg2img OK
apktool OK
aapt OK
apksigner OK
zipalign OK
binwalk OK
mitmproxy OK
scrcpy OK
dtc OK
tcpdump OK
clang OK
java OK
7z OK
jadx OK
moon@moon-Thin-GF63-12UCX:~/tools$ sudo apt update; sudo apt install -y android-sdk-libsparse-utils android-sdk-platform-tools-common adb fastboot apktool jadx aapt apksigner zipalign binwalk mitmproxy scrcpy device-tree-compiler tcpdump clang gcc-aarch64-linux-gnu libssl-dev bc bison flex libelf-dev git curl unzip p7zip-full; pip3 install --user edl
[sudo: authenticate] Password: 
Hit:1 http://archive.ubuntu.com/ubuntu resolute InRelease
Hit:2 https://apt.grafana.com stable InRelease 
Hit:3 https://dl.google.com/linux/chrome-stable/deb stable InRelease
Hit:4 http://security.ubuntu.com/ubuntu resolute-security InRelease 
Hit:5 http://archive.ubuntu.com/ubuntu resolute-updates InRelease
Hit:6 http://archive.ubuntu.com/ubuntu resolute-backports InRelease
45 packages can be upgraded. Run &apos;apt list --upgradable&apos; to see them.
Note, selecting &apos;7zip&apos; instead of &apos;p7zip-full&apos;
Error: Unable to locate package jadx
error: externally-managed-environment
× This environment is externally managed
╰─&gt; To install Python packages system-wide, try apt install
python3-xyz, where xyz is the package you are trying to
install.
If you wish to install a non-Debian-packaged Python package,
create a virtual environment using python3 -m venv path/to/venv.
Then use path/to/venv/bin/python and path/to/venv/bin/pip. Make
sure you have python3-full installed.
If you wish to install a non-Debian packaged Python application,
it may be easiest to use pipx install xyz, which will manage a
virtual environment for you. Make sure you have pipx installed.
See /usr/share/doc/python3.14/README.venv for more information.
note: If you believe this is a mistake, please contact your Python installation or OS distribution provider. You can override this, at the risk of breaking your Python installation or OS, by passing --break-system-packages.
hint: See PEP 668 for the detailed specification.
moon@moon-Thin-GF63-12UCX:~/tools$ AUTH=$(grep -ai &quot;authorization&quot; /tmp/proxy.log | head -1 | sed &apos;s/.*Basic //&apos; | tr -d &apos;\r&apos;); mkdir -p ~/janam_fota &amp;&amp; df -h ~/ | tail -1; wget -r -np -nH --cut-dirs=1 -c -e robots=off --reject &quot;index.html*&quot; --header=&quot;Authorization: Basic $AUTH&quot; -P &quot;$HOME/janam_fota&quot; http://software.janam.com/update/
/dev/nvme0n1p2 915G 762G 107G 88% /
--2026-11-24 04:09:06-- http://software.janam.com/update/
Resolving software.janam.com (software.janam.com)... 198.12.241.48
Connecting to software.janam.com (software.janam.com)|198.12.241.48|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2537 (2.5K) [text/html]
Saving to: ‘/home/moon/janam_fota/index.html.tmp’
index.html.tmp 100%[===================&gt;] 2.48K --.-KB/s in 0s 
2026-11-24 04:09:07 (79.1 MB/s) - ‘/home/moon/janam_fota/index.html.tmp’ saved [2537/2537]
Removing /home/moon/janam_fota/index.html.tmp since it should be rejected.
--2026-11-24 04:09:07-- http://software.janam.com/update/?C=N;O=D
Reusing existing connection to software.janam.com:80.
HTTP request sent, awaiting response... 200 OK
Length: 2537 (2.5K) [text/html]
Saving to: ‘/home/moon/janam_fota/index.html?C=N;O=D.tmp’
index.html?C=N;O=D. 100%[===================&gt;] 2.48K --.-KB/s in 0s 
2026-11-24 04:09:07 (118 MB/s) - ‘/home/moon/janam_fota/index.html?C=N;O=D.tmp’ saved [2537/2537]
Removing /home/moon/janam_fota/index.html?C=N;O=D.tmp since it should be rejected.
--2026-11-24 04:09:07-- http://software.janam.com/update/?C=M;O=A
Reusing existing connection to software.janam.com:80.
HTTP request sent, awaiting response... 200 OK
Length: 2537 (2.5K) [text/html]
Saving to: ‘/home/moon/janam_fota/index.html?C=M;O=A.tmp’
index.html?C=M;O=A. 100%[===================&gt;] 2.48K --.-KB/s in 0s 
2026-11-24 04:09:08 (37.4 MB/s) - ‘/home/moon/janam_fota/index.html?C=M;O=A.tmp’ saved [2537/2537]
Removing /home/moon/janam_fota/index.html?C=M;O=A.tmp since it should be rejected.
--2026-11-24 04:09:08-- http://software.janam.com/update/?C=S;O=A
Reusing existing connection to software.janam.com:80.
HTTP request sent, awaiting response... 200 OK
Length: 2537 (2.5K) [text/html]
Saving to: ‘/home/moon/janam_fota/index.html?C=S;O=A.tmp’
index.html?C=S;O=A. 100%[===================&gt;] 2.48K --.-KB/s in 0.004s 
2026-11-24 04:09:08 (686 KB/s) - ‘/home/moon/janam_fota/index.html?C=S;O=A.tmp’ saved [2537/2537]
Removing /home/moon/janam_fota/index.html?C=S;O=A.tmp since it should be rejected.
--2026-11-24 04:09:08-- http://software.janam.com/update/?C=D;O=A
Reusing existing connection to software.janam.com:80.
HTTP request sent, awaiting response... 200 OK
Length: 2537 (2.5K) [text/html]
