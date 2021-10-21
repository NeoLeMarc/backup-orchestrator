#!/bin/bash
set -x
export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts
## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)
mount /mnt/rz-backup/polarstern-backup

## Create snapshot
zfs destroy vault/encrypted@backup_snapshot
zfs snapshot vault/encrypted@backup_snapshot

## Backups that are synced to cloud
$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/jennifer_marcel && \
$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/jennifer && \
$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/*.sh && \
$REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/archive && \

## Backups that are not synced to cloud
$NOCLOUD_REMOTE_RESTIC_VAULT backup /vault/encrypted/.zfs/snapshot/backup_snapshot/Incoming && \


## Cleanup
$REMOTE_RESTIC_VAULT forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 5 
case $(LC_ALL=C date +%a) in
   (Thu)$REMOTE_RESTIC_VAULT prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$REMOTE_RESTIC_VAULT check
date

umount /mnt/rz-backup/polarstern-backup
