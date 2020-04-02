//
//  PthreadCondition.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// A Swift wrapper for the Pthreads condition variable.
open class PthreadCondition: InitConfigurable {
    // MARK: - Types

    public struct Configuration {
        /// Flag specifying if the mutex should operate across processes. Defaults to `true`.
        ///
        /// # See Also:
        ///     man 3 pthread_condattr_setpshared
        /// [pthread_condattr_setpshared](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_condattr_setpshared.html)
        public var isProcessShared: Bool?
    }

    // MARK: - State

    @usableFromInline
    let condPtr: UnsafeMutablePointer<pthread_cond_t>

    // MARK: - Initialization

    required public init(configure: (inout Configuration) -> Void) {
        condPtr = UnsafeMutablePointer<pthread_cond_t>.allocate(capacity: 1)
        var attr = pthread_condattr_t()
        guard pthread_condattr_init(&attr) == 0 else { preconditionFailure() }
        var configuration = Configuration()
        configure(&configuration)
        if let isProcessShared = configuration.isProcessShared {
            pthread_condattr_setpshared(&attr, isProcessShared ? PTHREAD_PROCESS_SHARED : PTHREAD_PROCESS_PRIVATE)
        }
        guard pthread_cond_init(condPtr, &attr) == 0 else { preconditionFailure() }
        pthread_condattr_destroy(&attr)
    }

    public convenience init() {
        self.init { _ in }
    }

    deinit {
        pthread_cond_destroy(condPtr)
        condPtr.deinitialize(count: 1)
        condPtr.deallocate()
    }

    // MARK: - UI

    /// Blocks on a condition variable.
    ///
    /// The application must ensure that this function is called with mutex locked by the calling thread; otherwise, an error or undefined behavior results.
    /// This function atomically releases mutex and causes the calling thread to block on the condition variable cond; atomically here means "atomically with respect to access by another thread to the mutex and then the condition variable". That is, if another thread is able to acquire the mutex after the about-to-block thread has released it, then a subsequent call to `broadcast()` or `signal()` in that thread shall behave as if it were issued after the about-to-block thread has blocked.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_wait
    /// [pthread_cond_wait](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_timedwait.html)
    @inline(__always) @inlinable
    open func waitT(with mutex: PthreadMutex) throws {
        let errno = pthread_cond_wait(condPtr, lockPtr(mutex))
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Blocks on a condition variable.
    ///
    /// The `wait(until:with:)` function is equivalent to `wait(with:)`, except that it fails if the absolute time specified by `threshold` passes (that is, system time equals or exceeds `threshold`) before the condition variable is signaled or broadcasted, or if the absolute time specified by `threshold` has already been passed at the time of the call. When such timeouts occur, `wait(until:with:)` will nonetheless release and re-acquire the mutex referenced by mutex, and may consume a condition signal directed concurrently at the condition variable.
    ///
    /// The application must ensure that this function is called with mutex locked by the calling thread; otherwise, an error or undefined behavior results.
    /// This function atomically releases mutex and causes the calling thread to block on the condition variable cond; atomically here means "atomically with respect to access by another thread to the mutex and then the condition variable". That is, if another thread is able to acquire the mutex after the about-to-block thread has released it, then a subsequent call to `broadcast()` or `signal()` in that thread shall behave as if it were issued after the about-to-block thread has blocked.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_timedwait
    /// [pthread_cond_timedwait](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_timedwait.html)
    @inline(__always) @inlinable
    open func waitT(until threshold: Date, with mutex: PthreadMutex) throws {
        guard var timeout = timespecFrom(date: threshold) else {
            throw PthreadMutexInvalidThreshold()
        }
        let errno = pthread_cond_timedwait(condPtr, lockPtr(mutex), &timeout)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Unblocks at least one of the threads that are blocked on this condition variable (if any threads are blocked on it).
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_signal
    /// [pthread_cond_signal](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_signal.html)
    @inline(__always) @inlinable
    open func signalT() throws {
        let errno = pthread_cond_signal(condPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Unblocks all threads currently blocked on this condition variable.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_cond_broadcast
    /// [pthread_cond_broadcast](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_cond_broadcast.html)
    @inline(__always) @inlinable
    open func broadcastT() throws {
        let errno = pthread_cond_broadcast(condPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    // MARK: - Helpers

    @inline(__always) @inlinable
    func timespecFrom(date: Date) -> timespec? {
        guard date.timeIntervalSinceNow > 0 else { return nil }
        let nsecPerSec: Int64 = 1_000_000_000
        let interval = date.timeIntervalSince1970
        let intervalNsecs = Int64(interval * Double(nsecPerSec))
        return timespec(tv_sec: time_t(intervalNsecs / nsecPerSec),
                        tv_nsec: Int(intervalNsecs % nsecPerSec))
    }
}
