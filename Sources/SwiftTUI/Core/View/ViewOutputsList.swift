//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import Foundation
import AttributeGraph

struct ViewOutputsList {
    let layoutComputers: [Attribute<LayoutComputer>]
    let displayList: Attribute<DisplayList>
}

extension ViewOutputsList: CustomStringConvertible {
    var description: String {
        "ViewOutputsList"
    }
}
