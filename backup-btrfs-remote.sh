#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts

## Wakeup rz-backup
wakeonlan -i 10.10.1.222 00:11:32:c2:0a:4f
sleep 400

## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)
mount /mnt/rz-backup/polarstern-backup

## backup /boot
$REMOTE_RESTIC backup /boot/ && \

## Backup /
set +e
btrfs subvol delete /remote-snapshot 2>/dev/null
set -e
btrfs subvol snapshot -r / /remote-snapshot && \
$REMOTE_RESTIC backup /remote-snapshot/ --exclude="/root/.cache" && \
btrfs subvol delete /remote-snapshot 

### Backup /home
#set +e
#btrfs subvol delete /home/remote-snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /home /home/remote-snapshot && \
#$REMOTE_RESTIC backup /home/remote-snapshot/ --exclude="/home/snapshot/marcel/.steam"  --exclude="/home/snapshot/marcel/.bitcoin" --exclude="/home/snapshot/marcel/.cache" && \
#btrfs subvol delete /home/remote-snapshot 
#
### Backup /var/lib/libvirt/images
#set +e
#btrfs subvol delete /var/lib/libvirt/images/remote-snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/remote-snapshot && \
#$REMOTE_RESTIC backup /var/lib/libvirt/images/remote-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/remote-snapshot 
#
### Backup /var/lib/libvirt/images/nosnapshot
#set +e
#btrfs subvol delete /var/lib/libvirt/images/nosnapshot/remote-snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /var/lib/libvirt/images/nosnapshot /var/lib/libvirt/images/nosnapshot/remote-snapshot && \
#$REMOTE_RESTIC backup /var/lib/libvirt/images/nosnapshot/remote-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/nosnapshot/remote-snapshot

## Backup /home
set +e
zfs destroy fastflash/home@remote_snapshot
set -e
zfs snapshot fastflash/home@remote_snapshot

$REMOTE_RESTIC backup /home/.zfs/snapshot/remote_snapshot/ --exclude="/home/.zfs/snapshot/remote_snapshot/marcel/.steam"  --exclude="/home/.zfs/remote_snapshot/marcel/.bitcoin" --exclude="/home/.zfs/snapshot/remote_snapshot/marcel/.cache" 


## Backup /var/lib/libvirt/images
set +e
zfs destroy fastflash/vms@remote_snapshot
set -e
zfs snapshot fastflash/vms@remote_snapshot
$REMOTE_RESTIC backup /var/lib/libvirt/images/.zfs/snapshot/remote_snapshot/ 



## Backup /var/lib/libvirt/images/sata-images
#btrfs subvol delete /var/lib/libvirt/images/sata-images/remote-snapshot 2>/dev/null
#btrfs subvol remote-snapshot -r /var/lib/libvirt/images/sata-images /var/lib/libvirt/images/sata-images/snapshot && \
#$REMOTE_RESTIC backup /var/lib/libvirt/images/sata-images/remote-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/sata-images/remote-snapshot 

## Backup /var/log
set +e
btrfs subvol delete /var/log/remote-snapshot 2>/dev/null
set -e
btrfs subvol snapshot -r /var/log /var/log/remote-snapshot && \
$REMOTE_RESTIC backup /var/log/remote-snapshot/ && \
btrfs subvol delete /var/log/remote-snapshot 

## Cleanup
$REMOTE_RESTIC forget --keep-daily 7 --keep-weekly 5 --keep-monthly 2 
case $(LC_ALL=C date +%a) in
   (Thu)$REMOTE_RESTIC prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$REMOTE_RESTIC check
date

umount /mnt/rz-backup/polarstern-backup
