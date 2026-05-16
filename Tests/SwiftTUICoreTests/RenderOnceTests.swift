import Foundation
import Testing
import Geometry
import SwiftTUICore
@testable import SwiftTUI
@testable import SwiftTUIRuntime

@Suite("renderOnce + renderToANSI")
struct RenderOnceTests {
    @Test("Codable round-trip + ANSI render contains text")
    func roundTrip() async throws {
        let displayList = SwiftTUIRuntime.renderOnce(
            Text("hello"),
            size: Size(width: 80, height: 1)
        )

        let encoded = try JSONEncoder().encode(displayList)
        let decoded = try JSONDecoder().decode(DisplayList.self, from: encoded)

        let frame = await SwiftTUIRuntime.renderToANSI(
            decoded,
            size: Size(width: 80, height: 1)
        )

        #expect(frame.contains("hello"))
    }
}
