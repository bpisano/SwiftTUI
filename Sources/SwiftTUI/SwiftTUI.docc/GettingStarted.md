# Getting Started

Build and run your first SwiftTUI app.

## Add the dependency

Add SwiftTUI to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/bpisano/SwiftTUI.git", from: "0.0.1")
]
```

Then add `SwiftTUI` to your executable target's dependencies.

## Define an app

An app is a type conforming to ``App``. Its `body` returns the root view.

```swift
import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        Text("Hello, terminal")
    }
}
```

Running the executable starts the runtime, draws the view tree to the terminal,
and processes keyboard input until the program exits.

## Compose views

Views nest. Use stacks to arrange children:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Name")
            TextField("Enter your name", text: $name)
        }
    }

    @State private var name = ""
}
```

## Next steps

- ``SwiftTUICore/State`` and ``SwiftTUICore/Binding`` for local state.
- ``SwiftTUICore/HStack``, ``SwiftTUICore/VStack``, and ``SwiftTUICore/ZStack`` for layout.
- <doc:SwiftUICompatibility> for the list of APIs not yet implemented.
