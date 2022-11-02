//
//  BiSemaphore.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Dispatch

// A binary dispatch semaphore.
open class BiSemaphore: BasicMutex {
    // MARK: - State

    @usableFromInline
    let semaphore = DispatchSemaphore(value: 1)

    // MARK: - Initialization

    required public init() {}

    // MARK: - UI

    @inline(__always) @inlinable
    open func lock() { semaphore.wait() }

    @inline(__always) @inlinable
    open func unlock() { semaphore.signal() }
}

extension BiSemaphore: WithLockedTrait {}
