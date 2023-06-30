# Guide Hardening

# Configurer SSH
sudo echo '
ClientAliveInterval 1
ClientAliveCountMax 1800
AllowUsers alfactory.user opensecu.adm
' >> /etc/ssh/sshd_config
sudo sed -i 's/PrintMotd no/PrintMotd yes/g' /etc/ssh/sshd_config
sudo systemctl reload sshd
