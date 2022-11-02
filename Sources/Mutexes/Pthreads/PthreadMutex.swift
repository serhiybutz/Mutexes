//
//  PthreadMutex.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Darwin

/// A Swift wrapper for the Pthreads mutex.
open class PthreadMutex: InitConfigurable {
    // MARK: - Types

    /// A mutex type.
    public enum MutexType {
        /// The `normal` mutex.
        ///
        /// This type of mutex does not check for usage errors.
        /// It will deadlock if reentered, and result in undefined behavior if a
        /// locked mutex is unlocked by another thread.
        /// Attempts to unlock an already unlocked `normal`
        /// mutex will result in undefined behavior.
        case normal
        /// The `errorcheck` mutex.
        ///
        /// These mutexes do check for usage errors.
        /// If an attempt is made to relock an `errorcheck`
        /// mutex without first dropping the lock, an error will be returned.
        /// If a thread attempts to unlock an `errorcheck`
        /// mutex that is locked by another thread, an error will be returned.
        /// If a thread attempts to unlock  an `errorcheck`
        /// thread that is unlocked, an error will be returned.
        case errorcheck
        /// The `recursive` mutex.
        ///
        /// These mutexes allow recursive locking.
        /// An attempt to relock a `recursive` mutex
        /// that is already locked by the same thread succeeds.
        /// An equivalent number of `unlock`
        /// calls are needed before the mutex will wake another thread waiting
        /// on this lock.
        /// If a thread attempts to unlock a `recursive`
        /// mutex that is locked by another thread, an error will be returned.
        ///
        /// It is advised that `recursive`
        /// mutexes are not used with condition variables.
        /// This is because of the implicit unlocking done by
        /// `pthread_cond_wait` and `pthread_cond_timedwait`.
        case recursive
        /// The ``default`` mutex (used by default).
        ///
        /// Currently the `default` mutex is equivalent to the `normal` mutex (but it's an implementation detail).
        case `default`
    }

    public enum MutexProtocol {
        /// The `none` protocol (`PTHREAD_PRIO_NONE`).
        ///
        /// When a thread owns a mutex with the `none` protocol attribute, its priority and scheduling shall not be affected by its mutex ownership.
        ///
        /// # See Also:
        /// [pthread_mutexattr_setprotocol](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_setprotocol.html)
        case none
        /// The `inherit` protocol (`PTHREAD_PRIO_INHERIT`).
        ///
        /// When a thread is blocking higher priority threads because of owning one or more mutexes with the `inherit` protocol attribute, it shall execute at the higher of its priority or the priority of the highest priority thread waiting on any of the mutexes owned by this thread and initialized with this protocol.
        ///
        /// # See Also:
        /// [pthread_mutexattr_setprotocol](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_setprotocol.html)
        case inherit
        /// The `protect` protocol (`PTHREAD_PRIO_PROTECT`).
        ///
        /// When a thread owns one or more mutexes initialized with the `protect` protocol, it shall execute at the higher of its priority or the highest of the priority ceilings of all the mutexes owned by this thread and initialized with this attribute, regardless of whether other threads are blocked on any of these mutexes or not.
        ///
        /// # See Also:
        /// [pthread_mutexattr_setprotocol](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_setprotocol.html)
        case protect
    }

    public struct Configuration {
        /// Type of the mutex. Currently defaults to `normal` (but it's an implementation detail).
        ///
        /// # See Also:
        ///     man 3 pthread_mutexattr_settype
        /// [pthread_mutexattr_settype](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_settype.html)
        /// [pthread_mutex_lock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_lock.html)
        public var type: MutexType?
        /// Flag specifying if the mutex respects fairness (or lock ordering). Defaults to `false`.
        ///
        /// If the mutex is non-fair an unlocker can potentially immediately reacquire the lock before a woken up waiter gets an opportunity to attempt to acquire the lock. This may be advantageous for performance reasons, but also makes starvation of waiters a possibility.
        ///
        /// # See Also:
        ///     man 3 pthread_mutexattr_setpolicy_np
        public var isFair: Bool?
        /// Flag specifying if the mutex should operate across processes. Defaults to `true`.
        ///
        /// # See Also:
        ///     man 3 pthread_mutexattr_setpshared
        /// [pthread_mutexattr_setpshared](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_setpshared.html)
        public var isProcessShared: Bool?
        /// Defines the protocol to be followed in utilizing mutexes. Defaults to `none`.
        ///
        /// # See Also:
        /// [pthread_mutexattr_setprotocol](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_setprotocol.html)
        public var `protocol`: MutexProtocol?

        /// Defines the priority ceiling of initialized mutexes. The values of prioceiling are within the maximum range of priorities [-999; 999]. Defaults to `0`.
        ///
        /// The prioceiling attribute defines the priority ceiling of initialized mutexes, which is the minimum priority level at which the critical section guarded by the mutex is executed. In order to avoid priority inversion, the priority ceiling of the mutex shall be set to a priority higher than or equal to the highest priority of all the threads that may lock that mutex. The values of prioceiling are within the maximum range of priorities defined under the SCHED_FIFO scheduling policy.
        ///
        /// # See Also:
        /// [pthread_mutexattr_setprioceiling](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutexattr_setprioceiling.html)
        public var priorityCeiling: Int32?
    }

    // MARK: - State

    @usableFromInline
    let lockPtr: UnsafeMutablePointer<pthread_mutex_t>

    // MARK: - Initialization

    required public init(configure: (inout Configuration) -> Void) {
        lockPtr = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)
        var attr = pthread_mutexattr_t()
        guard pthread_mutexattr_init(&attr) == 0 else { preconditionFailure() }
        var configuration = Configuration()
        configure(&configuration)
        if let type = configuration.type {
            switch type {
            case .normal:
                pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)
            case .errorcheck:
                pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ERRORCHECK)
            case .recursive:
                pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
            case .default:
                pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT)
            }
        }
        if let isFair = configuration.isFair {
            pthread_mutexattr_setpolicy_np(&attr, isFair ? PTHREAD_MUTEX_POLICY_FAIRSHARE_NP : PTHREAD_MUTEX_POLICY_FIRSTFIT_NP)
        }
        if let isProcessShared = configuration.isProcessShared {
            pthread_mutexattr_setpshared(&attr, isProcessShared ? PTHREAD_PROCESS_SHARED : PTHREAD_PROCESS_PRIVATE)
        }
        if let `protocol` = configuration.`protocol` {
            switch `protocol` {
            case .none:
                pthread_mutexattr_setprotocol(&attr, PTHREAD_PRIO_NONE)
            case .inherit:
                pthread_mutexattr_setprotocol(&attr, PTHREAD_PRIO_INHERIT)
            case .protect:
                pthread_mutexattr_setprotocol(&attr, PTHREAD_PRIO_PROTECT)
            }
        }
        if let priorityCeiling = configuration.priorityCeiling {
            pthread_mutexattr_setprioceiling(&attr, priorityCeiling)
        }
        guard pthread_mutex_init(lockPtr, &attr) == 0 else { preconditionFailure() }
        pthread_mutexattr_destroy(&attr)
    }

    required public convenience init() {
        self.init { _ in }
    }

    deinit {
        pthread_mutex_destroy(lockPtr)
        lockPtr.deinitialize(count: 1)
        lockPtr.deallocate()
    }

    // MARK: - UI

    /// Locks a mutex.
    ///
    /// Locks a mutex. If the mutex is already locked, the calling thread will
    /// block until the mutex becomes available.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_mutex_lock
    /// [pthread_mutex_lock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_lock.html)
    @inline(__always) @inlinable
    open func lockT() throws {
        let errno = pthread_mutex_lock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Unlocks a mutex.
    ///
    /// Unlocks a mutex. If the current thread holds the lock on mutex, then the `unlock()` function unlocks mutex.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// Calling `unlock()` with a mutex that the calling thread does not hold will result in undefined behavior.
    ///
    /// # See Also:
    ///     man 3 pthread_mutex_unlock
    /// [pthread_mutex_unlock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_lock.html)
    @inline(__always) @inlinable
    open func unlockT() throws {
        let errno = pthread_mutex_unlock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }

    /// Attempts to lock a mutex without blocking.
    ///
    /// Attempts to lock a mutex without blocking. If the mutex is already locked,
    /// `trylock()` will not block waiting for the mutex, but will unsucceed.
    ///
    /// If unsuccessful, a `PthreadMutexError` will be thrown with `errno` indicating the error.
    ///
    /// # See Also:
    ///     man 3 pthread_mutex_trylock
    /// [pthread_mutex_trylock](https://pubs.opengroup.org/onlinepubs/9699919799/functions/pthread_mutex_trylock.html)
    @inline(__always) @inlinable
    open func tryLockT() throws {
        let errno = pthread_mutex_trylock(lockPtr)
        if errno != 0 { throw PthreadMutexError(errno) }
    }
}

extension PthreadMutex: WithLockedTrait {}

extension PthreadCondition {
    @inline(__always) @inlinable
    func lockPtr(_ mutex: PthreadMutex) -> UnsafeMutablePointer<pthread_mutex_t> { mutex.lockPtr }
}
