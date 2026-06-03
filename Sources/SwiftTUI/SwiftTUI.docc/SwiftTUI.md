# ``SwiftTUI``

A SwiftUI-style framework for building terminal user interfaces.

## Overview

SwiftTUI renders declarative views to the terminal. You describe a UI with the
same patterns used in SwiftUI — a `View` tree, stacks for layout, `@State` for
local state — and SwiftTUI lays it out and draws it to the screen.

```swift
import SwiftTUI

@main
struct MyApp: App {
    var body: some View {
        Text("Hello, terminal")
    }
}
```

SwiftTUI implements a subset of SwiftUI. APIs that do not yet exist are listed in
<doc:SwiftUICompatibility>.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:SwiftUICompatibility>
- ``App``
- ``SwiftTUICore/View``

### Views

- ``SwiftTUICore/Text``
- ``SwiftTUICore/Button``
- ``SwiftTUICore/TextField``
- ``SwiftTUICore/ForEach``

### Layout

- ``SwiftTUICore/HStack``
- ``SwiftTUICore/VStack``
- ``SwiftTUICore/ZStack``

### State and Data Flow

- ``SwiftTUICore/State``
- ``SwiftTUICore/Binding``
- ``SwiftTUICore/Environment``

### Styling

- ``SwiftTUICore/Color``
