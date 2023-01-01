#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

# Copy data of VM filesystems that should also be backed up separately

### Backup dockerserver
rsync -prav root@dockerserver.services.ka.xcore.net:/opt/ /vault/encrypted/crypto_backup/vms/dockerserver/opt/

## Backup archive
rsync -prav root@archive.services.ka.xcore.net:/ /vault/encrypted/crypto_backup/vms/archive/ --exclude /proc --exclude /sys
