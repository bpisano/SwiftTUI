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
    @State private var field: Field? = nil
    @Focus private var focus

    var body: some View {
        VStack {
            Text("Focus demo")

            Text("Counter: \(count)")

            HStack {
                Button("-") {
                    count -= 1
                }
                Button("+") {
                    count += 1
                }
            }

            Text(field.map { "Field: \($0)" } ?? "No field selected")

            HStack {
                Button("Username") {
                    field = .username
                }
                .focused($field, equals: .username)

                Button("Password") {
                    field = .password
                }
                .focused($field, equals: .password)
            }
            .focusGroup()

            HStack {
                Button("Clear focus") {
                    focus(.clear)
                }
                Button("Reset count") {
                    count = 0
                }
            }
        }
    }
}

extension MyView {
    enum Field: Hashable {
        case username
        case password
    }
}
