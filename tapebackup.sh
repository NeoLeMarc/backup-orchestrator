#!/bin/bash

echo "Configuration: $1"

# Rotate snapshots
zfs destroy vault/encrypted@amanda_$1
zfs snapshot vault/encrypted@amanda_$1

# Trigger amanda
ssh root@10.10.32.4 "./dump.sh $1"

# Delete snapshot
zfs destroy vault/encrypted@amanda_$1
