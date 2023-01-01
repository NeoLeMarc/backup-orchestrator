#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

# Encrypt vaultwarden data with gpg and upload to google drive for DR purposeses
tar -cz /vault/encrypted/crypto_backup/vms/dockerserver/opt/vaultwarden/data | gpg --armor -e -r 7C72016B451B2016 > /vault/encrypted/crypto_backup/vaultwarden.tgz.asc
gdrive upload -p 1OBtO9i6qDJ4Qxe-tp5Tfiml1RIwRvY0T /vault/encrypted/crypto_backup/vaultwarden.tgz.asc
