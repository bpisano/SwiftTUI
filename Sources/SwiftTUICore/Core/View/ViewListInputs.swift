//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

public struct ViewListInputs: InputStorage {
    var storage: ViewInputsStorage

    init(viewInputs: ViewInputs) {
        self.storage = viewInputs.storage
    }
}
