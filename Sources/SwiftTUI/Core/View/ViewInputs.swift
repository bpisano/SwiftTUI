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
    let storage: Storage

    init(frame: Attribute<Rect>) {
        self.storage = .frame(frame)
    }

    init(geometry: Attribute<ViewGeometry>) {
        self.storage = .geometry(geometry)
    }

    var proposalFrame: Attribute<Rect> {
        switch storage {
        case .frame(let frame):
            return frame
        case .geometry(let geometry):
            let frame = Attribute {
                geometry.wrappedValue.dimensions.frame
            }
            frame.label = "ViewInputs.proposalFrame(from geometry)"
            return frame
        }
    }
}

extension ViewInputs {
    enum Storage {
        case frame(Attribute<Rect>)
        case geometry(Attribute<ViewGeometry>)
    }
}
