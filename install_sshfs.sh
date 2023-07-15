#!/bin/bash
# Enable ssh connexions to distant volumes. Will not work under Docker rootless mode.

if [ "$-" = "${-%a*}" ]; then
    # allexport is not set
    set -a
    . ./.env
    set +a
else
    . ./.env
fi

sudo docker plugin install vieux/sshfs sshkey.source=$SSHKEYS_PATH

#to remove the plugin :
#docker plugin rm vieux/sshfs