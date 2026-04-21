//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation

public protocol EnvironmentKey {
    associatedtype Value

    static var defaultValue: Value { get }
}
