//
//  PthreadNormalMutex.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
@testable import Mutexes

final class PthreadNormalMutex: Mutex {
    // MARK: - State

    let mutex = PthreadMutex {
        $0.type = .normal // the default mutex
    }

    // MARK: - Initialization

    required init() {}

    // MARK: - UI

    @inline(__always) @inlinable
    func lock() { mutex.lock() }

    @inline(__always) @inlinable
    func unlock() { mutex.unlock() }

    @inline(__always) @inlinable
    func tryLock() -> Bool { mutex.tryLock() }
}
