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
    @State private var keyPressCount: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Text("Keyboard counter")
                .foregroundStyle(.primary)
            Text("Pressed keys: \(keyPressCount)")
                .foregroundStyle(.secondary)
            Text("Press any key")
                .foregroundStyle(.tertiary)
        }
        .onKeyPressed { _ in
            keyPressCount += 1
        }
    }
}
