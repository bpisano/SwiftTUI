# SwiftTUI Copilot Instructions

This repository is a SwiftUI-inspired terminal UI framework with a custom `AttributeGraph`. Architectural suggestions should be grounded in the local implementation and compared against the reference projects below before proposing structural changes.

## Read These Reference Repos First

These two repositories are essential to understanding this project:

- `/Users/bpisano/Dev/OpenSwiftUI`
- `/Users/bpisano/Dev/OpenAttributeGraph`

For architecture work, start with:

- `/Users/bpisano/Dev/OpenSwiftUI/Sources/OpenSwiftUICore/View/Input/ViewList.swift`
- `/Users/bpisano/Dev/OpenSwiftUI/Sources/OpenSwiftUICore/View/DynamicViewContent/ForEach.swift`
- `/Users/bpisano/Dev/OpenSwiftUI/Sources/OpenSwiftUICore/Layout/Dynamic/DynamicLayoutView.swift`
- `/Users/bpisano/Dev/OpenAttributeGraph/Sources/OpenAttributeGraph/Graph/Subgraph.swift`

Do not suggest major changes to `ViewList`, `ForEach`, `LayoutView`, or `Subgraph` without comparing the local code to those references.

## Project Map

- `Sources/AttributeGraph`
  Local dependency graph engine.
- `Sources/Geometry`
  Geometry primitives.
- `Sources/Terminal`
  Terminal rendering primitives.
- `Sources/SwiftTUICore`
  Core view system, layout, modifiers, view lists, dynamic properties.
- `Sources/SwiftTUI`
  Runtime/app integration.

Tests are mainly in `Tests/SwiftTUICoreTests`.

## Main Architectural Concepts

### Views

The main lowering entry points are:

- `View.makeView`
- `View.makeViewList`

See:

- `Sources/SwiftTUICore/Core/View/View.swift`
- `Sources/SwiftTUICore/Core/View/ViewInputs.swift`
- `Sources/SwiftTUICore/Core/View/ViewOutputs.swift`

`ViewInputs` carries position, size, phase, and storage. `ViewOutputs` carries `layoutComputer` and `displayList`.

### View Lists

`ViewListOutputs` is a structural intermediate form. The static vs dynamic distinction is fundamental.

See:

- `Sources/SwiftTUICore/Core/View/ViewListOutputs.swift`
- `Sources/SwiftTUICore/Core/ViewList/ViewList.swift`
- `Sources/SwiftTUICore/Core/ViewElement`
- `Sources/SwiftTUICore/Core/ViewBuilder`

When in doubt:

- preserve static structure as long as possible
- only box into a dynamic `ViewList` when necessary

### Layout

`LayoutView` bridges child `ViewOutputs` and a `Layout`.

See:

- `Sources/SwiftTUICore/Core/Layout/Layout.swift`
- `Sources/SwiftTUICore/Views/LayoutView.swift`
- `Sources/SwiftTUICore/Views/HStack.swift`
- `Sources/SwiftTUICore/Views/VStack.swift`
- `Sources/SwiftTUICore/Views/ZStack.swift`
- `Sources/SwiftTUICore/Views/RootLayout.swift`

If a layout issue involves dynamic children, compare the local code to OpenSwiftUI's dynamic layout model before suggesting a refactor.

### AttributeGraph

The UI system depends heavily on the local graph model.

See:

- `Sources/AttributeGraph/Attribute/Attribute.swift`
- `Sources/AttributeGraph/Graph/Graph.swift`
- `Sources/AttributeGraph/Subgraph/Subgraph.swift`

Important behavior:

- reading an `Attribute` registers a dependency
- writing invalidates dependents
- `Subgraph` groups node lifetimes for dynamic content

### ForEach

`ForEach` is a dynamic list and is one of the most fragile architectural areas.

See:

- `Sources/SwiftTUICore/Views/ForEach/ForEach.swift`
- `Sources/SwiftTUICore/Views/ForEach/ForEachState.swift`
- `Sources/SwiftTUICore/Views/ForEach/ForEachViewList.swift`

Current local implementation keeps per-item state and caches outputs. Before suggesting changes to lifetime, removal, reorder, or reuse behavior, compare it with OpenSwiftUI's approach.

## Actor Isolation

Most targets use `.defaultIsolation(MainActor.self)` in `Package.swift`. Assume the framework is main-actor oriented.

## Validation

Useful tests:

- `Tests/SwiftTUICoreTests/Views/ForEachTests.swift`
- `Tests/SwiftTUICoreTests/DebugTests.swift`
- `Tests/SwiftTUICoreTests/OnAppearTests.swift`
- `Tests/SwiftTUICoreTests/OnDisappearTests.swift`

Useful commands:

- `swift test --filter ForEachTests`
- `swift test`

## Guidance For Suggestions

- Prefer explanations tied to the local files and types.
- For architecture, compare with OpenSwiftUI/OpenAttributeGraph before proposing changes.
- Avoid generic SwiftUI advice that ignores the custom graph and view list model.
- Treat `ViewListOutputs`, `LayoutView`, `ForEach`, and `Subgraph` as strongly coupled.
