//
//  ConditionTests.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import XCTest
import XConcurrencyKit
@testable import Mutexes

final class ConditionTests: XCTestCase {
    let queue = DispatchQueue(label: "ConditionTests.ConcurrentQueue", attributes: .concurrent)

    // MARK: - Tests

    func test_PthreadCondition_withSignal() {
        _test_PthreadCondition(shouldBroadcast: false)
    }

    func test_PthreadCondition_withBroadcast() {
        _test_PthreadCondition(shouldBroadcast: true)
    }

    // MARK: - Helpers

    func _test_PthreadCondition(shouldBroadcast: Bool, line: UInt = #line) {
        // Given

        let timeStep: TimeInterval = 0.5
        let sema = DispatchSemaphore(value: 0)
        let mutex = PthreadMutex()
        let sut = PthreadCondition()
        var conditionPredicate: Bool = false

        // When

        queue.async {
            mutex.lock()
            while !conditionPredicate {
                sut.wait(with: mutex)
            }
            mutex.unlock()
            sema.signal()
        }

        queue.async {
            Thread.sleep(forTimeInterval: timeStep)
            mutex.lock()
            conditionPredicate = true
            if shouldBroadcast {
                sut.broadcast()
            } else {
                sut.signal()
            }
            mutex.unlock()
        }

        // Then

        var timeMeter = CFExecutionTimeMeter()
        timeMeter.measure {
            XCTAssertEqual(sema.wait(timeout: .now() + timeStep + 0.1), .success, line: line)
        }

        XCTAssertGreaterThanOrEqual(timeMeter.executionTime, timeStep - 0.1, line: line)
    }

    func test_PthreadConditionWaitUntil() {
        // Given

        let sema = DispatchSemaphore(value: 0)
        let mutex = PthreadMutex()
        let sut = PthreadCondition()
        let conditionPredicate: Bool = false
        let waitLimit: TimeInterval = 1.0

        // When

        queue.async {
            mutex.lock()
            while !conditionPredicate {
                if !sut.wait(until: Date() + waitLimit, with: mutex) {
                    break
                }
            }
            mutex.unlock()
            sema.signal()
        }

        // Then

        var timeMeter = CFExecutionTimeMeter()
        timeMeter.measure {
            sema.wait()
        }

        XCTAssertGreaterThanOrEqual(timeMeter.executionTime, waitLimit - 0.1)
    }
}
