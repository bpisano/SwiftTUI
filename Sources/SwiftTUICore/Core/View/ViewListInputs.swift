//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

public struct ViewListInputs: InputStorage {
    var implicitId: Int
    var environment: Attribute<EnvironmentValues>
    var storage: ViewInputsStorage

    init(viewInputs: ViewInputs, implicitId: Int = 0) {
        self.implicitId = implicitId
        self.environment = viewInputs.environment
        self.storage = viewInputs.storage
    }

    @MainActor
    init(implicitId: Int = 0) {
        self.implicitId = implicitId
        self.environment = .init(wrappedValue: EnvironmentValues())
        self.storage = .init()
    }
}
