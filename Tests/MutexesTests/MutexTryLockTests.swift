//
//  MutexTryLockTests.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
@testable import Mutexes

final class MutexTryLockTests: XCTestCase {
    let queue = DispatchQueue(label: "MutexTryLockTests.ConcurrentQueue", attributes: .concurrent)

    // MARK: - Tests

    func test_NSLock() {
        _test(NSLock.self)
    }

    func test_NSRecursiveLock() {
        _test(NSRecursiveLock.self, isRecursive: true)
    }

    func test_PthreadNormalMutex() {
        _test(PthreadNormalMutex.self)
    }

    func test_PthreadRecursiveMutex() {
        _test(PthreadRecursiveMutex.self, isRecursive: true)
    }

    func test_OSUnfairLock() {
        _test(OSUnfairLock.self)
    }

    // MARK: - Helpers

    func _test<T: Mutex>(_ mutexType: T.Type, isRecursive: Bool = false, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let sut = mutexType.init()

        // When

        queue.async {
            sut.lock()
            if isRecursive { sut.lock() }
            defer {
                sut.unlock()
                if isRecursive { sut.unlock() }
            }
            Thread.sleep(forTimeInterval: timeStep)
        }

        // Then

        Thread.sleep(forTimeInterval: timeStep / 2)

        XCTAssertFalse(sut.tryLock(), line: line)

        Thread.sleep(forTimeInterval: timeStep / 2 + 0.1)

        XCTAssertTrue(sut.tryLock(), line: line)
    }
}
