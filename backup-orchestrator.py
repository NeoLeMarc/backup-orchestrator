#!/usr/bin/env python3
#pip install fasteners

import fasteners, time
import smtplib
import ssl

SMTP_SERVER = 'mx.services.ka.xcore.net'
SMTP_PORT = 25
SENDER_EMAIL = 'root@polarstern.lan.ka.xcore.net'
RECEIVER_EMAIL = 'root@xcore.net'

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

class LockingException(Exception):
    pass

class BackupLockstate(object):
    def __init__(self):
        pass

class BackupOrchestrator(object):
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
        self._lock = fasteners.InterProcessLock("lockfile")



if __name__ == "__main__":
    print("Starting")
    bo = BackupOrchestrator()
    bo.lock()
    mailer = BackupMailer()
    mailer.send('[TEST]', 'this is a test e-mail')
    time.sleep(20)
    print("Done")
