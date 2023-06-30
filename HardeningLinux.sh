#!/bin/bash

# Creation groupe
groupadd sualfa
groupadd suopen

# Droit Sudo
apt install sudo
echo '
%sualfa $HOSTNAME=(ALL) ALL
%suopen $HOSTNAME=(ALL) ALL
' >> /etc/sudoers

# Creation Uilisateur
pass=$(openssl rand -base64 16)
user="opensecu.adm"
sudo useradd -m $user --group sudo  --shell /bin/bash
adduser $user suopen
adduser $user docker
echo $user:$pass | sudo chpasswd
echo $pass

pass=$(openssl rand -base64 16)
user="alfactory.adm"
sudo useradd -m $user --group sudo  --shell /bin/bash
adduser $user sualfa
adduser $user docker
echo $user:$pass | sudo chpasswd
echo $pass

pass=$(openssl rand -base64 16)
user="opensecu.user"
sudo useradd -m $user --group sudo  --shell /bin/bash
echo $user:$pass | sudo chpasswd
echo $pass

pass=$(openssl rand -base64 16)
user="alfactory.user"
sudo useradd -m $user --group sudo  --shell /bin/bash
echo $user:$pass | sudo chpasswd
echo $pass

# Configuration du kernel
sudo echo '
# Configuration du kernel
kernel_module_disabled=1
kernel.yama.ptrace_scope=2' >> /etc/sysctl.conf

# Configuration de la configuration réseaux
sudo echo '
# Configuration de la configuration réseaux
# IPV4
net.core.bpf_jit_harden=2
net.ipv4.ip_forward=0
net.ipv4.conf.all.accept_local=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.all.shared_media=0
net.ipv4.conf.default.shared_media=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.arp_filter=1
net.ipv4.conf.all.arp_ignore=2
net.ipv4.conf.all.route_localnet=0
net.ipv4.conf.all.drop_gratuitous_arp=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.ip_local_port_range=32768 65535
net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_syncookies=1
# IPV6
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.all.disable_ipv6=1
' >> /etc/sysctl.conf

echo 'GRUB_CMDLINE_LINUX=" ipv6.disable=1"' /etc/default/grub

# Configuration système de fichier
sudo echo '
# Configuration système de fichier
fs.suid_dumpable = 0
fs.protected_fifos=2
fs.protected_regular=2
fs.protected_symlinks=1
fs.protected_hardinks=1
' >> /etc/sysctl.conf

# Conf SSH mis à la main

# Service Audit
sudo apt install auditd

# Configuration Auditd
sudo echo '
# Exécution de insmod , rmmod et modprobe
-w /sbin/insmod -p x
-w /sbin/modprobe -p x
-w /sbin/rmmod -p x
# Sur les distributions GNU/Linux récentes , insmod , rmmod et modprobe sont
# des liens symboliques de kmod
-w /bin/kmod -p x
# Journaliser les modifications dans /etc/
-w /etc/ -p wa
# Surveillance de montage/démontage
-a exit,always -S mount -S umount2
# Appels de syscalls x86 suspects
-a exit,always -S ioperm -S modify_ldt
# Appels de syscalls qui doivent être rares et surveillés de près
-a exit,always -S get_kernel_syms -S ptrace
-a exit,always -S prctl
# Rajout du monitoring pour la création ou suppression de fichiers
# Ces règles peuvent avoir des conséquences importantes sur les
# performances du système
-a exit,always -F arch=b64 -S unlink -S rmdir -S rename
-a exit,always -F arch=b64 -S creat -S open -S openat -F exit=-EACCES
-a exit,always -F arch=b64 -S truncate -S ftruncate -F exit=-EACCES
# Rajout du monitoring pour le chargement , le changement et
# le déchargement de module noyau
-a exit,always -F arch=b64 -S init_module -S delete_module
-a exit,always -F arch=b64 -S finit_module
# Verrouillage de la configuration de auditd
-e 2
# Audit modification utilisateurs
-w /etc/passwd -p wa -k user-modify
' >> /etc/audit/audit.rules

