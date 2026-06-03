# Laying Out Views

Arrange views with stacks and size them with frames.

## Overview

SwiftTUI lays out views in terminal cells: one unit is one character cell wide
and one row tall. You build a layout by nesting views inside stacks and, when
you need a fixed size, applying a ``View/frame(width:height:alignment:)``.

Layout works top-down: a container proposes a size to each child, the child
reports the size it wants, and the container places it. Sizes are measured in
character cells, so a width of `10` means ten columns.

## Stacks

The three stacks arrange their children along an axis:

- ``HStack`` places children left to right.
- ``VStack`` places children top to bottom.
- ``ZStack`` layers children back to front, overlapping in the same space.

```swift
HStack {
    Text("Left")
    Text("Right")
}

VStack {
    Text("Top")
    Text("Bottom")
}

ZStack {
    Color.blue
    Text("On top")
}
```

### Alignment

``HStack`` and ``VStack`` take an alignment that controls how children line up
across the stack's axis. An ``HStack`` aligns children vertically
(``VerticalAlignment``: `.top`, `.center`, `.bottom`); a ``VStack`` aligns them
horizontally (``HorizontalAlignment``: `.leading`, `.center`, `.trailing`).

```swift
VStack(alignment: .leading) {
    Text("Title")
    Text("A longer subtitle")
}
```

``ZStack`` aligns its layered children with a two-dimensional ``Alignment``
such as `.center`, `.topLeading`, or `.bottomTrailing`.

```swift
ZStack(alignment: .topTrailing) {
    Color.blue
    Text("Badge")
}
```

### Spacing

``HStack`` and ``VStack`` take a `spacing` value — the number of cells between
adjacent children. Spacing defaults to `0`, so children sit flush unless you
ask for a gap:

```swift
VStack(spacing: 1) {
    Text("Line one")
    Text("Line two")
}
```

## Frames

``View/frame(width:height:alignment:)`` gives a view a fixed size in cells.
Pass `width`, `height`, or both; an omitted dimension keeps the view's own
size.

```swift
Text("Boxed")
    .frame(width: 20, height: 3)
```

When the frame is larger than the view, `alignment` controls where the view
sits inside it. The default is `.center`.

```swift
Text("Right")
    .frame(width: 20, alignment: .trailing)
```

## Not yet supported

- `Spacer` and `Divider`.
- `.background(_:)` and `.overlay(_:)` (layer with ``ZStack`` instead).
- `GeometryReader` and flexible frames (`minWidth`, `maxWidth`, `idealWidth`).
- Default stack spacing — `spacing` is `0` unless you set it, rather than a
  platform-derived default.
