//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation
import SwiftTUI
import SwiftTUICore
import Terminal

@main
struct MyApp: App {
    var body: some View {
        MyView()
    }
}

struct MyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Alice")
            EmptyView()
            Text("Bob")
        }
//        .onEvent(of: .keyboard) { event in
//            count += 1
//        }
    }
}
