#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

# Copy data of VM filesystems that should also be backed up separately
#
### Backup wormhole01 
rsync -prav root@wormhole01.xcore.net:/ /vault/encrypted/crypto_backup/vms/wormhole01/ --exclude /proc --exclude /sys

### Backup ns2 
rsync -prav root@ns2.noetech.net:/ /vault/encrypted/crypto_backup/vms/ns2/ --exclude /proc --exclude /sys

### Backup dockerserver
rsync -prav root@dockerserver.services.ka.xcore.net:/opt/ /vault/encrypted/crypto_backup/vms/dockerserver/opt/

## Backup archive
rsync -prav root@archive.services.ka.xcore.net:/ /vault/encrypted/crypto_backup/vms/archive/ --exclude /proc --exclude /sys
