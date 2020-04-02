//
//  WithReadWriteLockedTrait.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public protocol WithReadWriteLockedTrait: BasicReadWriteLock {}

extension WithReadWriteLockedTrait {
    @inline(__always) @inlinable @discardableResult
    public func withReadLocked<T>(_ exec: () -> T) -> T {
        readLock()
        defer { unlock() }
        return exec()
    }

    @inline(__always) @inlinable @discardableResult
    public func withReadLocked<T>(_ exec: () throws -> T) rethrows -> T {
        readLock()
        defer { unlock() }
        return try exec()
    }

    @inline(__always) @inlinable @discardableResult
    public func withWriteLocked<T>(_ exec: () -> T) -> T {
        writeLock()
        defer { unlock() }
        return exec()
    }

    @inline(__always) @inlinable @discardableResult
    public func withWriteLocked<T>(_ exec: () throws -> T) rethrows -> T {
        writeLock()
        defer { unlock() }
        return try exec()
    }
}
