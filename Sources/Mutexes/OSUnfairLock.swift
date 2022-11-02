//
//  OSUnfairLock.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Dispatch

/// A Swift wrapper for OSUnfairLock.
open class OSUnfairLock: Mutex {
    // MARK: - State

    @usableFromInline
    let lockPtr: UnsafeMutablePointer<os_unfair_lock>

    // MARK: - Initialization

    required public init() {
        let mutex = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        mutex.initialize(to: os_unfair_lock())
        self.lockPtr = mutex
    }

    deinit {
        lockPtr.deinitialize(count: 1)
        lockPtr.deallocate()
    }

    // MARK: - UI

    @inline(__always) @inlinable
    open func lock() { os_unfair_lock_lock(lockPtr) }
    @inline(__always) @inlinable
    open func unlock() { os_unfair_lock_unlock(lockPtr) }
    @inline(__always) @inlinable
    open func tryLock() -> Bool { os_unfair_lock_trylock(lockPtr) }
}

extension OSUnfairLock: WithLockedTrait {}
