#!/bin/bash

# v1.0.1

# Ensure groups exist
getent group pm2users >/dev/null || groupadd pm2users
getent group webusers >/dev/null || groupadd webusers

for userdir in /home/*; do
    [ -d "$userdir" ] || continue
    if [ -f "$userdir/.web-user" ] && [ ! -f "$userdir/.web-user-ignore-groups" ]; then
        usermod -aG pm2users $(basename "$userdir")
        usermod -aG webusers $(basename "$userdir")
        echo "Updated groups for $(basename "$userdir")"
    fi
done
