## Restic config
export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts
export REMOTE_RESTIC="restic -r /mnt/rz-backup/polarstern-backup/restic -p /etc/restic-password"
export ZFS_RESTIC="restic -r /vault/backup/restic -p /etc/restic-password"
export REMOTE_RESTIC_VAULT="restic -r /mnt/rz-backup/polarstern-backup/restic_vault -p /etc/restic-password"
export NOCLOUD_REMOTE_RESTIC_VAULT="restic -r /mnt/rz-backup/polarstern-backup/restic_vault_nocloud -p /etc/restic-password"
export SATARAID_RESTIC="restic -r /sataraid/backup/restic -p /etc/restic-password"
export HAVARIE_RESTIC="restic -r /mnt/havarie/backup/restic -p /etc/restic-password"
export LOCAL_HAVARIE_RESTIC="restic -r /mnt/localhavarie/restic -p /etc/restic-password"

