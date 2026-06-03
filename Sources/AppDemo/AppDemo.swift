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
        ContentView()
    }
}

//struct ContentView: View {
//    var body: some View {
//        VStack(spacing: 1) {
//            Text("Colors")
//
//            HStack(alignment: .top, spacing: 4) {
//                VStack(alignment: .leading, spacing: 1) {
//                    Swatch(name: "Red", color: .red)
//                    Swatch(name: "Green", color: .green)
//                    Swatch(name: "Blue", color: .blue)
//                    Swatch(name: "Yellow", color: .yellow)
//                    Swatch(name: "Cyan", color: .cyan)
//                    Swatch(name: "Magenta", color: .magenta)
//                }
//
//                VStack(alignment: .leading, spacing: 1) {
//                    Swatch(name: "Soft Red", color: .softRed)
//                    Swatch(name: "Soft Green", color: .softGreen)
//                    Swatch(name: "Soft Blue", color: .softBlue)
//                    Swatch(name: "Soft Yellow", color: .softYellow)
//                    Swatch(name: "Soft Cyan", color: .softCyan)
//                    Swatch(name: "Soft Magenta", color: .softMagenta)
//                }
//
//                VStack(alignment: .leading, spacing: 1) {
//                    Text("Primary").foregroundStyle(.primary)
//                    Text("Secondary").foregroundStyle(.secondary)
//                    Text("Tertiary").foregroundStyle(.tertiary)
//                    Text("Quaternary").foregroundStyle(.quaternary)
//                    Text("Quinary").foregroundStyle(.quinary)
//                }
//            }
//        }
//    }
//}

//struct Swatch: View {
//    let name: String
//    let color: Color
//
//    var body: some View {
//        HStack(spacing: 1) {
//            color
//                .frame(width: 4, height: 1)
//            Text(name)
//                .foregroundStyle(color)
//        }
//    }
//}

struct ContentView: View {
    enum Screen {
        case form
        case welcome
    }

    @State private var screen: Screen = .form
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var city: String = ""

    @State private var submittedName: String = ""
    @State private var submittedEmail: String = ""
    @State private var submittedCity: String = ""

    @Focus private var focus

    var body: some View {
        if screen == .form {
            FormView(
                name: $name,
                email: $email,
                city: $city,
                onSubmit: submit
            )
        } else {
            WelcomeView(
                name: submittedName,
                email: submittedEmail,
                city: submittedCity,
                onBack: back
            )
        }
    }

    private func submit() {
        submittedName = name
        submittedEmail = email
        submittedCity = city
        screen = .welcome
        focus(.clear)
    }

    private func back() {
        name = ""
        email = ""
        city = ""
        screen = .form
        focus(.clear)
    }
}

struct FormView: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var city: String
    let onSubmit: @MainActor @Sendable () -> Void

    @Focus private var focus

    var body: some View {
        VStack {
            Text("Sign up")
            VStack {
                TextField("Name", text: $name)
                    .frame(width: 40)
                TextField("Email", text: $email)
                    .frame(width: 40)
                TextField("City", text: $city)
                    .frame(width: 40)
            }
            .focusGroup()
            Button("Submit", action: onSubmit)
            Button("Test") {
                focus(.clear)
            }
        }
        .onSubmit(onSubmit)
    }
}

struct WelcomeView: View {
    let name: String
    let email: String
    let city: String
    let onBack: @MainActor @Sendable () -> Void

    var body: some View {
        VStack {
            Text("Welcome \(name)!")
            Text("Email: \(email)")
            Text("City: \(city)")
            Button("OK", action: onBack)
        }
    }
}
