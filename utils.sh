#!/bin/bash

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
          echo "Error: Invalid argument: $1"
          return 1
      esac
      shift
    done
    
    ssh -p $ssh_port -N -f -L localhost:$local_port:localhost:$notebook_port $ssh_host
}
