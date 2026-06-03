//
//  FocusedViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import AttributeGraph

struct FocusedViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let binding: Binding<Bool>

    init(binding: Binding<Bool>) {
        self.binding = binding
    }
}

extension FocusedViewModifier {
    static func makeView(
        _ modifier: Attribute<FocusedViewModifier>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let nodeID: FocusNodeID = .init(modifier.id)
        let position: Attribute<Point> = inputs.position
        let size: Attribute<Size> = inputs.size

        let childEnvironment = Attribute("Focused Environment") {
            var env = inputs.environment.wrappedValue
            env.isFocused = env.focusManager?.currentFocus == nodeID
            return env
        }

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironment

        let childOutputs: ViewOutputs = makeViewOutputs(modifiedInputs)

        let sync = Attribute("Focused Sync") {
            let modifierValue = modifier.wrappedValue
            let bound = modifierValue.binding.wrappedValue
            guard let manager = inputs.environment.wrappedValue.focusManager else { return }
            let current = manager.currentFocus
            let isFocused = current == nodeID

            if isFocused, bound != true {
                CallbackQueue.shared.enqueue {
                    modifierValue.binding.wrappedValue = true
                }
            } else if !isFocused, bound != false {
                CallbackQueue.shared.enqueue {
                    modifierValue.binding.wrappedValue = false
                }
            }
        }

        let focusList = Attribute("Focused FocusList") {
            _ = sync.wrappedValue
            let frame = Rect(origin: position.wrappedValue, size: size.wrappedValue)
            let node = FocusableNode(id: nodeID, frame: frame, isEnabled: true)
            let selfList = FocusList(.node(node))
            if let childList = childOutputs.focusList?.wrappedValue {
                return selfList.appending(childList)
            }
            return selfList
        }

        return ViewOutputs(
            viewId: childOutputs.viewId,
            layoutComputer: childOutputs.layoutComputer,
            displayList: childOutputs.displayList,
            focusList: focusList
        )
    }
}

extension View {
    /// Binds the view's focus state to a Boolean.
    ///
    /// The binding is two-way: setting it to `true` moves focus to this view,
    /// and the binding tracks whether this view currently holds focus.
    ///
    /// ```swift
    /// @State private var isFocused: Bool = false
    ///
    /// TextField("Name", text: $name)
    ///     .focused($isFocused)
    /// ```
    ///
    /// - Parameter binding: A binding to a Boolean that drives and reflects
    ///   whether this view is focused.
    public func focused(_ binding: Binding<Bool>) -> some View {
        modifier(FocusedViewModifier(binding: binding))
    }
}
