export GODEBUG=asyncpreemptoff=1 # Fix for bugs caused by preempted interrupts
## Prepare and mount
date
source restic.sh
diroffset=$(echo `date +"%d"`%2 | bc)
zfs mount -la


## backup /boot
$ZFS_RESTIC backup /boot/ && \

## Backup /
btrfs subvol delete /snapshot 2>/dev/null
btrfs subvol snapshot -r / /snapshot && \
$ZFS_RESTIC backup /snapshot/ --exclude="/root/.cache" && \
btrfs subvol delete /snapshot 

## Backup /home
btrfs subvol delete /home/snapshot 2>/dev/null
btrfs subvol snapshot -r /home /home/snapshot && \
$ZFS_RESTIC backup /home/snapshot/ --exclude="/home/snapshot/marcel/.steam"  --exclude="/home/snapshot/marcel/.bitcoin" --exclude="/home/snapshot/marcel/.cache" && \
btrfs subvol delete /home/snapshot 

## Backup /var/lib/libvirt/images
btrfs subvol delete /var/lib/libvirt/images/snapshot 2>/dev/null
btrfs subvol snapshot -r /var/lib/libvirt/images /var/lib/libvirt/images/snapshot && \
$ZFS_RESTIC backup /var/lib/libvirt/images/snapshot/ && \
btrfs subvol delete /var/lib/libvirt/images/snapshot 

## Backup /var/lib/libvirt/images/sata-images
#btrfs subvol delete /var/lib/libvirt/images/sata-images/snapshot 2>/dev/null
#btrfs subvol snapshot -r /var/lib/libvirt/images/sata-images /var/lib/libvirt/images/sata-images/snapshot && \
#$ZFS_RESTIC backup /var/lib/libvirt/images/sata-images/snapshot/ && \
#btrfs subvol delete /var/lib/libvirt/images/sata-images/snapshot 

## Backup /var/log
btrfs subvol delete /var/log/snapshot 2>/dev/null
btrfs subvol snapshot -r /var/log /var/log/snapshot && \
$ZFS_RESTIC backup /var/log/snapshot/ && \
btrfs subvol delete /var/log/snapshot 

## Cleanup
$ZFS_RESTIC forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --keep-yearly 5 
case $(LC_ALL=C date +%a) in
   (Thu)$ZFS_RESTIC prune;;
   (*) echo No prune today;; # last ;; not necessary but doesn't harm
esac
$ZFS_RESTIC check
date
