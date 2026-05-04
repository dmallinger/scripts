#!/bin/bash -e

# this script must be run as root
if [ "$EUID" -ne 0 ]
  then echo "Please re-run as root (i.e. sudo [this script].sh)."
  exit
fi

# install uv
curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh

# give all users a few handy aliases
echo '

function venv {
    local NAME=$1
    local VERSION=$2

    if [ -z "$NAME" ]; then
        echo "Please pass a name for your venv."
    else
        if [ -z "$VERSION" ]; then
            uv venv ~/venv/$NAME
        else
	    uv venv --python $VERSION ~/venv/$NAME
	fi
    fi
}

function activate {
    local NAME=$1
    
    if [ -z "$NAME" ]; then
        echo "Please pass the name of your venv."
    else
        local ACTIVATE_FILE=~/venv/$NAME/bin/activate
	if [ ! -f $ACTIVATE_FILE ]; then
            echo "Could not find activate file: $ACTIVATE_FILE"
	else
            deactivate || echo "[INFO] No active venv to deactivate"
	    source $ACTIVATE_FILE
	    alias notebook="jupyter notebook --ip=0.0.0.0 --no-browser &"
            PS1="($NAME) \[\e[166;33;82m\e[1m\]\w\[\e[m\]\\$ "
        fi
    fi
}    
' >> /etc/bash.bashrc

echo "
Complete.

You will now need to restart the shell to enable uv."
