# Домашнее задание: развернуть сервис NFS и подключить к нему клиента


## Решение:

Задание выполнено на машине vagrant с помощью Ansible.

Скрипт `deploy.sh`:
 - создаёт две виртуальные машины с помощью Vagrantfile;
 - заускает роли:
   - manage_nfss (настройка сервера);
   - manage_nfsc (настройка клиента);
   - test (тестирование результата);
 - получает лог из виртуальной машины. 

Файлы с логами, полученными после отработки ролей находится в директории со скриптом `deploy.sh`

<details>
<summary>Лог настройки сервера</summary>

```bash
 Посмотрим прослушиваемые порты (ss -tnplu) 

Netid  State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
udp    UNCONN     0      0         *:732                   *:*                   users:(("rpcbind",pid=566,fd=7))
udp    UNCONN     0      0      127.0.0.1:755                   *:*                   users:(("rpc.statd",pid=4394,fd=7))
udp    UNCONN     0      0         *:2049                  *:*                  
udp    UNCONN     0      0      127.0.0.1:323                   *:*                   users:(("chronyd",pid=568,fd=1))
udp    UNCONN     0      0         *:68                    *:*                   users:(("dhclient",pid=2635,fd=6))
udp    UNCONN     0      0         *:20048                 *:*                   users:(("rpc.mountd",pid=4398,fd=7))
udp    UNCONN     0      0         *:46185                 *:*                   users:(("rpc.statd",pid=4394,fd=8))
udp    UNCONN     0      0         *:111                   *:*                   users:(("rpcbind",pid=566,fd=6))
udp    UNCONN     0      0         *:44236                 *:*                  
udp    UNCONN     0      0        :::732                  :::*                   users:(("rpcbind",pid=566,fd=10))
udp    UNCONN     0      0        :::2049                 :::*                  
udp    UNCONN     0      0        :::43786                :::*                   users:(("rpc.statd",pid=4394,fd=10))
udp    UNCONN     0      0       ::1:323                  :::*                   users:(("chronyd",pid=568,fd=2))
udp    UNCONN     0      0        :::20048                :::*                   users:(("rpc.mountd",pid=4398,fd=9))
udp    UNCONN     0      0        :::49505                :::*                  
udp    UNCONN     0      0        :::111                  :::*                   users:(("rpcbind",pid=566,fd=9))
tcp    LISTEN     0      64        *:2049                  *:*                  
tcp    LISTEN     0      128       *:56846                 *:*                   users:(("rpc.statd",pid=4394,fd=9))
tcp    LISTEN     0      128       *:111                   *:*                   users:(("rpcbind",pid=566,fd=8))
tcp    LISTEN     0      64        *:45264                 *:*                  
tcp    LISTEN     0      128       *:20048                 *:*                   users:(("rpc.mountd",pid=4398,fd=8))
tcp    LISTEN     0      128       *:22                    *:*                   users:(("sshd",pid=884,fd=3))
tcp    LISTEN     0      100    127.0.0.1:25                    *:*                   users:(("master",pid=1100,fd=13))
tcp    LISTEN     0      64       :::2049                 :::*                  
tcp    LISTEN     0      128      :::58988                :::*                   users:(("rpc.statd",pid=4394,fd=11))
tcp    LISTEN     0      64       :::43662                :::*                  
tcp    LISTEN     0      128      :::111                  :::*                   users:(("rpcbind",pid=566,fd=11))
tcp    LISTEN     0      128      :::20048                :::*                   users:(("rpc.mountd",pid=4398,fd=10))
tcp    LISTEN     0      128      :::22                   :::*                   users:(("sshd",pid=884,fd=4))
tcp    LISTEN     0      100     ::1:25                   :::*                   users:(("master",pid=1100,fd=14))


 Посмотрим экспортированные директории (exportfs -s) 

/srv/share  192.168.56.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)


```
</details>

<details>
<summary>Лог настройки клиента</summary>

```bash

 Проверяем, что /mnt примонтирован (mount | grep mnt ) 

systemd-1 on /mnt type autofs (rw,relatime,fd=51,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=31098)
192.168.56.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.10)

```
</details>

<details>
<summary>Лог теста сервера</summary>

```bash

Проверим с клиента наличие файла на сервере (ls -la /srv/share/upload/) 

total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 19 20:37 .
drwxrwxrwx. 3 nfsnobody nfsnobody 20 Jan 19 20:36 ..
-rw-r--r--. 1 root      root       0 Jan 19 20:37 check_file
-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 19 20:37 client_file


 Проверяем статус сервера NFS  (systemctl status nfs) 

● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Fri 2024-01-19 20:39:01 UTC; 1min 9s ago
  Process: 1018 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 992 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 990 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 992 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service

Jan 19 20:39:01 nfss systemd[1]: Starting NFS server and services...
Jan 19 20:39:01 nfss systemd[1]: Started NFS server and services.


 Проверяем статус firewall (systemctl status firewalld) 

● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2024-01-19 20:38:57 UTC; 1min 13s ago
     Docs: man:firewalld(1)
 Main PID: 570 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─570 /usr/bin/python -Es /usr/sbin/firewalld --nofork --nopid

Jan 19 20:38:56 nfss systemd[1]: Starting firewalld - dynamic firewall daemon...
Jan 19 20:38:57 nfss systemd[1]: Started firewalld - dynamic firewall daemon.


 Проверяем статус exportfs (exportfs -s) 

/srv/share  192.168.56.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)


 Проверяем статус RPC (showmount -a 192.168.56.10) 

All mount points on 192.168.56.10:
192.168.56.11:/srv/share
```
</details>

<details>
<summary>Лог теста клиента</summary>

```bash
 Проверим с клиента наличие файла на сервере (ls -la /mnt/upload) 

total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 24 Jan 19 20:37 .
drwxrwxrwx. 3 nfsnobody nfsnobody 20 Jan 19 20:36 ..
-rw-r--r--. 1 root      root       0 Jan 19 20:37 check_file


 Проверим с клиента наличие файла на сервере (ls -la /mnt/upload) 

total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 19 20:37 .
drwxrwxrwx. 3 nfsnobody nfsnobody 20 Jan 19 20:36 ..
-rw-r--r--. 1 root      root       0 Jan 19 20:37 check_file
-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 19 20:37 client_file


 Проверяем статус RPC (showmount -a 192.168.56.10) 

All mount points on 192.168.56.10:


 Проверяем статус RPC (mount | grep mnt) 

systemd-1 on /mnt type autofs (rw,relatime,fd=36,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11734)


 Проверим с клиента наличие файла на сервере (ls -la /mnt/upload) 

total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 43 Jan 19 20:37 .
drwxrwxrwx. 3 nfsnobody nfsnobody 20 Jan 19 20:36 ..
-rw-r--r--. 1 root      root       0 Jan 19 20:37 check_file
-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 19 20:37 client_file


 Проверим с клиента наличие файла на сервере (ls -la /mnt/upload) 

total 0
drwxrwxrwx. 2 nfsnobody nfsnobody 62 Jan 19 20:41 .
drwxrwxrwx. 3 nfsnobody nfsnobody 20 Jan 19 20:36 ..
-rw-r--r--. 1 root      root       0 Jan 19 20:37 check_file
-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 19 20:37 client_file
-rw-r--r--. 1 nfsnobody nfsnobody  0 Jan 19 20:41 final_check


```
</details>