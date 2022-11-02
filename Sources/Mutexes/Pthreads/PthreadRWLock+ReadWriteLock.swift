//
//  PthreadRWLock+ReadWriteLock.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Darwin

extension PthreadRWLock: ReadWriteLock {
    // MARK: - ReadWriteLock UI

    /// Acquires a read/write lock for writing.
    ///
    /// Blocks until a write lock can be acquired against lock.
    ///
    /// The results are undefined if the calling thread already holds the lock at the time the call is made.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_wrlock
    /// [pthread_rwlock_wrlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_wrlock.html)
    @inline(__always) @inlinable
    open func writeLock() { pthread_rwlock_wrlock(lockPtr) }

    /// Acquires a read/write lock for reading.
    ///
    /// Acquires a read lock on lock provided that lock is not presently held
    /// for writing and no writer threads are presently blocked on the lock.
    /// If the read lock cannot be immediately acquired, the calling thread
    /// blocks until it can acquire the lock.
    ///
    /// A thread may hold multiple concurrent read locks.  If so, `unlock()` must be
    /// called once for each lock obtained.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_rdlock
    /// [pthread_rwlock_rdlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_rdlock.html)
    @inline(__always) @inlinable
    open func readLock() { pthread_rwlock_rdlock(lockPtr) }

    /// Releases a read/write lock.
    ///
    /// Releases the read/write lock previously obtained by `readLock()`, `writeLock()`, `tryReadLock()`, `tryWriteLock()`.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_unlock
    /// [pthread_rwlock_unlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_unlock.html)
    @inline(__always) @inlinable
    open func unlock() { pthread_rwlock_unlock(lockPtr) }

    /// Acquires a read/write lock for writing. Performs the same action as `writeLock()`,
    /// but does not block if the lock cannot be immediately obtained.
    ///
    /// The results are undefined if the calling thread already holds the lock at the time the call is made.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_trywrlock
    /// [pthread_rwlock_trywrlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_trywrlock.html)
    @inline(__always) @inlinable
    open func tryWriteLock() -> Bool { pthread_rwlock_trywrlock(lockPtr) == 0 }

    /// Acquires a read/write lock for reading. Performs the same action as `readLock()`,
    /// but does not block if the lock cannot be immediately obtained
    /// (i.e., the lock is held for writing or there are waiting writers).
    ///
    /// A thread may hold multiple concurrent read locks.  If so, `unlock()` must be
    /// called once for each lock obtained.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_tryrdlock
    /// [pthread_rwlock_tryrdlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_tryrdlock.html)
    @inline(__always) @inlinable
    open func tryReadLock() -> Bool { pthread_rwlock_tryrdlock(lockPtr) == 0 }
}
