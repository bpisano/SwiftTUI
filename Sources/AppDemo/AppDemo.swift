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
struct AppDemo {
    static func main() {
        let app = App {
            MyView()
        }
        app.run()
    }
}

struct MyView: View {
    @State private var count: Int = 0

    var body: some View {
        Text("\(count)")
            .onEvent(of: .keyboard) { event in
                count += 1
            }
    }
}
