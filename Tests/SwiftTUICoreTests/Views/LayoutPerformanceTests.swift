#if canImport(XCTest)
import Foundation
import Geometry
import XCTest

@testable import AttributeGraph
@testable import SwiftTUICore

/// Performance benchmarks for `HStack` and `VStack` layout passes.
///
/// Each test measures:
/// - **initial layout**: first `sizeThatFits` + `viewGeometries` call (cold engine)
/// - **repeated layout**: N re-layout passes (hot engine, `updateCache` path)
/// - **flexible children**: layout with a mix of fixed and flexible children
///
/// Child variants:
/// - *fixed* — always return the same size regardless of proposal
/// - *flexible* — expand to fill the proposed axis
@MainActor
final class LayoutPerformanceTests: XCTestCase {

    // MARK: - Helpers

    private static let proposal = ProposedViewSize(width: 200, height: 100)
    private static let rect = Rect(origin: .zero, size: Size(width: 200, height: 100))

    private static let measureOptions: XCTMeasureOptions = {
        let o = XCTMeasureOptions()
        o.iterationCount = 10
        return o
    }()

    /// Leaf that always returns `size` regardless of the proposal.
    private func makeFixedLeaf(size: Size = Size(width: 10, height: 5)) -> LayoutComputer {
        LayoutComputer { _ in size } viewGeometries: { rect in
            [ViewGeometry(origin: rect.origin, size: size)]
        }
    }

    /// Leaf that fills the full proposed size (flexible in both axes).
    private func makeFlexibleLeaf() -> LayoutComputer {
        LayoutComputer { proposal in
            Size(
                width: proposal.width ?? 100,
                height: proposal.height ?? 50
            )
        } viewGeometries: { rect in
            [ViewGeometry(origin: rect.origin, size: rect.size)]
        }
    }

    private func fixedLeaves(_ count: Int) -> [LayoutComputer] {
        (0..<count).map { _ in makeFixedLeaf() }
    }

    /// Half fixed, half flexible.
    private func mixedLeaves(_ count: Int) -> [LayoutComputer] {
        (0..<count).map { i in i.isMultiple(of: 2) ? makeFixedLeaf() : makeFlexibleLeaf() }
    }

    /// Run one full layout pass: sizeThatFits + viewGeometries.
    private func runPass(_ computer: LayoutComputer) {
        let size = computer.sizeThatFits(Self.proposal)
        _ = computer.viewGeometries(Rect(origin: .zero, size: size))
    }

    // MARK: - HStack · Fixed children

    func testHStackInitialLayout_4_FixedChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: HStack(), subviews: fixedLeaves(4))
            runPass(engine.makeLayoutComputer())
        }
    }

    func testHStackInitialLayout_16_FixedChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: HStack(), subviews: fixedLeaves(16))
            runPass(engine.makeLayoutComputer())
        }
    }

    func testHStackInitialLayout_64_FixedChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: HStack(), subviews: fixedLeaves(64))
            runPass(engine.makeLayoutComputer())
        }
    }

    // MARK: - HStack · Repeated layout (hot engine, updateCache path)

    func testHStackRepeatedLayout_16_FixedChildren() {
        let leaves = fixedLeaves(16)
        let engine = LayoutEngine(layout: HStack(), subviews: leaves)
        runPass(engine.makeLayoutComputer())  // prime

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            engine.update(layout: HStack(), subviews: leaves)
            runPass(engine.makeLayoutComputer())
        }
    }

    func testHStackRepeatedLayout_64_FixedChildren() {
        let leaves = fixedLeaves(64)
        let engine = LayoutEngine(layout: HStack(), subviews: leaves)
        runPass(engine.makeLayoutComputer())

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            engine.update(layout: HStack(), subviews: leaves)
            runPass(engine.makeLayoutComputer())
        }
    }

    // MARK: - HStack · Flexible children

    func testHStackInitialLayout_16_FlexibleChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: HStack(), subviews: mixedLeaves(16))
            runPass(engine.makeLayoutComputer())
        }
    }

    func testHStackInitialLayout_64_FlexibleChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: HStack(), subviews: mixedLeaves(64))
            runPass(engine.makeLayoutComputer())
        }
    }

    // MARK: - VStack · Fixed children

    func testVStackInitialLayout_4_FixedChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: VStack(), subviews: fixedLeaves(4))
            runPass(engine.makeLayoutComputer())
        }
    }

    func testVStackInitialLayout_16_FixedChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: VStack(), subviews: fixedLeaves(16))
            runPass(engine.makeLayoutComputer())
        }
    }

    func testVStackInitialLayout_64_FixedChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: VStack(), subviews: fixedLeaves(64))
            runPass(engine.makeLayoutComputer())
        }
    }

    // MARK: - VStack · Repeated layout (hot engine, updateCache path)

    func testVStackRepeatedLayout_16_FixedChildren() {
        let leaves = fixedLeaves(16)
        let engine = LayoutEngine(layout: VStack(), subviews: leaves)
        runPass(engine.makeLayoutComputer())

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            engine.update(layout: VStack(), subviews: leaves)
            runPass(engine.makeLayoutComputer())
        }
    }

    func testVStackRepeatedLayout_64_FixedChildren() {
        let leaves = fixedLeaves(64)
        let engine = LayoutEngine(layout: VStack(), subviews: leaves)
        runPass(engine.makeLayoutComputer())

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            engine.update(layout: VStack(), subviews: leaves)
            runPass(engine.makeLayoutComputer())
        }
    }

    // MARK: - VStack · Flexible children

    func testVStackInitialLayout_16_FlexibleChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: VStack(), subviews: mixedLeaves(16))
            runPass(engine.makeLayoutComputer())
        }
    }

    func testVStackInitialLayout_64_FlexibleChildren() {
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: Self.measureOptions) {
            let engine = LayoutEngine(layout: VStack(), subviews: mixedLeaves(64))
            runPass(engine.makeLayoutComputer())
        }
    }
}
#endif
