# Controls

Take user input with buttons and text fields.

## Overview

Controls are the views the user interacts with. ``Button`` runs an action when
activated, and ``TextField`` edits a string. Both are focusable: the user moves
focus between them with the keyboard, and the focused control receives input.
See <doc:ManagingFocus> for how focus moves.

## Button

``Button`` runs a closure when the user activates it. Create one with a title,
or with a custom label view:

```swift
Button("Save") {
    save()
}

Button(action: submit) {
    Text("Submit")
}
```

A button takes focus during navigation. When it holds focus, pressing `Return`
runs its action. Disable a button with ``View/disabled(_:)``; a disabled button
is skipped during focus navigation and does not run its action:

```swift
Button("Continue") {
    advance()
}
.disabled(!isReady)
```

## TextField

``TextField`` edits a string bound with ``Binding``. Pass a placeholder and a
binding to the text:

```swift
struct NameEntry: View {
    @State private var name = ""

    var body: some View {
        TextField("Enter your name", text: $name)
    }
}
```

While the text field holds focus, typing edits the bound value, and the view
updates as it changes. Run an action when the user presses `Return` with
``View/onSubmit(_:)``:

```swift
TextField("Search", text: $query)
    .onSubmit {
        runSearch(query)
    }
```

## Styling buttons

Change how a button draws by applying a ``ButtonStyle`` with
``View/buttonStyle(_:)``. A style builds the button's view from a
``ButtonStyleConfiguration``, which carries the button's `label` and whether it
``ButtonStyleConfiguration/isPressed``. Read ``EnvironmentValues/isFocused`` to
react to focus.

```swift
struct BracketButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text(isFocused ? "[" : " ")
            configuration.label
            Text(isFocused ? "]" : " ")
        }
        .foregroundStyle(configuration.isPressed ? .yellow : .primary)
    }
}

Button("Run") { run() }
    .buttonStyle(BracketButtonStyle())
```

The built-in ``DefaultButtonStyle`` brackets the label with `>` and `<` while
the button is focused.

## Focus

Both controls take part in keyboard focus without extra code. To read whether a
control is focused, drive focus from state, or move it programmatically, see
<doc:ManagingFocus>.

## Not yet supported

- `Toggle`, `Slider`, `Picker`, `Stepper`, and `Menu`.
- Secure text entry and multi-line text editors.
- Button roles (`.destructive`, `.cancel`).
