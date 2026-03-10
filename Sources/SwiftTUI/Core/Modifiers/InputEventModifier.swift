//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 05/02/2026.
//

import Foundation
import Terminal
import SwiftTUICore

//struct InputEventViewModifier<I: Input>: ViewModifier {
//    private let input: I
//    private let onEvent: @MainActor (I.Event) -> Void
//
//    @State private var inputStreamTask: Task<Void, Never>?
//
//    init(
//        input: I,
//        onEvent: @escaping @MainActor (I.Event) -> Void
//    ) {
//        self.input = input
//        self.onEvent = onEvent
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .onAppear {
//                inputStreamTask = Task.detached {
//                    for await event in await input.events() {
//                        guard !Task.isCancelled else { break }
//                        Task { @MainActor in
//                            onEvent(event)
//                        }
//                    }
//                }
//            }
//            .onDisappear {
//                inputStreamTask?.cancel()
//            }
//    }
//}
//
//extension View {
//    public func onEvent<I: Input>(
//        of input: I,
//        _ action: @escaping @MainActor (_ event: I.Event) -> Void
//    ) -> some View {
//        modifier(InputEventViewModifier(input: input, onEvent: action))
//    }
//}
