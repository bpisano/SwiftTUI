//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

public struct Alignment: Sendable {
    let horizontal: HorizontalAlignment
    let vertical: VerticalAlignment
}

public extension Alignment {
    static let topLeading: Alignment = .init(horizontal: .leading, vertical: .top)
    static let top: Alignment = .init(horizontal: .center, vertical: .top)
    static let topTrailing: Alignment = .init(horizontal: .trailing, vertical: .top)

    static let leading: Alignment = .init(horizontal: .leading, vertical: .center)
    static let center: Alignment = .init(horizontal: .center, vertical: .center)
    static let trailing: Alignment = .init(horizontal: .trailing, vertical: .center)

    static let bottomLeading: Alignment = .init(horizontal: .leading, vertical: .bottom)
    static let bottom: Alignment = .init(horizontal: .center, vertical: .bottom)
    static let bottomTrailing: Alignment = .init(horizontal: .trailing, vertical: .bottom)
}

extension Alignment: CustomStringConvertible {
    public var description: String {
        "Alignment(h: \(horizontal), v: \(vertical))"
    }
}
