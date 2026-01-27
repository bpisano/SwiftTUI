//
//  ViewOutputs.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation

public struct ViewOutputs {
    public let layoutComputer: Attribute<LayoutComputer>
    public let displayList: Attribute<DisplayList>
}

extension ViewOutputs: CustomStringConvertible {
    public var description: String {
        "ViewOutputs"
    }
}
