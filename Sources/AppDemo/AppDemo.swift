//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation
import SwiftTUI
import SwiftTUICore

struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello world")
            Text("This is a SwiftTUI demo")
        }
    }
}

@main
struct AppDemo {
    static func main() {
        let app = App {
            MyView()
        }
        app.run()
    }
}
