//
//  HStackPerformanceTests.swift
//  SwiftTUI
//
//  XCTest performance benchmarks for the production HStack.
//  Each test measures one complete sizeThatFits + placeSubviews pass
//  (the hot path in every render cycle) across scenarios from light to heavy.
//
//  Scenarios span 4 → 1024 children to verify O(n) complexity:
//  if complexity is linear, doubling the child count should ~double the time.

#if canImport(XCTest)
import Foundation
import Geometry
import XCTest

@testable import SwiftTUICore

nonisolated final class HStackPerformanceTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private static let proposal = ProposedViewSize(width: 100_000, height: 50)
    @MainActor
    private static let bounds = Rect(origin: .zero, size: Size(width: 100_000, height: 50))

    @MainActor
    private func fixedSubview(width: GeometryUnit = 10, height: GeometryUnit = 5) -> LayoutProxy {
        let size = Size(width: width, height: height)
        let computer = LayoutComputer { _ in size } viewGeometries: { rect in
            [ViewGeometry(origin: rect.origin, size: size)]
        }
        return LayoutProxy(computerProvider: { computer }, place: { _ in })
    }

    @MainActor
    private func flexibleSubview(height: GeometryUnit = 5) -> LayoutProxy {
        let computer = LayoutComputer { p in
            Size(width: p.width ?? 100, height: height)
        } viewGeometries: { rect in
            [ViewGeometry(origin: rect.origin, size: Size(width: rect.width, height: height))]
        }
        return LayoutProxy(computerProvider: { computer }, place: { _ in })
    }

    @MainActor
    private func runPass(subviews: [LayoutProxy]) {
        var cache = HStack().makeCache(subviews: subviews)
        let hstack = HStack()
        _ = hstack.sizeThatFits(proposal: Self.proposal, subviews: subviews, cache: &cache)
        hstack.placeSubviews(in: Self.bounds, subviews: subviews, cache: &cache)
    }

    // MARK: - Fixed children (4 → 1024)

    @MainActor
    func testPerformance_4Fixed() {
        let subviews = (0..<4).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_16Fixed() {
        let subviews = (0..<16).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_64Fixed() {
        let subviews = (0..<64).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_128Fixed() {
        let subviews = (0..<128).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_256Fixed() {
        let subviews = (0..<256).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_512Fixed() {
        let subviews = (0..<512).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_1024Fixed() {
        let subviews = (0..<1024).map { _ in fixedSubview() }
        measure { runPass(subviews: subviews) }
    }

    // MARK: - Mixed children (25% flexible, 4 → 1024)

    @MainActor
    func testPerformance_16Mixed() {
        let subviews = (0..<12).map { _ in fixedSubview() }
                     + (0..<4).map  { _ in flexibleSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_64Mixed() {
        let subviews = (0..<48).map { _ in fixedSubview() }
                     + (0..<16).map { _ in flexibleSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_256Mixed() {
        let subviews = (0..<192).map { _ in fixedSubview() }
                     + (0..<64).map  { _ in flexibleSubview() }
        measure { runPass(subviews: subviews) }
    }

    @MainActor
    func testPerformance_1024Mixed() {
        let subviews = (0..<768).map  { _ in fixedSubview() }
                     + (0..<256).map  { _ in flexibleSubview() }
        measure { runPass(subviews: subviews) }
    }
}

#endif
