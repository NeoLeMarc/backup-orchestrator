# Delete snapshot
zfs destroy sataflash/encrypted@bareos_$1
#zfs destroy vault/backup@bareos_$1
btrfs subvol delete /snapshot_bareos_$1
#btrfs subvol delete /home/snapshot_bareos_$1
zfs destroy fastflash/home@bareos_$1
#btrfs subvol delete /var/lib/libvirt/images/snapshot_bareos_$1
zfs destroy fastflash/vms@bareos_$1

