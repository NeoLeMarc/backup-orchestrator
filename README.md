# backup-orchestrator
Small collection of scripts I use to automate the backup of my server. It uses [Restic](https://restic.net/) to do the actual backup.
It can backup ZFS and BTRFS and relies on snapshots to do so. It is intended to be run as cronjob and delivers it's output via mail. If all backup tasks are successful it only send a summary with all the tasks output. But if one task fails, it sends an individual mail per failed task additional to the summary.

# Dependencies
- Unix based operating system (tested on Linux)
- Restic
- Python3
- Python3 fasteners (pip install fasteners)
- ZFS or BTFS based filesystem (or you need to write your own backup scripts)

# Usage
- First write your own backup shellscript per task. Three scripts are included (backup-bault-remote.sh, backup-btrfs-local.sh, backup-btrfs-remote.sh). The first one uses ZFS, the other two use BTFS. They can easily be adapted to use LVM based snapshots
- Edit backup-orchestrator.py
  - Change e-mail setting in top
  - Edit the task lists in the main section at the bottom. It runs all three scripts by default. Add your own scripts here and remove the rest
- Run python3 backup-orchestrator.py either on shell or ideally over cron. Most output is send via e-mail, it only prints minimal output on the command line
