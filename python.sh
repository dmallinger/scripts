#!/bin/bash -e

if [ "$EUID" -eq 0 ]
  then echo "This script cannot be run as root as it has user config."
  exit
fi

python3 -m venv ~/venv/default

pip install ipython jupyter
pip install numpy scipy sklearn gensim

# Now that we have a setup for multiple enviroments, we make this
# user an activate function for switching between them.
echo '

function activate {
    local NAME=$1
    
    if [ -z "$NAME" ]; then
        NAME=default
    fi
    
    local ACTIVATE_FILE=~/venv/$NAME/bin/activate
    if [ ! -f $ACTIVATE_FILE ]
        then echo "Could not find activate file: $ACTIVATE_FILE"
    else
        deactivate || echo "No activate venv to deactivate"
        source $ACTIVATE_FILE
        alias notebook="jupyter notebook --ip=$HOSTNAME --no-browser &"
    fi    
}
' >> ~/.bashrc


