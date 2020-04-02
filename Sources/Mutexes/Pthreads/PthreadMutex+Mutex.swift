//
//  PthreadMutex+Mutex.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Darwin

extension PthreadMutex: Mutex {
    // MARK: - Mutex UI

    /// Locks a mutex.
    ///
    /// Locks a mutex. If the mutex is already locked, the calling thread will
    /// block until the mutex becomes available.
    ///
    /// # See Also:
    ///     man 3 pthread_mutex_lock
    /// [pthread_mutex_lock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_lock.html)
    @inline(__always) @inlinable
    open func lock() { pthread_mutex_lock(lockPtr) }

    /// Unlocks a mutex.
    ///
    /// Unlocks a mutex. If the current thread holds the lock on mutex, then the `unlock()` function unlocks mutex.
    /// Calling `unlock()` with a mutex that the calling thread does not hold will result in undefined behavior.
    ///
    /// # See Also:
    ///     man 3 pthread_mutex_unlock
    /// [pthread_mutex_unlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_lock.html)
    @inline(__always) @inlinable
    open func unlock() { pthread_mutex_unlock(lockPtr) }

    /// Attempts to lock a mutex without blocking.
    ///
    /// Attempts to lock a mutex without blocking. If the mutex is already locked,
    /// `trylock()` will not block waiting for the mutex, but will unsucceed.
    ///
    /// # See Also:
    ///     man 3 pthread_mutex_trylock
    /// [pthread_mutex_trylock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_trylock.html)
    @inline(__always) @inlinable
    open func tryLock() -> Bool { pthread_mutex_trylock(lockPtr) == 0 }
}
