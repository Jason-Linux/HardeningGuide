# Hardening Linux
1.	Configuration Machine
    1.1 BIOS / UEFI
        - Mot de passe sur le bios et passage en uefi préconisé.
    1.2 Certificat préchargé
        - Possible de mettre des certificats en dur dans le SHIM qui est une application EFI.
    1.3 TPM
        - Utilisé la puce TPM pour trust le matériel et chiffrer les données.

2.	Configuration du Noyau
    2.1 Grub    
        - Configurer un mot de passe GRUB
    2.2 Configuration Mémoire
        – Forcer l’activation D’IOMMU
        – Liste des options de configuration de la mémoire recommandé.
    2.3 Noyau
        - Paramétré sysctl.conf
        - Désactivation des modules kernel
        - Décompilation du noyau CF R15 à R23 + R25
    2.4 Gestion des processus
        - Paramétré yama
        - P2
        - P3
    2.5 Configuration du réseau IPV4
        - CF R12 du guide de hardening
    2.6 Désactivation IPV6
        – Modification Grub
        – Modification Sysctl.conf
    2.7 Configuration des systèmes de fichiers
        - CF R14

3.	Configuration Système
    3.1 Partionnement
        – LVM
        – Séparer Home / SRV / VAR dans des points de montage différent.
    3.2 Gestion des droits
        –	Restreindre les accès au boot
    3.3 Comptes
        – Désactiver les comptes inutilisés
        – Mots de passe robustes (10 tous les caractères / unique par poste)
        – Inactivité des comptes.
        – Gestion des droits admin sudo
        - Verrouillage d’un compte
        - Désactivation shell
        – Création de compte de services
        - Doit avoir son propre compte système
        – Gestion des droits UMASK / DAC & MAC
        – Un groupe sudo dédié
        - Plusieurs Groupe Sudo avec des droits différents
        - R40 à R45
    3.4 SELINUX
        – Configurer les droits SELINUX des applications
        – R46
        – Utilisateur confiné selinux : https://access.redhat.com/documentation/fr-fr/red_hat_enterprise_linux/8/html/using_selinux/managing-confined-and-unconfined-users_using-selinux
        – Limiter les variables SELinux (R48)
        – Desinstaller ■ setroubleshootd, ■ setroubleshoot-server, ■ setroubleshoot-plugins.
    3.5 Fichiers
        – Fichier Et Repertoire droit Setuid et setgid et RWX
        – Fichier Sensible
        - Rendre visible que pour root les endroits avec des mots de passe et des Empreintes
```conf
-rw-r----- root root /etc/gshadow 
-rw-r----- root root /etc/shadow 
-rw------- foo users /home/foo/.ssh/id_rsa
```
        - Manager en function des groupes owner
        – Isoler les sockets et les fichiers IPC
        – Tout les dossiers et fichiers doivent être assigné à un utilisateur et un groupe
        – Stickitbit sur les répertoires inscriptibles
        – Séparer les Temp de chaque user
        - Utiliser tmpfiles
        – Éviter l'usage d'exécutables avec les droits spéciaux setuid root et setgid root
    3.6 Gestion des paquets
        - Installation minimaliste avec seulement les services dédiés
        - Repo de confiance

4.0 Services
        - Désactiver les services non nécessaires ou les fonctionnalités des services non essentielles
        - Configurer Les privilèges des services
    4.1 Cloisonnement des services
        – Isolation des systèmes
        – Docker
    4.2 Journaliser le système
        - Journaliser l’activité système avec auditd
        Le fichier de configuration /etc/audit/audit.rules de auditd suivant enregistre
**les actions présentant un intérêt :**
```shell
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
```
    4.3 Messagerie Locale
        –	Durcir le service de messagerie
        –	Alias de messagerie des comptes de service
