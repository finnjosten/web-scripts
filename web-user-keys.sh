#!/bin/bash

# v1.0.0

clone_keys="/opt/admin-scripts/clone_keys"

for userdir in /home/*; do
    [ -d "$userdir" ] || continue
    if [ -f "$userdir/.web-user" ] && [ ! -f "$userdir/.web-user-ignore-keys" ]; then
        auth_keys="$userdir/.ssh/authorized_keys"
        if [ -f "$auth_keys" ]; then
            > "$auth_keys" # clear file
            cat "$clone_keys" > "$auth_keys"
            chown $(basename "$userdir"):$(basename "$userdir") "$auth_keys"
            chmod 600 "$auth_keys"
            echo "Updated authorized_keys for $(basename "$userdir")"
        fi
    fi
done
