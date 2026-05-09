#!/bin/bash -e

# this script must be run as root
if [ "$EUID" -ne 0 ]
  then echo "Please re-run as root (i.e. sudo [this script].sh)."
  exit
fi

# Start by updating
apt -y update
apt -y upgrade

# Set up auto updates
apt install -y unattended-upgrades
dpkg-reconfigure -f noninteractive --priority=low unattended-upgrades
sed -i 's/^.*Unattended-Upgrade::Automatic-Reboot "false".*$/Unattended-Upgrade::Automatic-Reboot "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's/^.*Unattended-Upgrade::Automatic-Reboot-WithUsers.*$/Unattended-Upgrade::Automatic-Reboot-WithUsers "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's/^.*Unattended-Upgrade::Automatic-Reboot-Time.*$/Unattended-Upgrade::Automatic-Reboot-Time "04:00";/g' /etc/apt/apt.conf.d/50unattended-upgrades

# Other packages we rely on
apt install -y screen tmux xscreensaver
apt install -y vim curl git npm
apt install -y pavucontrol # helps audio out over HDMI on Ubuntu
