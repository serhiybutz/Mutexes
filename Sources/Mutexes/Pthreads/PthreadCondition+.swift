//
//  PthreadCondition+.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

extension PthreadCondition {
    // MARK: - UI

    /// Blocks on a condition variable.
    ///
    /// The application must ensure that this function is called with mutex locked by the calling thread; otherwise, an error or undefined behavior results.
    /// This function atomically releases mutex and causes the calling thread to block on the condition variable cond; atomically here means "atomically with respect to access by another thread to the mutex and then the condition variable". That is, if another thread is able to acquire the mutex after the about-to-block thread has released it, then a subsequent call to `broadcast()` or `signal()` in that thread shall behave as if it were issued after the about-to-block thread has blocked.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_wait
    /// [pthread_cond_wait](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_timedwait.html)
    @inline(__always) @inlinable
    open func wait(with mutex: PthreadMutex) {
        pthread_cond_wait(condPtr, lockPtr(mutex))
    }

    /// Blocks on a condition variable.
    ///
    /// The `wait(until:with:)` function is equivalent to `wait(with:)`, except that it fails if the absolute time specified by `threshold` passes (that is, system time equals or exceeds `threshold`) before the condition variable is signaled or broadcasted, or if the absolute time specified by `threshold` has already been passed at the time of the call. When such timeouts occur, `wait(until:with:)` will nonetheless release and re-acquire the mutex referenced by mutex, and may consume a condition signal directed concurrently at the condition variable.
    ///
    /// The application must ensure that this function is called with mutex locked by the calling thread; otherwise, an error or undefined behavior results.
    /// This function atomically releases mutex and causes the calling thread to block on the condition variable cond; atomically here means "atomically with respect to access by another thread to the mutex and then the condition variable". That is, if another thread is able to acquire the mutex after the about-to-block thread has released it, then a subsequent call to `broadcast()` or `signal()` in that thread shall behave as if it were issued after the about-to-block thread has blocked.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_timedwait
    /// [pthread_cond_timedwait](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_timedwait.html)
    @inline(__always) @inlinable
    open func wait(until threshold: Date, with mutex: PthreadMutex) -> Bool {
        guard var timeout = timespecFrom(date: threshold) else {
            return false
        }
        return pthread_cond_timedwait(condPtr, lockPtr(mutex), &timeout) == 0
    }

    /// Unblocks at least one of the threads that are blocked on this condition variable (if any threads are blocked on it).
    ///
    /// # See Also:
    ///     man 3 pthread_cond_signal
    /// [pthread_cond_signal](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_signal.html)
    @inline(__always) @inlinable
    open func signal() {
        pthread_cond_signal(condPtr)
    }

    /// Unblocks all threads currently blocked on this condition variable.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_broadcast
    /// [pthread_cond_broadcast](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_broadcast.html)
    @inline(__always) @inlinable
    open func broadcast() { pthread_cond_broadcast(condPtr) }
}
