#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts

## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)

## Create snapshot
set +e
zfs destroy sataflash/encrypted@storagebox_backup_snapshot
set -e
zfs snapshot sataflash/encrypted@storagebox_backup_snapshot

## Backups that are synced to cloud
#$REMOTE_RESTIC_VAULT_STORAGEBOX backup /vault/encrypted/.zfs/snapshot/storagebox_backup_snapshot/jennifer_marcel && \
#$REMOTE_RESTIC_VAULT_STORAGEBOX backup /vault/encrypted/.zfs/snapshot/storagebox_backup_snapshot/jennifer && \
$REMOTE_RESTIC_VAULT_STORAGEBOX backup /vault/encrypted/.zfs/snapshot/storagebox_backup_snapshot/*.sh && \


## Backups that are not synced to cloud
#$NOCLOUD_REMOTE_RESTIC_VAULT_STORAGEBOX backup /vault/encrypted/.zfs/snapshot/storagebox_backup_snapshot/

## Cleanup
$REMOTE_RESTIC_VAULT_STORAGEBOX forget --keep-daily 7 --keep-weekly 5 --keep-monthly 2 
case $(LC_ALL=C date +%a) in
   (Thu)$REMOTE_RESTIC_VAULT_STORAGEBOX prune ;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$REMOTE_RESTIC_VAULT_STORAGEBOX check

date

