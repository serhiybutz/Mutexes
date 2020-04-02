//
//  ReadWriteLockBasicTests.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
import XConcurrencyKit
@testable import Mutexes

final class ReadWriteLockBasicTests: XCTestCase {
    let queue = DispatchQueue(label: "ReadWriteLockBasicTests.ConcurrentQueue", attributes: .concurrent)

    // MARK: - Tests

    func test_PthreadRWLock() {
        _test_writeLockBlocksReadLock(PthreadRWLock.self)
        _test_readLockDoesNotBlockAnotherReadLock(PthreadRWLock.self)
    }

    // MARK: - Helpers

    func _test_writeLockBlocksReadLock<T: BasicReadWriteLock>(_ mutexType: T.Type, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let startSema = DispatchSemaphore(value: 0)
        let sema = DispatchSemaphore(value: 0)
        let sut = mutexType.init()

        // When

        queue.async {
            startSema.signal()
            sut.writeLock()
            defer { sut.unlock() }
            Thread.sleep(forTimeInterval: timeStep)
        }

        startSema.wait()

        queue.async {
            sut.readLock()
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

    func _test_readLockDoesNotBlockAnotherReadLock<T: BasicReadWriteLock>(_ mutexType: T.Type, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let startSema = DispatchSemaphore(value: 0)
        let sema = DispatchSemaphore(value: 0)
        let sut = mutexType.init()

        // When

        queue.async {
            startSema.signal()
            sut.readLock()
            defer { sut.unlock() }
            Thread.sleep(forTimeInterval: timeStep)
        }

        startSema.wait()

        queue.async {
            sut.readLock()
            defer { sut.unlock() }
            sema.signal()
        }

        // Then

        var timeMeter = CFExecutionTimeMeter()
        timeMeter.measure {
            XCTAssertEqual(sema.wait(timeout: .now() + timeStep + 0.1), .success, line: line)
        }

        XCTAssertLessThanOrEqual(timeMeter.executionTime, 0.1, line: line)
    }
}
