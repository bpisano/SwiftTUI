//
//  ViewOutputs.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation

struct ViewOutputs {
    let layoutComputer: Attribute<LayoutComputer>
    let displayList: Attribute<DisplayList>
}

extension ViewOutputs: CustomStringConvertible {
    var description: String {
        "ViewOutputs"
    }
}
