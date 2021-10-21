# backup-orchestrator
Small collection of scripts I use to automate the backup of my server. It uses [Restic](https://restic.net/) to to the actual backup.
It can backup ZFS and BTRFS and relies on snapshots to do so. It is intended to be run as cronjob and delivers it's output via mail. If all backup tasks are successful it only send a summary with all the tasks output. But if one task fails, it sends an individual mail per failed task additional to the summary.
