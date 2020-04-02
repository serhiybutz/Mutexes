//
//  ReadWriteLockRaceTests.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
import XConcurrencyKit
@testable import Mutexes

final class ReadWriteLockRaceTests: XCTestCase {
    // MARK: - Tests

    func test_PthreadRWLock() {
        _test(PthreadRWLock.self)
    }

    // MARK: - Helpers

    func _test<T: BasicReadWriteLock>(_ mutexType: T.Type, line: UInt = #line) {
        let sut = mutexType.init()

        // Given

        let threadCollider = ThreadCollider()
        let raceDetector = RaceSensitiveSection()

        // When

        threadCollider.collide(victim: {
            if Bool.random() {
                sut.writeLock()

                raceDetector.exclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 15
                    usleep(sleepVal)
                })
            } else {
                sut.readLock()

                raceDetector.nonExclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 31
                    usleep(sleepVal)
                })
            }
            sut.unlock()
        })

        // Then

        XCTAssertTrue(raceDetector.noProblemDetected, "\(raceDetector.exclusiveRaces) races out of \(raceDetector.exclusivePasses) passes", line: line)
        XCTAssertTrue(raceDetector.nonExclusiveBenignRaces > 0, line: line)
        print("Read races: \(raceDetector.nonExclusiveRaces) out of \(raceDetector.nonExclusivePasses)")
    }
}
