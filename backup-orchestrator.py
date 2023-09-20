#!/usr/bin/env python3
#pip install fasteners

# Author: Marcel Noe (https://github.com/NeoLeMarc)
# License: GPL v3
import fasteners, time
import smtplib
import ssl
import subprocess as subprocess
import traceback
import sys

SMTP_SERVER = 'mx.services.ka.xcore.net'
SMTP_PORT = 25
SENDER_EMAIL = 'root@polarstern.lan.ka.xcore.net'
RECEIVER_EMAIL = 'root@xcore.net'
LOGFILE = '/var/log/backuporchestrator.log'


class BackupMailer(object):
    def send(self, subject, message):
#        server.ehlo()
#        server.starttls(context = self.context)
#        server.ehlo()
        email_message = "Subject: %s\nFrom: %s\nTo: %s\n\n%s" % (subject, self.sender, self.receiver, message)
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
                server.sendmail(SENDER_EMAIL, RECEIVER_EMAIL, email_message)

    def __init__(self):
        self.server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        self.context = ssl.create_default_context()
        self.sender = SENDER_EMAIL
        self.receiver = RECEIVER_EMAIL

class ExecutionError(Exception):
    pass

class LockingException(Exception):
    pass

class BackupLockstate(object):
    def __init__(self):
        pass

class BackupLockManager(object):
    def lock(self):
        self.havelock = self._lock.acquire(blocking=False)
        if self.havelock:
            print("got lock")
        else:
            print("Sleeping 10 seconds")
            time.sleep(10)
            self.havelock = self._lock.acquire(blocking=False)
            if self.havelock:
                print("got lock")
            else:
                print("Failed to get lock, giving up")
                raise LockingException()


    def __init__(self):
        print("Aqcuiring lock...")
        self._lock = fasteners.InterProcessLock(".masterlock.lck")


class BackupTask(object):

    def __init__(self, name, command):
        self.command = command
        self.name = name

    def run(self):
        print("Running %s" % self.name)
        result = subprocess.run(self.command, shell=True, capture_output=True)
        result.taskName = self.name

        if result.returncode != 0:
            result.successful = False 
            print("failed")
            print(result.stderr)
        else:
            result.successful = True 
            print("completed")
        return result


class BackupSequence(object):
    
    def __init__(self, tasks):
        self.lockManager = BackupLockManager()
        self.mailer = BackupMailer()
        self.tasks = tasks
        self.summary = ""

    def run(self):
        self.lockManager.lock()
        for task in self.tasks:
            result = task.run()
            with open(LOGFILE, 'a') as logfile:
                summary = ""
                if result.successful:
                    summary += "\n****** [%s] - OK\n" % (result.taskName)
                    summary += result.stderr.decode("utf-8")
                    summary += result.stdout.decode("utf-8")
                    summary += "\n-------------------------------------\n"
                else: 
                    summary += "\n****** [%s] - ERROR\n" % (result.taskName)
                    summary += result.stderr.decode("utf-8")
                    summary += result.stdout.decode("utf-8")
                    summary += "\n-------------------------------------\n"
                    
                    self.sendErrorMail(result)
                logfile.write(summary)
                self.summary += summary
        self.sendSummary()
                
    def sendErrorMail(self, result):
        self.mailer.send("[BACKUP ERROR] Backup task (%s) failed" % result.taskName, result.stderr.decode("utf-8"))

    def sendSummary(self):
        self.mailer.send("[SUMMARY OF BACKUP] Backup completed", self.summary)

if __name__ == "__main__":
    print("Starting")
    try:
        tasks = []
        tasks.append(BackupTask("RSYNC VMs", "./rsync_vm_filesystems.sh"))
        tasks.append(BackupTask("GDRIVE vaultwarden", "./vaultwarden_gdrive.sh"))
        tasks.append(BackupTask("BTRFS local", "./backup-btrfs-local.sh"))
        tasks.append(BackupTask("Vault remote", "./backup-vault-remote.sh"))
        tasks.append(BackupTask("BTRFS remote", "./backup-btrfs-remote.sh"))
        sequence = BackupSequence(tasks)
        sequence.run()
        print("Done")
    except LockingException:
        mailer = BackupMailer()
        mailer.send("[BACKUP LOCK ERROR] Backup failed to acquire lock", traceback.format_exc())
        print("Failed to acquire lock")
        sys.exit(1)
