# SwiftUI Compatibility

What SwiftTUI implements, and what it does not yet support.

## Overview

SwiftTUI follows SwiftUI's API where it makes sense for the terminal, but it
implements only a subset. This page tracks the gaps so you know what to expect.

> Note: This list is maintained by hand and will expand as the framework grows.

## Not yet supported

The following common SwiftUI APIs are not yet available:

- `Spacer`
- `Divider`
- `.background(_:)` and `.overlay(_:)`
- `GeometryReader`
- `ScrollView`, `List`
- `Image`
- `Toggle`, `Slider`, `Picker`
- Animations and transitions

This list is not exhaustive. Individual articles call out missing APIs relevant
to their topic.
