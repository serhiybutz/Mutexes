//
//  PthreadRWLock.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Darwin

/// A Swift wrapper for the Pthreads read-write lock.
open class PthreadRWLock: InitConfigurable {
    // MARK: - Types

    public struct Configuration {
        /// Flag specifying if the mutex should operate across processes. Defaults to `true`.
        ///
        /// # See Also:
        ///     man 3 pthread_rwlockattr_setpshared
        /// [pthread_rwlockattr_setpshared](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlockattr_setpshared.html)
        public var isProcessShared: Bool?
    }

    // MARK: - State

    @usableFromInline
    let lockPtr: UnsafeMutablePointer<pthread_rwlock_t>

    // MARK: - Initialization

    required public init(configure: (inout Configuration) -> Void) {
        lockPtr = UnsafeMutablePointer<pthread_rwlock_t>.allocate(capacity: 1)
        var attr = pthread_rwlockattr_t()
        guard pthread_rwlockattr_init(&attr) == 0 else { preconditionFailure() }
        var configuration = Configuration()
        configure(&configuration)
        if let isProcessShared = configuration.isProcessShared {
            pthread_rwlockattr_setpshared(&attr, isProcessShared ? PTHREAD_PROCESS_SHARED : PTHREAD_PROCESS_PRIVATE)
        }
        guard pthread_rwlock_init(lockPtr, &attr) == 0 else { preconditionFailure() }
        pthread_rwlockattr_destroy(&attr)
    }

    required public convenience init() {
        self.init { _ in }
    }

    deinit {
        pthread_rwlock_destroy(lockPtr)
        lockPtr.deinitialize(count: 1)
        lockPtr.deallocate()
    }

    // MARK: - UI

    /// Acquires a read/write lock for writing.
    ///
    /// Blocks until a write lock can be acquired against lock.
    ///
    /// The results are undefined if the calling thread already holds the lock at the time the call is made.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_wrlock
    /// [pthread_rwlock_wrlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_wrlock.html)
    @inline(__always) @inlinable
    open func writeLockT() throws {
        let errno = pthread_rwlock_wrlock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

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
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_rdlock
    /// [pthread_rwlock_rdlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_rdlock.html)
    @inline(__always) @inlinable
    open func readLockT() throws {
        let errno = pthread_rwlock_rdlock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Releases a read/write lock.
    ///
    /// Releases the read/write lock previously obtained by `readLock()`, `writeLock()`, `tryReadLock()`, `tryWriteLock()`.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_unlock
    /// [pthread_rwlock_unlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_unlock.html)
    @inline(__always) @inlinable
    open func unlockT() throws {
        let errno = pthread_rwlock_unlock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Acquires a read/write lock for writing. Performs the same action as `writeLock()`,
    /// but does not block if the lock cannot be immediately obtained.
    ///
    /// The results are undefined if the calling thread already holds the lock at the time the call is made.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_trywrlock
    /// [pthread_rwlock_trywrlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_trywrlock.html)
    @inline(__always) @inlinable
    open func tryWriteLockT() throws {
        let errno = pthread_rwlock_trywrlock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Acquires a read/write lock for reading. Performs the same action as `readLock()`,
    /// but does not block if the lock cannot be immediately obtained
    /// (i.e., the lock is held for writing or there are waiting writers).
    ///
    /// A thread may hold multiple concurrent read locks.  If so, `unlock()` must be
    /// called once for each lock obtained.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// - Note: To prevent writer starvation, writers are favored over readers.
    ///
    /// # See Also:
    ///     man 3 pthread_rwlock_tryrdlock
    /// [pthread_rwlock_tryrdlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_rwlock_tryrdlock.html)
    @inline(__always) @inlinable
    open func tryReadLockT() throws {
        let errno = pthread_rwlock_tryrdlock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }
}

extension PthreadRWLock: WithReadWriteLockedTrait {}
