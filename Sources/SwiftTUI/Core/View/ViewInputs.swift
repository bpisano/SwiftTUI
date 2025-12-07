//
//  ViewInputs.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

struct ViewInputs {
    let frame: Attribute<Rect>

    init(frame: Attribute<Rect>) {
        self.frame = frame
    }
}
