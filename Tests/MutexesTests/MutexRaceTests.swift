//
//  MutexRaceTests.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
import XConcurrencyKit
@testable import Mutexes

final class MutexRaceTests: XCTestCase {
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
        let sut = mutexType.init()

        // Given

        let threadCollider = ThreadCollider()
        let raceDetector = RaceSensitiveSection()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            sut.lock()
            if isRecursive {
                sut.lock()
            }

            raceDetector.exclusiveCriticalSection({
                // simulate some work
                let sleepVal = arc4random() & 7
                usleep(sleepVal)
            })

            sut.unlock()
            if isRecursive {
                sut.unlock()
            }

            // Race corral END
        })

        // Then

        XCTAssertTrue(raceDetector.noProblemDetected, line: line)
    }
}
