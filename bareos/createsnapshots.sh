#!/bin/bash

echo "Configuration: $1"

# Rotate snapshots
zfs destroy sataflash/encrypted@bareos_$1
zfs snapshot sataflash/encrypted@bareos_$1

#zfs destroy vault/backup@bareos_$1
#zfs snapshot vault/backup@bareos_$1

btrfs subvol delete /snapshot_bareos_$1
btrfs subvol snapshot -r / /snapshot_bareos_$1

#btrfs subvol delete /home/snapshot_bareos_$1
#btrfs subvol snapshot -r /home /home/snapshot_bareos_$1
zfs destroy fastflash/home@bareos_$1
zfs snapshot fastflash/home@bareos_$1

#btrfs subvol delete /var/lib/libvirt/images/snapshot_bareos_$1
#btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/snapshot_bareos_$1
zfs destroy fastflash/vms@bareos_$1
zfs snapshot fastflash/vms@bareos_$1


echo "Created all snapshots"
