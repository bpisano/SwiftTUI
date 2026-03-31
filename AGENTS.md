# SwiftTUI Agent Context

This repository is a SwiftUI-inspired terminal UI engine. Most architectural questions in this repo are easier to answer by first comparing the local implementation with OpenSwiftUI and OpenAttributeGraph.

## Mandatory Reference Projects

Before changing any of the following areas, read the reference projects first:

- `ViewList`
- `ForEach`
- `LayoutView`
- `Subgraph`
- `Attribute`
- dynamic view lifetime / removal / reorder behavior

Reference repositories:

- `/Users/bpisano/Dev/OpenSwiftUI`
- `/Users/bpisano/Dev/OpenAttributeGraph`

Recommended starting points in the reference code:

- `/Users/bpisano/Dev/OpenSwiftUI/Sources/OpenSwiftUICore/View/Input/ViewList.swift`
- `/Users/bpisano/Dev/OpenSwiftUI/Sources/OpenSwiftUICore/View/DynamicViewContent/ForEach.swift`
- `/Users/bpisano/Dev/OpenSwiftUI/Sources/OpenSwiftUICore/Layout/Dynamic/DynamicLayoutView.swift`
- `/Users/bpisano/Dev/OpenAttributeGraph/Sources/OpenAttributeGraph/Graph/Subgraph.swift`

Do not make architectural changes to the local view list or graph model without checking how those concepts are represented in the two reference repos.

## Package Structure

The package is split into a few layers:

- `Sources/AttributeGraph`
  A lightweight attribute graph engine used by the UI system.
- `Sources/Geometry`
  Shared geometry primitives such as `Point`, `Size`, `Rect`.
- `Sources/Terminal`
  Terminal-specific primitives and rendering infrastructure.
- `Sources/SwiftTUICore`
  The view system, layout system, modifiers, view lists, dynamic properties, and most framework logic.
- `Sources/SwiftTUI`
  Higher-level app/runtime integration built on top of `SwiftTUICore` and `Terminal`.
- `Sources/AppDemo`
  Manual executable demo.

Tests are mainly in:

- `Tests/SwiftTUICoreTests`
- `Tests/AttributeGraphTests`
- `Tests/GeometryTests`

## Isolation Model

Most targets use `.defaultIsolation(MainActor.self)` in `Package.swift`.

Assume the framework is conceptually main-actor driven:

- avoid introducing background-thread assumptions
- be careful with API shapes that interact badly with main-actor isolation
- if a design looks odd from a pure Swift perspective, first check whether it exists because of graph/lifetime constraints

## Core Rendering Pipeline

The core pipeline is:

1. A `View` is lowered through `makeView` and `makeViewList`.
2. `ViewInputs` carries runtime inputs:
   - position
   - size
   - phase
   - storage
3. `ViewListOutputs` describes the child structure of a view.
4. `ViewList` turns that structure into `[ViewOutputs]`.
5. `ViewOutputs` contains:
   - `layoutComputer`
   - `displayList`
6. Layout containers compute child geometries and feed remapped `ViewInputs` to children.

Important files:

- `Sources/SwiftTUICore/Core/View/View.swift`
- `Sources/SwiftTUICore/Core/View/ViewInputs.swift`
- `Sources/SwiftTUICore/Core/View/ViewOutputs.swift`
- `Sources/SwiftTUICore/Core/View/ViewListOutputs.swift`
- `Sources/SwiftTUICore/Core/ViewList/ViewList.swift`
- `Sources/SwiftTUICore/Views/LayoutView.swift`

## View Lists

`ViewListOutputs` is a central type. It preserves structure before the system commits to a runtime `ViewList`.

Current local model:

- `.staticList([any ViewElement])`
- `.dynamicList(Attribute<any ViewList>)`

That distinction is fundamental. Bugs around `onAppear`, `ForEach`, removal, or repeated `makeView` calls are often caused by accidentally turning a static structure into a dynamic one too early.

When working in this area:

- preserve static structure as long as possible
- only box into `Attribute<any ViewList>` when runtime dynamism is actually needed
- compare with OpenSwiftUI's handling of `_ViewListOutputs`, static lists, dynamic lists, and modifiers applied to lists

## Layout

`LayoutView` is the bridge between child `ViewOutputs` and a `Layout`.

`Layout` itself is intentionally simple:

- `sizeThatFits(proposal:subviews:)`
- `placeSubviews(in:subviews:)`

`Layout.layoutComputer(for:)` creates a `LayoutComputer` that:

- asks each child for its size
- lets the layout place subviews
- records child geometries

Important files:

- `Sources/SwiftTUICore/Core/Layout/Layout.swift`
- `Sources/SwiftTUICore/Views/LayoutView.swift`
- `Sources/SwiftTUICore/Views/RootLayout.swift`
- `Sources/SwiftTUICore/Views/HStack.swift`
- `Sources/SwiftTUICore/Views/VStack.swift`
- `Sources/SwiftTUICore/Views/ZStack.swift`

If layout bugs involve dynamic children, compare with OpenSwiftUI's dynamic layout path before refactoring.

## View Modifiers

Modifiers are implemented as their own lowering pipeline and can affect both `makeView` and `makeViewList`.

Important files:

- `Sources/SwiftTUICore/Core/ViewModifier/ViewModifier.swift`
- `Sources/SwiftTUICore/Core/ViewModifier/ViewModifierContent.swift`
- `Sources/SwiftTUICore/Core/ViewModifier/UnaryViewModifier.swift`
- `Sources/SwiftTUICore/ViewModifiers`

When behavior differs between a direct child and the same child inside a list, check the modifier's `makeViewList` path.

## AttributeGraph Model

The local `AttributeGraph` is a lightweight reimplementation, not a full copy of Apple's internals.

Key concepts:

- `Attribute<T>`
  Stores a value or rule and tracks dependencies on read.
- `Graph`
  Registers nodes, records dependencies, invalidates dependents, and tracks transactions.
- `Subgraph`
  Groups attribute lifetimes so dynamic structures such as `ForEach` items can be created and cleaned as a unit.

Important files:

- `Sources/AttributeGraph/Attribute/Attribute.swift`
- `Sources/AttributeGraph/Graph/Graph.swift`
- `Sources/AttributeGraph/Subgraph/Subgraph.swift`

If a bug involves stale nodes, repeated reevaluations, or removal crashes, inspect the graph model before changing view code.

## Current `ForEach` Architecture

`ForEach` is currently implemented as a dynamic view list.

Important files:

- `Sources/SwiftTUICore/Views/ForEach/ForEach.swift`
- `Sources/SwiftTUICore/Views/ForEach/ForEachState.swift`
- `Sources/SwiftTUICore/Views/ForEach/ForEachViewList.swift`

Current local design:

- `ForEach.makeViewList` returns a `.dynamicList`
- `ForEachState` keeps items keyed by explicit data IDs
- each item currently stores:
  - `childView`
  - `viewListOutputs`
  - `viewSubgraph`
  - `viewOutputsSubgraph`
  - cached `[ViewOutputs]`

This is an important area of ongoing architectural work. Before changing it:

- compare with OpenSwiftUI's item lifetime and subgraph ownership
- compare how OpenSwiftUI represents per-item child structure
- verify behavior on:
  - insertion
  - update
  - reorder
  - removal

## Debugging and Validation

Useful tests:

- `Tests/SwiftTUICoreTests/Views/ForEachTests.swift`
- `Tests/SwiftTUICoreTests/DebugTests.swift`
- `Tests/SwiftTUICoreTests/OnAppearTests.swift`
- `Tests/SwiftTUICoreTests/OnDisappearTests.swift`
- `Tests/SwiftTUICoreTests/RootLayoutTests.swift`

Useful commands:

- `swift test --filter ForEachTests`
- `swift test --filter OnAppearTests`
- `swift test`

For graph debugging, the project often uses:

- `Graph.current.digraph`
- `copyToClipboard(...)` in debug tests

## Working Rules For Agents

- Read the local implementation first.
- For any architectural change, read the matching OpenSwiftUI/OpenAttributeGraph implementation before proposing a design.
- Do not change tests casually. Fix the architecture or runtime behavior instead.
- Preserve the static vs dynamic list distinction.
- Treat `ForEach`, `LayoutView`, `ViewListOutputs`, and `Subgraph` as tightly coupled concepts.
- Prefer small, reviewable refactors over sweeping rewrites unless the change really requires it.
