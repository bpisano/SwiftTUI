import Foundation
import AttributeGraph
import SwiftTUICore
import Terminal

public enum SwiftTUIRuntime {
    public static func run<V: View>(
        @ViewBuilder _ content: @escaping @MainActor () -> V
    ) async -> Never {
        await MainActor.run {
            start(content())
        }
        await withUnsafeContinuation { (_: UnsafeContinuation<Void, Never>) in }
        fatalError("SwiftTUI runtime suspension resumed unexpectedly.")
    }

    public static func main<V: View>(
        @ViewBuilder _ content: @escaping @MainActor () -> V
    ) -> Never {
        DispatchQueue.main.async {
            MainActor.assumeIsolated {
                start(content())
            }
        }
        RunLoop.main.run()

        fatalError("RunLoop.main.run() returned unexpectedly.")
    }

    @MainActor
    private static func start<V: View>(_ view: V) {
        let terminal: Terminal = .current
        let renderState: RenderState = .init()
        let engine: TerminalEngine = .init(
            configuration: .standard,
            terminal: terminal,
            view: RootLayout {
                view
            }
        )

        let graph: Graph = .init()
        graph.makeCurrent()
        graph.onInvalidate = {
            renderState.setNeedsRender()
        }

        engine.setup()

        let frameRate: Double = 1 / 60
        let timer = Timer.scheduledTimer(
            withTimeInterval: frameRate,
            repeats: true
        ) { _ in
            Task { @MainActor in
                guard renderState.needsRender else { return }
                renderState.clearNeedsRender()
                await engine.render()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
    }
}
