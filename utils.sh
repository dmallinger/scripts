#!/bin/zsh

# Generate Password
# Takes a parameter (default 20) and returns a random password
# of that length with easy to delineate characters.
function gen_pass {
    local length=$1
    if [ -z "$length" ]; then
        length=20
    fi
    echo $(cat /dev/urandom | LC_ALL=C tr -dc 'a-hj-kp-tw-yAE-HJ-KP-RT-Y2-69!@#&?+=' | fold -$length | head -1)
}



# Tunnel to Jupyter Notebook
# Takes parameters by order and then opens an SSH tunnel that allows
# you to open Notebooks on the remote server locally.
#
# Example usage: `notebook_tunnel hostname 22 8888 8888`
function notebook_tunnel {
    ssh -p $2 -N -f -L localhost:${4}:localhost:$3 $1
}

