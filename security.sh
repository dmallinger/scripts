#!/bin/bash -e

# this script must be run as root
if [ "$EUID" -ne 0 ]
  then echo "Please re-run as root (i.e. sudo [this script].sh)."
  exit
fi


# Start by updating
apt -y update
apt -y upgrade


# Update `su` to only be runnable by root.  Other users will need to `sudo su`
sed -i 's/^.*auth[[:space:]]*required[[:space:]]*pam_wheel.so$/auth\trequired\tpam_wheel.so/g' /etc/pam.d/su


# Ubuntu desktop doesn't include SSH by default
apt install -y openssh-server
# Disable root login
sed -i 's/^.*PermitRootLogin.*$/PermitRootLogin no/g' /etc/ssh/sshd_config
# Move SSH to a nonstandard port
sed -i 's/^.*Port 22.*$/Port 2222/g' /etc/ssh/sshd_config
# And ensure SSH supports 2FA
sed -i 's/^UsePAM.*$/UsePAM yes/g' /etc/ssh/sshd_config
sed -i 's/^KbdInteractiveAuthentication.*$/KbdInteractiveAuthentication yes/g' /etc/ssh/sshd_config


# Install and enable Fail2Ban to block attacks
apt install -y fail2ban sendmail
touch /etc/fail2ban/fail2ban.local
touch /etc/fail2ban/jail.local
echo "
[DEFAULT]
bantime = 1800

[sshd]
port    = 2222" >> /etc/fail2ban/jail.local
# Open the firewall and enable fail2ban
ufw allow 2222
ufw enable


# This will allow us to make and require 2FA tokens for users.
# Despite the name, the Google apps will not be required by users
apt install -y libpam-google-authenticator


# Update PAM to require 2FA on SSH as well as `sudo`
echo "#
# /etc/pam.d/common-2fa - settings for requiring 2FA
# 
auth    required    pam_google_authenticator.so" > /etc/pam.d/common-2fa
echo "@include common-2fa" >> /etc/pam.d/sshd
echo "@include common-2fa" >> /etc/pam.d/sudo


# Install Yubico Authenticator
apt install -y pcscd
systemctl enable --now pcscd
curl -o /tmp/yubico-authenticator.tar.gz https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-7.3.3-linux.tar.gz
mkdir /etc/yubico-authenticator
tar -xzf yubico-authenticator.tar.gz -C /etc/yubico-authenticator --strip-components=1
ln -s /etc/yubico-authenticator/authenticator /usr/local/bin/yubico-authenticator


# Ensure all services are running with the right configs
systemctl restart ssh fail2ban sendmail pcscd


# Exiting
echo '
Setup complete. Do not forget to configure your 2FA app.
To generate one for your current user run the following:
     google-authenticator -t -d -f -w 3 -u -l "$USER@$HOSTNAME"

Lastly, definitely check that everything works as expected.'
