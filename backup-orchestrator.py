#!/usr/bin/env python3
#pip install fasteners

import fasteners, time
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
    time.sleep(20)
    print("Done")
