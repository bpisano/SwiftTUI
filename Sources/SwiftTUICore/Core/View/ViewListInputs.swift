//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

public struct ViewListInputs: InputStorage {
    var storage: ViewInputsStorage
    var implicitId: Int

    init(viewInputs: ViewInputs, implicitId: Int = 0) {
        self.storage = viewInputs.storage
        self.implicitId = implicitId
    }

    @MainActor
    init(implicitId: Int = 0) {
        self.storage = .init()
        self.implicitId = implicitId
    }
}
