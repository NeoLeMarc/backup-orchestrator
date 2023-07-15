#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts
## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)
zfs mount -la


## backup /boot
$ZFS_RESTIC backup /boot/ && \

## Backup /
set +e
btrfs subvol delete /snapshot 2>/dev/null
set -e
btrfs subvol snapshot -r / /snapshot && \
$ZFS_RESTIC backup /snapshot/ --exclude="/root/.cache" && \
btrfs subvol delete /snapshot 

## Backup /home
#set +e
#btrfs subvol delete /home/snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /home /home/snapshot && \
#$ZFS_RESTIC backup /home/snapshot/ --exclude="/home/snapshot/marcel/.steam"  --exclude="/home/snapshot/marcel/.bitcoin" --exclude="/home/snapshot/marcel/.cache" && \
#btrfs subvol delete /home/snapshot 

## Backup /home
set +e
zfs destroy fastflash/home@backup_snapshot
set -e
zfs snapshot fastflash/home@backup_snapshot

$ZFS_RESTIC backup /home/.zfs/snapshot/backup_snapshot/ --exclude="/home/.zfs/snapshot/backup_snapshot/marcel/.steam"  --exclude="/home/.zfs/snapshot/backup_snapshot/marcel/.bitcoin" --exclude="/home/.zfs/snapshot/backup_snapshot/marcel/.cache" 


## Backup /var/lib/libvirt/images
set +e
zfs destroy fastflash/vms@backup_snapshot
set -e
zfs snapshot fastflash/vms@backup_snapshot
$ZFS_RESTIC backup /var/lib/libvirt/images/.zfs/snapshot/backup_snapshot/ 

### Backup /var/lib/libvirt/images/nosnapshot
#set +e
#btrfs subvol delete /var/lib/libvirt/images/nosnapshot/snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /var/lib/libvirt/images/nosnapshot /var/lib/libvirt/images/nosnapshot/snapshot && \
#$ZFS_RESTIC backup /var/lib/libvirt/images/nosnapshot/snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/nosnapshot/snapshot 


## Backup /var/lib/libvirt/images/sata-images
#btrfs subvol delete /var/lib/libvirt/images/sata-images/snapshot 2>/dev/null
#btrfs subvol snapshot -r /var/lib/libvirt/images/sata-images /var/lib/libvirt/images/sata-images/snapshot && \
#$ZFS_RESTIC backup /var/lib/libvirt/images/sata-images/snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/sata-images/snapshot 

## Backup /var/log
set +e
btrfs subvol delete /var/log/snapshot 2>/dev/null
set -e
btrfs subvol snapshot -r /var/log /var/log/snapshot && \
$ZFS_RESTIC backup /var/log/snapshot/ && \
btrfs subvol delete /var/log/snapshot 

## Cleanup
$ZFS_RESTIC forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 5 
case $(LC_ALL=C date +%a) in
   (Thu)$ZFS_RESTIC prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$ZFS_RESTIC check
date
