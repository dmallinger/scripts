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


# configure Dynu
sudo add-apt-repository ppa:dotnet/backports
sudo apt install -y dotnet-runtime-6.0
sudo wget --trust-server-names https://www.dynu.com/support/downloadfile/67
sudo apt install -y ./dynu-ip-update-client_0.1.0-1_amd64.deb

# configure the RSA token creator.  Not required but helpful
# for places where digital 2FA is not supported but physical devices are
apt install -y python3-pip qrencode pipx
pipx install python-vipaccess


# Similarly, configure Yubico Authenticator for using keys from this
# machine when it's a desktop.
add-apt-repository -y ppa:yubico/stable && apt -y update
apt install -y yubioath-desktop


# Ensure all services are running with the right configs
systemctl restart ssh fail2ban sendmail dynu-ip-update-client.service


# Exiting
echo '
Setup complete. Do not forget to configure your 2FA app.
To generate one for your current user run the following:
     google-authenticator -t -d -f -w 3 -u -l "$USER@$HOSTNAME"

If you want to run DDNS make sure you do the following:
     `sudo vi /usr/share/dynu-ip-update-client/appsettings.json`
     Update the configurations and then run:
     `sudo systemctl restart dynu-ip-update-client.service`

Lastly, definitely check that everything works as expected.
'
