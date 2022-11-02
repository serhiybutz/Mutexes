//
//  NSLock+.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

extension NSLock: Mutex {
    @inline(__always)
    @inlinable
    open func tryLock() -> Bool { `try`() }
}

extension NSLock: WithLockedTrait {}

extension NSRecursiveLock: Mutex {
    @inline(__always)
    @inlinable
    open func tryLock() -> Bool { `try`() }
}

extension NSRecursiveLock: WithLockedTrait {}
