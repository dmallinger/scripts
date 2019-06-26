#!/bin/bash -e

# this script must be run as root
if [ "$EUID" -ne 0 ]
  then echo "Please re-run as root (i.e. sudo [this script].sh)."
  exit
fi

# Start by updating
apt -y update
apt -y upgrade

# Other packages we rely on
apt install -y screen tmux vim curl git
apt install -y python3-venv
