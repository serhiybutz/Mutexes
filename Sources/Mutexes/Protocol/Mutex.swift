//
//  Mutex.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// This protocol defines a universal interface for mutexes. It's analogous to `NSLocking`.
public protocol BasicMutex {
    func lock()
    func unlock()
    init()
}

public protocol Mutex: BasicMutex {
    func tryLock() -> Bool
}
