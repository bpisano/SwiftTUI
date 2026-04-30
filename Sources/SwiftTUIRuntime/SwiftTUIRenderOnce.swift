import Foundation
import AttributeGraph
import Geometry
import SwiftTUICore

extension SwiftTUIRuntime {
    /// Renders a view once into a `DisplayList` without entering the terminal event loop.
    ///
    /// Used by off-screen consumers (e.g. an MCP tool that needs to ship a serialized
    /// UI snapshot to a remote client). No terminal I/O is performed.
    @MainActor
    public static func renderOnce<V: View>(
        _ view: V,
        size: Size
    ) -> DisplayList {
        let graph = Graph()
        graph.makeCurrent()

        let inputs = ViewInputs(
            position: Attribute<Point>(wrappedValue: .zero),
            size: Attribute<Size>(wrappedValue: size),
            phase: Attribute<ViewPhase>(wrappedValue: .active),
            environment: Attribute<EnvironmentValues>(wrappedValue: .init()),
            storage: ViewInputsStorage()
        )

        return resolveDisplayList(for: RootLayout { view }, inputs: inputs)
    }

    /// Renders an existing `DisplayList` to an ANSI escape-encoded string.
    ///
    /// Useful when a `DisplayList` arrived from the wire (e.g. an MCP tool result) and
    /// just needs to be drawn into a terminal scrollback.
    public static func renderToANSI(
        _ list: DisplayList,
        size: Size,
        configuration: RenderingConfiguration = .offline
    ) async -> String {
        let renderer = TerminalRenderer(configuration: configuration)
        return await renderer.renderFrame(displayList: list, in: size)
    }

    @MainActor
    private static func resolveDisplayList<R: View>(
        for view: R,
        inputs: ViewInputs
    ) -> DisplayList {
        let attribute = Attribute<R>(wrappedValue: view)
        let outputs = R.makeView(attribute, inputs: inputs)
        return outputs.displayList.wrappedValue
    }
}
