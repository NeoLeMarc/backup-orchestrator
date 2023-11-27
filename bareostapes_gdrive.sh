#!/bin/bash
# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3

# Dump encryption keys of bareos tapes, encrypt them with gpg and upload to google drive for DR purposeses
su - -s /bin/bash bareos -c 'echo "select mediaid, volumename, encryptionkey from media;" | psql'  | gpg --armor -e -r 7C72016B451B2016 > /vault/encrypted/crypto_backup/bareos_tapes.asc
gdrive upload -p 1OBtO9i6qDJ4Qxe-tp5Tfiml1RIwRvY0T /vault/encrypted/crypto_backup/bareos_tapes.asc
