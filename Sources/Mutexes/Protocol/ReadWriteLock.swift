//
//  ReadWriteLock.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// This protocol defines a universal interface for read-write locks.
public protocol BasicReadWriteLock {
    func readLock()
    func writeLock()
    func unlock()
    init()
}

public protocol ReadWriteLock: BasicReadWriteLock {
    func tryReadLock() -> Bool
    func tryWriteLock() -> Bool
}
