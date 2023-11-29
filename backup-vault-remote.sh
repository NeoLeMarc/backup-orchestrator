#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts

## Wakeup rz-backup
wakeonlan 00:11:32:c2:0a:4f 
sleep 400

## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)
mount /mnt/rz-backup/polarstern-backup

## Create snapshot
set +e
zfs destroy sataflash/encrypted@backup_snapshot
set -e
zfs snapshot sataflash/encrypted@backup_snapshot

## Backups that are synced to cloud
#$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/jennifer_marcel && \
#$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/jennifer && \
$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/*.sh && \


## Backups that are not synced to cloud
$NOCLOUD_REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/

## Cleanup
$REMOTE_RESTIC_VAULT forget --keep-daily 7 --keep-weekly 5 --keep-monthly 2 
case $(LC_ALL=C date +%a) in
   (Thu)$REMOTE_RESTIC_VAULT prune && $NOCLOUD_REMOTE_RESTIC_VAULT prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$REMOTE_RESTIC_VAULT check
$NOCLOUD_REMOTE_RESTIC_VAULT check

date

umount /mnt/rz-backup/polarstern-backup
