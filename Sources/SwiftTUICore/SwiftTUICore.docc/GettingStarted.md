# Getting Started

Build and run your first SwiftTUI app.

## Create an executable target

A SwiftTUI app is a command-line executable. Create a Swift package with an
executable target if you don't have one:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    targets: [
        .executableTarget(name: "MyApp")
    ]
)
```

## Add the dependency

Add SwiftTUI to the package and to the executable target:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/bpisano/SwiftTUI.git", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "MyApp",
            dependencies: [
                .product(name: "SwiftTUI", package: "SwiftTUI")
            ]
        )
    ]
)
```

`import SwiftTUI` brings in everything you need — views, layout, state, and the
`App` entry point.

## Create your first app

The program's entry point is a type conforming to `App`, marked `@main`. Its
`body` returns the root view.

```swift
import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        Text("Hello, terminal")
    }
}
```

Views nest. Use stacks to arrange children and ``State`` to hold values that
change:

```swift
import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        Greeting()
    }
}

struct Greeting: View {
    @State private var name = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("What is your name?")
            TextField("Enter your name", text: $name)
            Text("Hello, \(name)")
        }
    }
}
```

## Run the app

Run the executable from the package directory:

```sh
swift run
```

SwiftTUI takes over the terminal, draws the view tree, and processes keyboard
input. The screen updates whenever the ``State`` your views depend on changes.

## Exit the app

The app runs until you press `Ctrl-C`. SwiftTUI handles the interrupt, restores
the terminal to its previous state — leaving raw mode and clearing what it
drew — and exits. There is no quit API to call; `Ctrl-C` is the way out.

## Next steps

- <doc:LayingOutViews> for arranging views with stacks and ``View/frame(width:height:alignment:)``.
- <doc:Controls> for ``Button`` and ``TextField``.
- <doc:ManagingFocus> for moving keyboard focus between views.
- <doc:StylingViews> for color and ``View/foregroundStyle(_:)``.
- <doc:SwiftUICompatibility> for the list of APIs not yet implemented.
