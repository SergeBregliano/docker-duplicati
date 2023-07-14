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

docker plugin install vieux/sshfs sshkey.source=$SSHKEYS_PATH
