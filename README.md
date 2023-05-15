#  Управление процессами 

Задание:

```text
Написать свою реализацию ps ax используя анализ /proc
```

Выполнение:

Вывод команды `ps ax` (для примера PID: 4863)

```shell
root@rul-ubuntu:/home/rul/dz10_processes# ps ax -q 4863
    PID TTY      STAT   TIME COMMAND
   4863 ?        Sl     2:06 /snap/firefox/2667/usr/lib/firefox/firefox
```

### Какие параметры `ps ax` где можно взять в `/proc`

#### PID

Столбец `PID` это сама поддиректория:

```shell
/proc/<PID>/
```

#### STAT

Столбец `STAT` это 3 показатель `/proc/4863/stat`, но так как возможны пробельные символы во втором столбце с комментарием, то необходимо сделать манипуляцию `взять 50 показатель с конца`
```shell
cat /proc/3906/stat | rev | awk '{printf $50}' | rev
    S
```

#### TIME

Столбец TIME это суммарное время 14, 15, 16 и 17 показателей `/proc/4863/stat`
```shell
[root@proc vagrant]# cat /proc/4863/stat
3906 (vim) T 3874 3906 3844 34816 4049 1077952768 823 0 3 0 3 3 0 0 20 0 1 0 33781 45084672 1932 18446744073709551615 94352897490944 94352900339976 140727042651408 0 0 0 0 12288 1837125375 0 0 0 17 0 0 0 3 0 0 94352902437872 94352902602320 94352921636864 140727042660078 140727042660087 140727042660087 140727042662383 0					    (1)   (2) ^space    (3) (4)  
      14    15   16 17 
      
root@rul-ubuntu:/home/rul/dz10_processes# cat /proc/4863/stat
4863 (firefox) S 2186 2186 2186 0 -1 4194560 921273 48904 21695 645 9345 3417 238 65 20 0 106 0 1832827 4369510400 93807 18446744073709551615 94720681172992 94720681796152 140726164353712 0 0 0 0 4096 17663 0 0 0 17 1 0 0 0 0 0 94720681800656 94720681805048 94720714387456 140726164359459 140726164359502 140726164359502 140726164365261 0                                          (1)   (2) ^space    (3) (4)                                    14    15   16 17 

cat /proc/4863/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev
9513 3515 238 65

cat /proc/4863/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print strftime(sum)}'
13369


cat /proc/4863/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print sum/100}' | awk '{("date +%T -d @"$1)| getline $1}1'
  03:02:13
  ↑  ↑
  ╎  ╎
  ╎  ВРЕМЯ НО 
  ╎
  C ЧАСАМИ
     
ps ax -q 4863 -o time
    TIME
    00:02:11
    ↑  ↑
    ╎  ╎
    ╎  ВРЕМЯ НО 
    ╎
    БЕЗ ЧАСОВ

cat /proc/4863/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print sum/100}' | awk '{("date +%M:%S -d @"$1)| getline $1}1'
    02:15
```

#### COMMAND

Столбец `COMMAND` это содержание
```shell
cat /proc/4863/cmdline 
/snap/firefox/2667/usr/lib/firefox/firefoxroot@rul-ubuntu:/home/rul/dz10_processes# 
```

#### TTY

Тут немного не понятно как декодировать, но подход такой

```shell
man proc
...
    (7) tty_nr  %d
    The controlling terminal of the process.  
    (The minor device number is contained in the combination of bits 31 to 20 and 7 to 0; 
    the major device number is in bits 15 to 8.)
...

```

### Результат


[Реализация разработанного скрипта](psax.sh)

```shell
#!/bin/bash

_pid(){
  echo "${PROC_PID/\/proc\//}"
}

_stat(){
  if [ -f ${PROC_PID}/stat ]; then
    cat ${PROC_PID}/stat | rev | awk '{printf $50}' | rev
  else
    echo 'n/a'
  fi
}

_time(){
  if [ -f ${PROC_PID}/stat ]; then
    cat ${PROC_PID}/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print sum/100}' | awk '{("date +%M:%S -d @"$1)| getline $1}1'
  else
    echo 'n/a'
  fi
}

_command(){
  if [ -f ${PROC_PID}/stat ]; then
  # предупреждение: подстановка команды: во входных данных проигнорирован нулевой байт
    cat ${PROC_PID}/cmdline | tr '\0' '\n' | sed -e s/DBUS_SESSION_BUS_ADDRESS=//
  else
    echo 'n/a'
  fi
}

for PROC_PID in `ls -d /proc/* | egrep "^/proc/[0-9]+"`; do
  echo $(_pid) $(_stat) $(_time) $(_command);
done

```

<details><summary>Результат вывода в консоль</summary>

```properties
1 S 00:25 /sbin/init splash
10 I 00:00
1020 S 00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
1035 S 00:00 /usr/sbin/gdm3
11 I 00:00
1102 S 00:00 /usr/libexec/rtkit-daemon
12 I 00:00
13 I 00:00
1353 I 00:00
1354 S 00:00
14 S 00:00
141 I 00:00
15 I 00:07
1532 S 00:01 /usr/libexec/upowerd
16 S 00:00
1620 S 00:18 /usr/libexec/packagekitd
17 S 00:00
1781 S 00:00 /usr/libexec/colord
1849 S 00:00 /usr/sbin/cups-browsed
1854 S 00:00 /sbin/rpc.statd
1858 S 00:00 /usr/sbin/rpc.mountd
1859 S 00:00 /usr/sbin/kerneloops --test
1864 S 00:00 /usr/sbin/kerneloops
1868 S 00:00
1872 S 00:00
1873 S 00:00
1874 S 00:00
1875 S 00:00
1876 S 00:00
1877 S 00:00
1878 S 00:00
1879 S 00:00
19 S 00:00
190 I 00:00
1912 S 00:00 gdm-session-worker [pam/gdm-password]
193 S 00:00
1930 S 00:05 /lib/systemd/systemd --user
1931 S 00:00 (sd-pam)
1937 S 00:00 /usr/bin/pipewire
1938 S 00:00 /usr/bin/pipewire-media-session
1939 S 00:00 /usr/bin/pulseaudio --daemonize=no --log-target=journal
194 I 00:00
195 S 00:00
1952 S 00:00 /usr/bin/gnome-keyring-daemon --daemonize --login
1956 S 00:01 /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
1959 S 00:00 /usr/libexec/gvfsd
196 I 00:00
1964 S 00:00 /usr/libexec/gvfsd-fuse /run/user/1000/gvfs -f
197 S 00:00
198 I 00:00
1989 S 00:00 /usr/libexec/xdg-document-portal
1992 S 00:00 /usr/libexec/xdg-permission-store
1998 S 00:00 fusermount3 -o rw,nosuid,nodev,fsname=portal,auto_unmount,subtype=portal -- /run/user/1000/doc
2 S 00:00
20 S 00:00
2026 S 00:00 /usr/libexec/tracker-miner-fs-3
204 I 00:00
2056 S 00:00
2072 S 00:00 /usr/libexec/gdm-wayland-session env GNOME_SHELL_SESSION_MODE=ubuntu /usr/bin/gnome-session --session=ubuntu
2077 S 00:00 /usr/libexec/gnome-session-binary --session=ubuntu
2096 S 00:01 /usr/libexec/gvfs-udisks2-volume-monitor
21 S 00:00
2113 S 00:00 /usr/libexec/gvfs-mtp-volume-monitor
2123 S 00:00 /usr/libexec/gvfs-goa-volume-monitor
2127 S 00:00 /usr/libexec/goa-daemon
2132 S 00:00 /usr/libexec/gnome-session-ctl --monitor
2146 S 00:00 /usr/libexec/gnome-session-binary --systemd-service --session=ubuntu
2154 S 00:00 /usr/libexec/goa-identity-service
2162 S 00:01 /usr/libexec/gvfs-afc-volume-monitor
2172 S 00:00 /usr/libexec/gvfs-gphoto2-volume-monitor
2186 S 04:06 /usr/bin/gnome-shell
2187 S 00:00 /usr/libexec/at-spi-bus-launcher --launch-immediately
2195 S 00:00 /usr/bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 11 --address=unix:path=/run/user/1000/at-spi/bus
22 S 00:00
2222 S 00:00 /usr/libexec/gnome-shell-calendar-server
2228 S 00:00 /usr/libexec/evolution-source-registry
2234 S 00:00 /usr/libexec/dconf-service
2239 S 00:00 /usr/libexec/evolution-calendar-factory
224 I 00:00
2252 S 00:00 /usr/libexec/evolution-addressbook-factory
2267 S 00:00 /usr/libexec/gvfsd-trash --spawner :1.2 /org/gtk/gvfs/exec_spaw/0
2277 S 00:00 /usr/bin/gjs /usr/share/gnome-shell/org.gnome.Shell.Notifications
2279 S 00:00 /usr/libexec/at-spi2-registryd --use-gnome-session
2291 S 00:00 sh -c /usr/bin/ibus-daemon --panel disable $([ "$XDG_SESSION_TYPE" = "x11" ] && echo "--xim")
2292 S 00:00 /usr/libexec/gsd-a11y-settings
2294 S 00:19 /usr/bin/ibus-daemon --panel disable
2295 S 00:00 /usr/libexec/gsd-color
2298 S 00:00 /usr/libexec/gsd-datetime
23 S 00:00
2301 S 00:01 /usr/libexec/gsd-housekeeping
2302 S 00:00 /usr/libexec/gsd-keyboard
2303 S 00:00 /usr/libexec/gsd-media-keys
2304 S 00:00 /usr/libexec/gsd-power
2306 S 00:00 /usr/libexec/gsd-print-notifications
2310 S 00:00 /usr/libexec/gsd-rfkill
2320 S 00:00 /usr/libexec/gsd-screensaver-proxy
2321 S 00:00 /usr/libexec/gsd-sharing
2328 S 00:00 /usr/libexec/gsd-smartcard
2330 S 00:00 /usr/libexec/gsd-sound
2339 S 00:00 /usr/libexec/gsd-wacom
2344 S 00:00 /usr/libexec/gsd-disk-utility-notify
2345 S 00:00 /snap/snapd-desktop-integration/83/usr/bin/snapd-desktop-integration
2353 S 00:00 /usr/lib/x86_64-linux-gnu/indicator-messages/indicator-messages-service
2383 S 00:00 /usr/libexec/evolution-data-server/evolution-alarm-notify
2393 S 00:00 /usr/libexec/ibus-memconf
2397 S 00:06 /usr/libexec/ibus-extension-gtk3
2402 S 00:00 /usr/libexec/ibus-portal
25 I 00:00
2516 S 00:00 /usr/libexec/gsd-printer
2523 S 00:07 /snap/snap-store/959/usr/bin/snap-store --gapplication-service
2537 S 00:00 /snap/snapd-desktop-integration/83/usr/bin/snapd-desktop-integration
2549 S 00:00 /usr/libexec/xdg-desktop-portal
2564 S 00:00 /usr/libexec/xdg-desktop-portal-gnome
2579 S 00:06 /usr/libexec/ibus-engine-simple
26 S 00:00
260 S 00:00
261 I 00:00
2666 S 00:00 /usr/libexec/xdg-desktop-portal-gtk
27 S 00:00
2701 S 00:00 /usr/bin/gjs /usr/share/gnome-shell/org.gnome.ScreenSaver
28 S 00:00
2814 S 00:00 /usr/libexec/gvfsd-metadata
29 S 00:03
3 I 00:00
31 I 00:00
314 S 00:00 /lib/systemd/systemd-journald
32 S 00:00
33 S 00:00
336 I 00:00
338 I 00:00
34 S 00:00
35 S 00:00
37 I 00:00
372 S 00:05 /lib/systemd/systemd-udevd
38 S 00:00
39 I 00:00
4 I 00:00
40 S 00:00
41 S 00:00
43 S 00:00
4361 S 00:03 update-notifier
438 S 00:00
4480 I 00:03
45 I 00:00
46 S 00:01
47 S 00:00
4722 I 00:14
48 S 00:00
4863 S 02:32 /snap/firefox/2667/usr/lib/firefox/firefox
49 I 00:00
495 I 00:00
4950 S 00:14 /usr/bin/Xwayland :0 -rootless -noreset -accessx -core -auth /run/user/1000/.mutter-Xwaylandauth.K4HG51 -listen 4 -listen 5 -displayfd 6 -initfd 7
4963 S 00:00 /usr/libexec/gsd-xsettings
499 I 00:00
4992 S 00:00 /usr/libexec/ibus-x11
5 I 00:00
50 I 00:00
5073 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -parentBuildID 20230512012512 -prefsLen 27791 -prefMapSize 235598 -appDir /snap/firefox/2667/usr/lib/firefox/browser {2e6ae555-057f-4742-b5d9-c6df2668c828} 4863 true socket
5094 S 00:01 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 1 -isForBrowser -prefsLen 27932 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {7e665f47-9c4c-4cef-9d2a-7de7a1b120b0} 4863 true tab
51 I 00:00
5132 S 00:00 /usr/bin/snap userd
514 I 00:05
518 S 00:01
5269 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 2 -isForBrowser -prefsLen 33404 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {bd992c35-649a-4b55-b1b6-d196b2f48afc} 4863 true tab
54 I 00:00
55 I 00:00
5558 S 03:08 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 3 -isForBrowser -prefsLen 29129 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {ec6b561b-c290-4235-bb94-b0ac02d1b645} 4863 true tab
5581 S 00:04 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 5 -isForBrowser -prefsLen 29129 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {5dbc5e80-841c-4abb-8d82-b6ae5b1ba5b3} 4863 true tab
56 I 00:00
560 S 00:00 /sbin/rpcbind -f -w
561 S 00:35 /lib/systemd/systemd-oomd
562 S 00:00 /lib/systemd/systemd-resolved
5635 S 00:02 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 6 -isForBrowser -prefsLen 29243 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {e5b12a72-65c6-40fd-bfaa-ae58370f4577} 4863 true tab
565 S 00:00 /lib/systemd/systemd-timesyncd
5656 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -parentBuildID 20230512012512 -prefsLen 33518 -prefMapSize 235598 -appDir /snap/firefox/2667/usr/lib/firefox/browser {006c9f51-75a6-450d-805a-217b15182f8b} 4863 true rdd
5658 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -parentBuildID 20230512012512 -sandboxingKind 0 -prefsLen 33518 -prefMapSize 235598 -appDir /snap/firefox/2667/usr/lib/firefox/browser {2dcb864b-1653-4c28-bb4d-b1d9bc875061} 4863 true utility
5684 S 00:07 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 7 -isForBrowser -prefsLen 29243 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {0d10db5b-4737-46b5-944d-43b783eebcbf} 4863 true tab
57 I 00:00
571 S 00:00 /usr/sbin/blkmapd
5719 S 00:03 /usr/bin/nautilus --gapplication-service
5754 S 00:17 /usr/libexec/gnome-terminal-server
578 S 00:00 /usr/sbin/rpc.idmapd
5780 S 00:12 bash
579 S 00:00 /usr/sbin/nfsdcld
58 I 00:00
5811 S 00:07 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 8 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {8df0831f-80a2-4bb2-9fe4-2abb4be872b4} 4863 true tab
5847 S 00:03 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 9 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {d24beca3-5684-40b2-9282-084dcdb50de6} 4863 true tab
5890 S 00:28 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 10 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {295f199b-665e-4cf0-b985-cc7ef02dec41} 4863 true tab
59 S 00:00
6 I 00:00
6030 S 00:01 /usr/lib/virtualbox/VBoxXPCOMIPCD
6036 S 00:18 /usr/lib/virtualbox/VBoxSVC --auto-shutdown
607 I 00:00
61 I 00:00
62 S 00:00
63 S 00:00
660 S 00:00
662 S 00:00
664 S 00:00
6697 S 01:17 /usr/lib/virtualbox/VBoxHeadless --comment dz10_processes_proc_1684168818283_95173 --startvm 6363dabc-315d-43bf-a79f-30d14d19ec05 --vrde config
6725 S 00:00 /usr/lib/virtualbox/VBoxNetDHCP --comment HostInterfaceNetworking-vboxnet0 --config /home/rul/.config/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.config --log /home/rul/.config/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.log
69 I 00:00
693 S 00:00 /usr/libexec/accounts-daemon
6938 I 00:00
694 S 00:00 /usr/sbin/acpid
697 S 00:00 avahi-daemon: running [rul-ubuntu.local]
698 S 00:00 /usr/lib/bluetooth/bluetoothd
701 S 00:00 /usr/sbin/cron -f -P
702 S 00:02 @dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
704 S 00:04 /usr/sbin/NetworkManager --no-daemon
7077 S 00:00 /usr/bin/ssh-agent -D -a /run/user/1000/keyring/.ssh
711 S 00:01 /usr/sbin/irqbalance --foreground
720 S 00:00 /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
723 S 00:02 /usr/libexec/polkitd --no-debug
726 S 00:00 /usr/libexec/power-profiles-daemon
727 S 00:00 /usr/sbin/rsyslogd -n -iNONE
728 S 00:07 /usr/lib/snapd/snapd
729 S 00:00 /usr/libexec/switcheroo-control
7299 S 00:01 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 12 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {e67489c9-0f42-43da-8096-8ab9fdd230f9} 4863 true tab
730 S 00:00 /lib/systemd/systemd-logind
731 S 00:02 /usr/sbin/thermald --systemd --dbus-enable --adaptive
732 S 00:03 /usr/libexec/udisks2/udisksd
7332 S 00:01 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 13 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {402b7efb-71ed-43b9-9579-d973b4a35d71} 4863 true tab
737 S 00:00 /sbin/wpa_supplicant -u -s -O /run/wpa_supplicant
742 S 00:00 avahi-daemon: chroot helper
75 I 00:00
7531 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 14 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {1c6d069e-1e33-4118-b034-32fb0da76e24} 4863 true tab
7558 I 00:07
7562 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 15 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {3e9ab070-93ac-465a-b767-1dfa84b325a3} 4863 true tab
758 S 00:01 /opt/cisco/anyconnect/bin/vpnagentd -execv_instance
7588 I 00:00
7598 S 04:50 /usr/bin/gedit --gapplication-service
76 S 00:00
7667 S 00:00 /usr/libexec/gvfsd-network --spawner :1.2 /org/gtk/gvfs/exec_spaw/1
7684 S 00:00 /usr/libexec/gvfsd-dnssd --spawner :1.2 /org/gtk/gvfs/exec_spaw/3
77 I 00:00
7742 I 00:00
7744 S 00:01 gjs /usr/share/gnome-shell/extensions/ding@rastersoft.com/ding.js -E -P /usr/share/gnome-shell/extensions/ding@rastersoft.com -M 0 -D 0:0:1366:768:1:27:0:0:0:0
7785 I 00:00
7823 I 00:01
7830 I 00:00
7957 I 00:00
8 I 00:00
8018 I 00:00
8055 I 00:00
81 I 00:00
8171 I 00:00
82 I 00:00
8202 I 00:00
8214 S 00:00 /snap/firefox/2667/usr/lib/firefox/firefox -contentproc -childID 16 -isForBrowser -prefsLen 29421 -prefMapSize 235598 -jsInitLen 238780 -parentBuildID 20230512012512 -appDir /snap/firefox/2667/usr/lib/firefox/browser {20c44658-6afe-4a5a-811f-05f073399c0d} 4863 true tab
8234 I 00:00
8261 S 00:07 /bin/bash ./psax.sh
8262 n/a n/a n/a
8263 n/a n/a n/a
8264 n/a n/a n/a
83 I 00:00
88 I 00:00
94 I 00:00
985 S 00:00 /usr/sbin/cupsd -l
988 S 00:00 /usr/sbin/ModemManager
993 S 00:00 /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
```

</details>


