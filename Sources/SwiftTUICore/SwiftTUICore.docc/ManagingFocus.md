# Managing Focus

Move keyboard focus between views and react to it.

## Overview

In a terminal there is no pointer, so the keyboard is the only way to interact
with a view. Focus is what decides which view receives that input. At any moment
a single view holds focus; the user moves it with the keyboard, and views read
or drive it through the environment, bindings, and the ``Focus`` property
wrapper.

``Button`` and ``TextField`` are focusable out of the box — they take part in
focus navigation without any extra code. Use the modifiers below when you build
your own focusable views or need to read and control focus yourself.

## Moving focus with the keyboard

The runtime routes a fixed set of keys to focus navigation before they reach
your views:

| Key | Action |
| --- | --- |
| `Tab` | Move to the next focusable view |
| `Shift` + `Tab` | Move to the previous focusable view |
| Arrow keys | Move focus by position (up, down, left, right) |

`Tab` and `Shift` + `Tab` walk focusable views in order. The arrow keys move
focus spatially, picking the nearest focusable view in that direction based on
where views sit on screen.

## Making a view focusable

Mark a view as focusable with ``View/focusable(_:)``. A focusable view joins
focus navigation and reads ``EnvironmentValues/isFocused`` as `true` while it
holds focus.

```swift
struct Tile: View {
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        Text("Tile")
            .foregroundStyle(isFocused ? .yellow : .white)
            .focusable()
    }
}
```

Pass `false` to opt a view out of focus without removing the modifier:

```swift
Tile()
    .focusable(rowIsActive)
```

## Reading whether a view is focused

``EnvironmentValues/isFocused`` is `true` for the subtree of the view that
currently holds focus. Read it with `@Environment` to change how a view draws
while focused:

```swift
struct HighlightedRow: View {
    let label: String

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        Text(isFocused ? "> \(label)" : "  \(label)")
    }
}
```

## Controlling focus from state

Bind focus to your own state with ``View/focused(_:)``. The binding is two-way:
setting it to `true` moves focus to the view, and it tracks whether the view
currently holds focus.

```swift
struct LoginForm: View {
    @State private var username = ""
    @State private var usernameFocused = false

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .focused($usernameFocused)

            Button("Focus the field") {
                usernameFocused = true
            }
        }
    }
}
```

When several views share one focus target, bind them to a value with
``View/focused(_:equals:)``. Setting the bound value to a view's tag moves focus
there, and the binding updates to match whichever tagged view becomes focused.

```swift
enum Field {
    case username
    case password
}

struct LoginForm: View {
    @State private var username = ""
    @State private var password = ""
    @State private var focus: Field = .username

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .focused($focus, equals: .username)

            TextField("Password", text: $password)
                .focused($focus, equals: .password)
        }
    }
}
```

## Moving focus programmatically

Use the ``Focus`` property wrapper to move focus from your own logic, in the
same directions the keyboard handles. Calling it returns `false` when no
eligible view exists in that direction.

```swift
struct Wizard: View {
    @Focus private var focus

    var body: some View {
        VStack {
            // ...fields...

            Button("Next") {
                focus(.next)
            }
        }
    }
}
```

Pass ``Focus/Direction/clear`` to drop focus entirely.

## Grouping focusable views

``View/focusGroup()`` keeps the focusable views in a subtree together during
navigation, ordered as a unit relative to other focusable views. Use it to keep
the controls of one section from interleaving with another's.

```swift
HStack {
    VStack {
        Button("Copy") {}
        Button("Paste") {}
    }
    .focusGroup()

    VStack {
        Button("Undo") {}
        Button("Redo") {}
    }
    .focusGroup()
}
```

## Reacting to submission

A focused ``TextField`` submits when the user presses Return. Run an action on
submit with ``View/onSubmit(_:)``:

```swift
TextField("Search", text: $query)
    .onSubmit {
        runSearch(query)
    }
```

## Not yet supported

- The `@FocusState` property wrapper. Drive focus with `@State` plus
  ``View/focused(_:)`` or ``View/focused(_:equals:)``, or the ``Focus`` property
  wrapper for imperative moves.
- `focusSection()` and default-focus APIs (`prefersDefaultFocus(_:in:)`).
- Customizing which keys move focus, or disabling the built-in `Tab` and arrow
  navigation.
