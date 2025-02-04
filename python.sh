#!/bin/bash -e

if [ "$EUID" -eq 0 ]
  then echo "This script cannot be run as root as it has user config."
  exit
fi

# make sure pythong 3 with venv is installed
sudo apt install -y python3-venv

# create a default working space
python3 -m venv ~/venv/ml
source ~/venv/ml/bin/activate

pip install ipython jupyter
pip install numpy scipy pandas scikit-learn statsmodels matplotlib seaborn nltk gensim torch

# Now that we have a setup for multiple enviroments, we make this
# user an activate function for switching between them.
echo '

function venv {
    local NAME=$1

    if [ -z "$NAME" ]; then
        echo "Please pass a name for your venv."
        exit
    fi

    python3 -m venv $NAME ~/venv/$NAME
}

function activate {
    local NAME=$1
    
    if [ -z "$NAME" ]; then
        NAME=default
    fi
    
    local ACTIVATE_FILE=~/venv/$NAME/bin/activate
    if [ ! -f $ACTIVATE_FILE ]
        then echo "Could not find activate file: $ACTIVATE_FILE"
    else
        deactivate || echo "[INFO] No active venv to deactivate"
        source $ACTIVATE_FILE
        alias notebook="jupyter notebook --ip=0.0.0.0 --no-browser &"
        PS1="($NAME) \[\e[166;33;82m\e[1m\]\w\[\e[m\]\\$ "
    fi    
}
' >> ~/.bashrc


