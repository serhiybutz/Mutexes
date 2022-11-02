//
//  MutexBasicTests.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
import XConcurrencyKit
@testable import Mutexes

final class MutexBasicTests: XCTestCase {
    let queue = DispatchQueue(label: "MutexBasicTests.ConcurrentQueue", attributes: .concurrent)

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

    func test_BiSemaphore() {
        _test(BiSemaphore.self)
    }

    // MARK: - Helpers

    func _test<T: BasicMutex>(_ mutexType: T.Type, isRecursive: Bool = false, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let startSema = DispatchSemaphore(value: 0)
        let sema = DispatchSemaphore(value: 0)
        let sut = mutexType.init()

        // When

        queue.async {
            startSema.signal()

            sut.lock()
            if isRecursive { sut.lock() }
            defer {
                sut.unlock()
                if isRecursive { sut.unlock() }
            }
            Thread.sleep(forTimeInterval: timeStep)
        }

        startSema.wait()

        queue.async {
            sut.lock()
            defer { sut.unlock() }
            sema.signal()
        }

        // Then

        var timeMeter = CFExecutionTimeMeter()
        timeMeter.measure {
            XCTAssertEqual(sema.wait(timeout: .now() + timeStep + 0.1), .success, line: line)
        }

        XCTAssertGreaterThanOrEqual(timeMeter.executionTime, timeStep - 0.1, line: line)
    }
}
