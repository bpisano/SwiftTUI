//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

protocol EnvironmentProperty {
    func update(environment: Attribute<EnvironmentValues>)
}
