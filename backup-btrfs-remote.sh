export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts
## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)
mount /mnt/rz-backup/polarstern-backup

## backup /boot
$REMOTE_RESTIC backup /boot/ && \

## Backup /
btrfs subvol delete /remote-snapshot 2>/dev/null
btrfs subvol snapshot -r / /remote-snapshot && \
$REMOTE_RESTIC backup /remote-snapshot/ --exclude="/root/.cache" && \
btrfs subvol delete /remote-snapshot 

## Backup /home
btrfs subvol delete /home/remote-snapshot 2>/dev/null
btrfs subvol snapshot -r /home /home/remote-snapshot && \
$REMOTE_RESTIC backup /home/remote-snapshot/ --exclude="/home/snapshot/marcel/.steam"  --exclude="/home/snapshot/marcel/.bitcoin" --exclude="/home/snapshot/marcel/.cache" && \
btrfs subvol delete /home/remote-snapshot 

## Backup /var/lib/libvirt/images
btrfs subvol delete /var/lib/libvirt/images/remote-snapshot 2>/dev/null
btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/remote-snapshot && \
$REMOTE_RESTIC backup /var/lib/libvirt/images/remote-snapshot/ && \
btrfs subvol delete /var/lib/libvirt/images/remote-snapshot 

## Backup /var/lib/libvirt/images/sata-images
#btrfs subvol delete /var/lib/libvirt/images/sata-images/remote-snapshot 2>/dev/null
#btrfs subvol remote-snapshot -r /var/lib/libvirt/images/sata-images /var/lib/libvirt/images/sata-images/snapshot && \
#$REMOTE_RESTIC backup /var/lib/libvirt/images/sata-images/remote-snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/sata-images/remote-snapshot 

## Backup /var/log
btrfs subvol delete /var/log/remote-snapshot 2>/dev/null
btrfs subvol snapshot -r /var/log /var/log/remote-snapshot && \
$REMOTE_RESTIC backup /var/log/remote-snapshot/ && \
btrfs subvol delete /var/log/remote-snapshot 

## Cleanup
$REMOTE_RESTIC forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 5 
case $(LC_ALL=C date +%a) in
   (Thu)$REMOTE_RESTIC prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$REMOTE_RESTIC check
date

umount /mnt/rz-backup/polarstern-backup
