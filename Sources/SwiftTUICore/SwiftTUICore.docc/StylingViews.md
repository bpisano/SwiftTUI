# Styling Views

Color text and views with shape styles.

## Overview

SwiftTUI styling maps to what a terminal can render: ANSI colors. You set the
color of text and other foreground content with ``View/foregroundStyle(_:)``,
and you fill space with ``Color`` used directly as a view.

## Color

``Color`` is both a view and a ``ShapeStyle``. Used as a view, it fills the
space proposed to it — useful as a background layer in a ``ZStack``. Used as a
style, it colors foreground content.

Create a color from the named ANSI palette, its dimmed `soft` variants, or RGB
components:

```swift
Color.red
Color.softBlue
Color(red: 0.2, green: 0.8, blue: 0.4)
```

The named colors are `black`, `red`, `green`, `yellow`, `blue`, `magenta`,
`cyan`, `white`, and `gray`, each with a dimmed `soft` variant
(``Color/softRed``, ``Color/softBlue``, and so on).

Terminal output is limited to the available palette; RGB values are mapped to
the closest supported color.

## Foreground style

``View/foregroundStyle(_:)`` sets the color of a view's foreground content,
such as the glyphs of a ``Text``:

```swift
Text("Error")
    .foregroundStyle(.red)

Text("Muted")
    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.5))
```

The style applies to the subtree, so children inherit it unless they set their
own.

## ShapeStyle

``ShapeStyle`` is the protocol for things that can color content.
``View/foregroundStyle(_:)`` takes any `ShapeStyle`. ``Color`` is the concrete
style SwiftTUI provides today.

Semantic styles map to fixed colors so you can express intent rather than a
specific hue:

- ``ShapeStyle/primary`` and ``ShapeStyle/secondary`` for primary and de-emphasized content.
- ``ShapeStyle/tertiary``, ``ShapeStyle/quaternary``, and ``ShapeStyle/quinary`` for progressively fainter content.

```swift
VStack(alignment: .leading) {
    Text("Title")
        .foregroundStyle(.primary)
    Text("Subtitle")
        .foregroundStyle(.secondary)
}
```

## Not yet supported

- Gradients, hierarchical fills, and materials.
- Text styling beyond color — bold, italic, and underline.
- `.background(_:)` and `.tint(_:)`. To put a color behind content, layer a
  ``Color`` view in a ``ZStack``.
