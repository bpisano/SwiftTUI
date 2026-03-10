//
//  MakeViewOutputsInputStorageKey.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

struct MakeViewOutputsInputStorageKey: ViewInputsStorageKey {
    typealias Value = OutputsType
}

extension MakeViewOutputsInputStorageKey {
    enum OutputsType {
        typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs
        typealias MakeViewListOutputs = (ViewListInputs) -> ViewListOutputs

        case view(MakeViewOutputs)
        case viewList(MakeViewListOutputs)
    }
}
