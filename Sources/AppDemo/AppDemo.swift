//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        MyView()
    }
}

struct MyView: View {
    @State private var count: Int = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")

            Button("Increment") {
                count += 1
            }

            Button("Decrement") {
                count -= 1
            }
        }
    }
}
