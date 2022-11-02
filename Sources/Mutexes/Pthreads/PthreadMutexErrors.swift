//
//  PthreadMutexError.swift
//  Mutexes
//
//  Created by Serhiy Butz on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public typealias Errno = Int32

public struct PthreadMutexError: Swift.Error {
    public let errno: Errno
    public init(_ errno: Errno) {
        self.errno = errno
    }
}

public struct PthreadMutexInvalidThreshold: Swift.Error {
    public init() {}
}
