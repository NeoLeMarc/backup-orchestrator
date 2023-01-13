#!/bin/bash

echo "Configuration: $1"

# Rotate snapshots
zfs destroy vault/encrypted@amanda_$1
zfs snapshot vault/encrypted@amanda_$1

#zfs destroy vault/backup@amanda_$1
#zfs snapshot vault/backup@amanda_$1

btrfs subvol delete /snapshot_amanda_$1
btrfs subvol snapshot -r / /snapshot_amanda_$1

btrfs subvol delete /home/snapshot_amanda_$1
btrfs subvol snapshot -r /home /home/snapshot_amanda_$1

btrfs subvol delete /var/lib/libvirt/images/snapshot_amanda_$1
btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/snapshot_amanda_$1

echo "Created all snapshots"

# Show next tapes to use
#ssh backup@miranda "/usr/sbin/amadmin $1 tape"
su backup -c "/usr/sbin/amadmin $1 tape"
echo "Please stage tapes and press Enter"
read

# Trigger amanda
#ssh backup@miranda "/usr/sbin/amcheck $1"
su backup -c "/usr/sbin/amcheck $1"

echo "Check done, proceeding with dump"
#echo "Press Enter"
#read
#ssh backup@miranda "/usr/sbin/amdump $1"
su backup -c "/usr/sbin/amdump $1"

# Delete snapshot
zfs destroy vault/encrypted@amanda_$1
#zfs destroy vault/backup@amanda_$1
btrfs subvol delete /snapshot_amanda_$1
btrfs subvol delete /home/snapshot_amanda_$1
btrfs subvol delete /var/lib/libvirt/images/snapshot_amanda_$1
