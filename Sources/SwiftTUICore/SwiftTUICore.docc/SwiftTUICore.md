# ``SwiftTUICore``

A SwiftUI-style framework for building terminal user interfaces.

## Overview

SwiftTUI renders declarative views to the terminal. You describe a UI with the
same patterns used in SwiftUI — a ``View`` tree, stacks for layout, ``State``
for local state — and SwiftTUI lays it out and draws it to the screen.

```swift
import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        Text("Hello, terminal")
    }
}
```

Add `SwiftTUI` to your package and import it; it re-exports everything in this
module. The `App` entry point lives in the `SwiftTUI` module — see
<doc:GettingStarted>.

SwiftTUI implements a subset of SwiftUI. APIs that do not yet exist are listed in
<doc:SwiftUICompatibility>.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:SwiftUICompatibility>
- ``View``

### Views

- ``Text``
- ``Button``
- ``TextField``
- ``ForEach``

### Layout

- ``HStack``
- ``VStack``
- ``ZStack``

### State and Data Flow

- ``State``
- ``Binding``
- ``Environment``

### Styling

- ``Color``
