#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3
#set -e
#set -x
export PATH=/opt/emulex/ocmanager/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:PATH

# Copy data of VM filesystems that should also be backed up separately
#
### Backup wormhole01 
rsync -prav root@wormhole01.xcore.net:/ /vault/encrypted/crypto_backup/vms/wormhole01/ --exclude /proc --exclude /sys --delete

### Backup ns2 
rsync -prav root@ns2.noetech.net:/ /vault/encrypted/crypto_backup/vms/ns2/ --exclude /proc --exclude /sys --delete

### Backup dockerserver
rsync -prav root@dockerserver.services.ka.xcore.net:/opt/ /vault/encrypted/crypto_backup/vms/dockerserver/opt/ --delete

## Backup archive
rsync -prav root@archive.services.ka.xcore.net:/ /vault/encrypted/crypto_backup/vms/archive/ --exclude /proc --exclude /sys --delete
