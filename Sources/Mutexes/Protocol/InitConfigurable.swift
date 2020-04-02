//
//  InitConfigurable.swift
//  Mutexes
//
//  Created by Serge Bouts on 4/2/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

/// An internal protocol that defines a convenient configuration process upon initialization.
///
/// An adopting type is supposed to define a nested configuration struct, e.g.:
/// ```
/// public struct Configuration {
///     var isRecursive: Bool = false
///     var isFair: Bool = true
///     ...
/// }
/// ```
/// and an initializer with the following logic:
/// ```
/// init(configure: (inout Configuration) -> Void) {
///     var configuration = Configuration()
///     configure(&configuration)
///     if configuration.isRecursive {
///         ...
///     }
/// }
/// ```
protocol InitConfigurable {
    associatedtype Configuration
    init(configure: (inout Configuration) -> Void)
}
