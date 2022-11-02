//
//  ReadWriteLockTryTests.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
@testable import Mutexes

final class ReadWriteLockTryTests: XCTestCase {
    let queue = DispatchQueue(label: "ReadWriteLockTryTests.ConcurrentQueue", attributes: .concurrent)

    // MARK: - Tests

    func test_PthreadRWLock() {
        _test_writeLockBlocksReadLock(PthreadRWLock.self)
        _test_readLockDoesNotBlockAnotherReadLock(PthreadRWLock.self)
    }

    // MARK: - Helpers

    func _test_writeLockBlocksReadLock<T: ReadWriteLock>(_ mutexType: T.Type, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let sut = mutexType.init()

        // When

        queue.async {
            sut.writeLock()
            defer { sut.unlock() }
            Thread.sleep(forTimeInterval: timeStep)
        }

        // Then

        Thread.sleep(forTimeInterval: timeStep / 2)

        XCTAssertFalse(sut.tryReadLock(), line: line)

        Thread.sleep(forTimeInterval: timeStep / 2 + 0.1)

        XCTAssertTrue(sut.tryReadLock(), line: line)
    }

    func _test_readLockDoesNotBlockAnotherReadLock<T: ReadWriteLock>(_ mutexType: T.Type, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let sut = mutexType.init()

        // When

        queue.async {
            sut.readLock()
            defer { sut.unlock() }
            Thread.sleep(forTimeInterval: timeStep)
        }

        // Then

        Thread.sleep(forTimeInterval: timeStep / 2)
        XCTAssertTrue(sut.tryReadLock(), line: line)
    }
}
