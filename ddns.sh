#!/bin/bash -e

# this script must be run as root
if [ "$EUID" -ne 0 ]
  then echo "Please re-run as root (i.e. sudo [this script].sh)."
  exit
fi

mkdir -p /etc/dynu/
echo '
#!/bin/bash

USERNAME=ENTERUSERNAME
PASSWORD=ENTERHASHEDPASSWORD

URL="https://api.dynu.com/nic/update?username=${USERNAME}&password=${PASSWORD}"

ANSWER=$(wget -q -O - "$URL")

echo $ANSWER' > /etc/dynu/cron.sh

echo '
*/15 * * * * root /etc/dynu/cron.sh' > /etc/cron.d/dynu

echo '
Process complete.

Please edit /etc/dynu/cron.sh and update the USERNAME and PASSWORD (hashed).'
