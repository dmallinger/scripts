#!/bin/bash

# Generate Password
# Takes a parameter (default 20) and returns a random password
# of that length with easy to delineate characters.
function gen_pass {
    echo perl -le 'my @chars = split("", join("", a..h, j..k, p..z, A..A, C..H, J..K, P..R, T..Y, 2..9, "!@#%&*-?+=")); print map{@chars [rand $#chars]} 0..((shift||20)-1)' $1
}


# Tunnel to Jupyter Notebook
# Takes parameters by name and then opens an SSH tunnel that allows
# you to open Notebooks on the remote server locally.
function notebook_tunnel {
    local ssh_host=""
    local ssh_port=2222
    local local_port=8888
    local notebook_port=8888
    
    while [ $# -gt 0 ]; do
      case "$1" in
        --ssh-host=*)
          ssh_host="${1#*=}"
          ;;
        --ssh-port=*)
          ssh_port="${1#*=}"
          ;;
        --local-port=*)
          local_port="${1#*=}"
          ;;
        --notebook-port=*)
          notebook_port="${1#*=}"
          ;;
        *)
          printf "* Error: Invalid argument.*\n"
          return 1
      esac
      shift
    done
    
    ssh -p $ssh_port -N -f -L localhost:$local_port:localhost:$notebook_port $ssh_host
}
