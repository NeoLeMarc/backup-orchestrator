#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts

## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)

## backup /boot
$REMOTE_RESTIC_STORAGEBOX backup /boot/ && \

## Backup /
set +e
btrfs subvol delete /remote-storagebox-snapshot 2>/dev/null
set -e
btrfs subvol snapshot -r / /remote-storagebox-snapshot && \
$REMOTE_RESTIC_STORAGEBOX backup /remote-storagebox-snapshot/ --exclude="/root/.cache" && \
btrfs subvol delete /remote-storagebox-snapshot 

### Backup /home
#set +e
#btrfs subvol delete /home/remote-storagebox-snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /home /home/remote-storagebox-snapshot && \
#$REMOTE_RESTIC_STORAGEBOX backup /home/remote-storagebox-snapshot/ --exclude="/home/snapshot/marcel/.steam"  --exclude="/home/snapshot/marcel/.bitcoin" --exclude="/home/snapshot/marcel/.cache" && \
#btrfs subvol delete /home/remote-storagebox-snapshot 
#
### Backup /var/lib/libvirt/images
#set +e
#btrfs subvol delete /var/lib/libvirt/images/remote-storagebox-snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/remote-storagebox-snapshot && \
#$REMOTE_RESTIC_STORAGEBOX backup /var/lib/libvirt/images/remote-storagebox-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/remote-storagebox-snapshot 
#
### Backup /var/lib/libvirt/images/nosnapshot
#set +e
#btrfs subvol delete /var/lib/libvirt/images/nosnapshot/remote-storagebox-snapshot 2>/dev/null
#set -e
#btrfs subvol snapshot -r /var/lib/libvirt/images/nosnapshot /var/lib/libvirt/images/nosnapshot/remote-storagebox-snapshot && \
#$REMOTE_RESTIC_STORAGEBOX backup /var/lib/libvirt/images/nosnapshot/remote-storagebox-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/nosnapshot/remote-storagebox-snapshot

## Backup /home
set +e
zfs destroy fastflash/home@remote_storagebox_snapshot
set -e
zfs snapshot fastflash/home@remote_storagebox_snapshot

$REMOTE_RESTIC_STORAGEBOX backup /home/.zfs/snapshot/remote_storagebox_snapshot/ --exclude="/home/.zfs/snapshot/remote_storagebox_snapshot/marcel/.steam"  --exclude="/home/.zfs/remote_storagebox_snapshot/marcel/.bitcoin" --exclude="/home/.zfs/snapshot/remote_storagebox_snapshot/marcel/.cache" 


## Backup /var/lib/libvirt/images
set +e
zfs destroy fastflash/vms@remote_storagebox_snapshot
set -e
zfs snapshot fastflash/vms@remote_storagebox_snapshot
$REMOTE_RESTIC_STORAGEBOX backup /var/lib/libvirt/images/.zfs/snapshot/remote_storagebox_snapshot/ 



## Backup /var/lib/libvirt/images/sata-images
#btrfs subvol delete /var/lib/libvirt/images/sata-images/remote-storagebox-snapshot 2>/dev/null
#btrfs subvol remote-storagebox-snapshot -r /var/lib/libvirt/images/sata-images /var/lib/libvirt/images/sata-images/snapshot && \
#$REMOTE_RESTIC_STORAGEBOX backup /var/lib/libvirt/images/sata-images/remote-storagebox-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/sata-images/remote-storagebox-snapshot 

## Backup /var/log
set +e
btrfs subvol delete /var/log/remote-storagebox-snapshot 2>/dev/null
set -e
btrfs subvol snapshot -r /var/log /var/log/remote-storagebox-snapshot && \
$REMOTE_RESTIC_STORAGEBOX backup /var/log/remote-storagebox-snapshot/ && \
btrfs subvol delete /var/log/remote-storagebox-snapshot 

## Cleanup
$REMOTE_RESTIC_STORAGEBOX forget --keep-daily 7 --keep-weekly 5 --keep-monthly 2 
case $(LC_ALL=C date +%a) in
   (Thu)$REMOTE_RESTIC_STORAGEBOX prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$REMOTE_RESTIC_STORAGEBOX check
date
