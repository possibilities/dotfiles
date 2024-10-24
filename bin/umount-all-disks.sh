#!/bin/bash

# Unmount all drives in /media
for mount_point in /media/*; do
    if mountpoint -q "$mount_point"; then
        echo "Unmounting $mount_point..."
        sudo veracrypt --text --dismount "$mount_point" --non-interactive
        if [ $? -eq 0 ]; then
            echo "Successfully unmounted $mount_point."
        else
            echo "Failed to unmount $mount_point. It may be in use."
        fi
    else
        echo "$mount_point is not a mount point."
    fi
done

echo "Unmounting process completed."
