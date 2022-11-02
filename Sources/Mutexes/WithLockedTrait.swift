//
//  WithLockedTrait.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public protocol WithLockedTrait: BasicMutex {}

extension WithLockedTrait {
    @inline(__always) @inlinable @discardableResult
    public func withLocked<T>(_ exec: () -> T) -> T {
        lock()
        defer { unlock() }
        return exec()
    }

    @inline(__always) @inlinable @discardableResult
    public func withLocked<T>(_ exec: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try exec()
    }
}
