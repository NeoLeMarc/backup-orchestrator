#!/bin/bash

echo "Configuration: $1"

# Rotate snapshots
zfs destroy vault/encrypted@amanda_$1
zfs snapshot vault/encrypted@amanda_$1

zfs destroy vault/backup@amanda_$1
zfs snapshot vault/backup@amanda_$1

btrfs subvol delete /snapshot_amanda_$1
btrfs subvol snapshot -r / /snapshot_amanda_$1

btrfs subvol delete /home/snapshot_amanda_$1
btrfs subvol snapshot -r /home /home/snapshot_amanda_$1

btrfs subvol delete /var/lib/libvirt/images/snapshot_amanda_$1
btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/snapshot_amanda_$1

# Trigger amanda
ssh root@10.10.32.4 "./dump.sh $1"

# Delete snapshot
zfs destroy vault/encrypted@amanda_$1
zfs destroy vault/backup@amanda_$1
btrfs subvol delete /snapshot_amanda_$1
btrfs subvol delete /home/snapshot_amanda_$1
btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/snapshot_amanda_$1
