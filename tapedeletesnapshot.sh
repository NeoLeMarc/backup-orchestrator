#!/bin/bash

echo "Configuration: $1"

# Delete snapshots
zfs destroy vault/encrypted@amanda_$1
zfs destroy vault/backup@amanda_$1
btrfs subvol delete /snapshot_amanda_$1
btrfs subvol delete /home/snapshot_amanda_$1
btrfs subvol delete /var/lib/libvirt/images/snapshot_amanda_$1
