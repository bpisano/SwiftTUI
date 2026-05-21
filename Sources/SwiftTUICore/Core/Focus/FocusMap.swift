//
//  FocusMap.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry

public struct FocusMap: Sendable {
    private let orderedIDs: [FocusNodeID]
    private let nodes: [FocusNodeID: FocusableNode]
    private let groups: [FocusNodeID: [FocusNodeID]]
    private let nodeToGroup: [FocusNodeID: FocusNodeID]
    private let edges: [FocusNodeID: [Direction: FocusNodeID]]

    public var isEmpty: Bool { orderedIDs.isEmpty }

    public var firstNode: FocusNodeID? {
        orderedIDs.first { nodes[$0]?.isEnabled == true }
    }

    public var lastNode: FocusNodeID? {
        orderedIDs.last { nodes[$0]?.isEnabled == true }
    }

    public init(list: FocusList) {
        var orderedIDs: [FocusNodeID] = []
        var nodes: [FocusNodeID: FocusableNode] = [:]
        var groups: [FocusNodeID: [FocusNodeID]] = [:]
        var nodeToGroup: [FocusNodeID: FocusNodeID] = [:]

        Self.walk(
            list,
            orderedIDs: &orderedIDs,
            nodes: &nodes,
            groups: &groups,
            nodeToGroup: &nodeToGroup,
            currentGroup: nil
        )

        let enabledNodes = orderedIDs.compactMap { nodes[$0] }.filter { $0.isEnabled }
        var edges: [FocusNodeID: [Direction: FocusNodeID]] = [:]
        for node in enabledNodes {
            var dirs: [Direction: FocusNodeID] = [:]
            for direction in [Direction.up, .down, .left, .right] {
                if let nearest = Self.nearest(from: node, in: direction, among: enabledNodes) {
                    dirs[direction] = nearest
                }
            }
            edges[node.id] = dirs
        }

        self.orderedIDs = orderedIDs
        self.nodes = nodes
        self.groups = groups
        self.nodeToGroup = nodeToGroup
        self.edges = edges
    }

    public func contains(_ id: FocusNodeID) -> Bool {
        nodes[id] != nil
    }

    public func node(for id: FocusNodeID) -> FocusableNode? {
        nodes[id]
    }

    public func nextFocus(from current: FocusNodeID, in direction: Direction) -> FocusNodeID? {
        edges[current]?[direction]
    }

    public func nextFocus(from current: FocusNodeID, in direction: TabDirection) -> FocusNodeID? {
        let scope = tabScope(for: current)
        guard !scope.isEmpty, let idx = scope.firstIndex(of: current) else { return nil }
        let nextIdx: Int
        switch direction {
        case .next:
            nextIdx = (idx + 1) % scope.count
        case .previous:
            nextIdx = (idx - 1 + scope.count) % scope.count
        }
        return scope[nextIdx]
    }

    private func tabScope(for current: FocusNodeID) -> [FocusNodeID] {
        if let groupID = nodeToGroup[current], let ids = groups[groupID] {
            return ids.filter { nodes[$0]?.isEnabled == true }
        }
        return orderedIDs.filter { nodes[$0]?.isEnabled == true }
    }

    // MARK: - Walk

    private static func walk(
        _ list: FocusList,
        orderedIDs: inout [FocusNodeID],
        nodes: inout [FocusNodeID: FocusableNode],
        groups: inout [FocusNodeID: [FocusNodeID]],
        nodeToGroup: inout [FocusNodeID: FocusNodeID],
        currentGroup: FocusNodeID?
    ) {
        for item in list.items {
            switch item {
            case .node(let node):
                orderedIDs.append(node.id)
                nodes[node.id] = node
                if let g = currentGroup {
                    groups[g, default: []].append(node.id)
                    nodeToGroup[node.id] = g
                }
            case .list(let sublist):
                walk(
                    sublist,
                    orderedIDs: &orderedIDs,
                    nodes: &nodes,
                    groups: &groups,
                    nodeToGroup: &nodeToGroup,
                    currentGroup: currentGroup
                )
            case .group(let group):
                if groups[group.id] == nil {
                    groups[group.id] = []
                }
                walk(
                    group.children,
                    orderedIDs: &orderedIDs,
                    nodes: &nodes,
                    groups: &groups,
                    nodeToGroup: &nodeToGroup,
                    currentGroup: group.id
                )
            }
        }
    }

    // MARK: - Spatial

    private static func isCandidate(
        _ other: FocusableNode,
        from node: FocusableNode,
        in direction: Direction
    ) -> Bool {
        switch direction {
        case .up: return other.frame.maxY <= node.frame.minY
        case .down: return other.frame.minY >= node.frame.maxY
        case .left: return other.frame.maxX <= node.frame.minX
        case .right: return other.frame.minX >= node.frame.maxX
        }
    }

    private static func cost(
        _ other: FocusableNode,
        from node: FocusableNode,
        in direction: Direction
    ) -> Double {
        let primary: Double
        let secondary: Double
        switch direction {
        case .up:
            primary = node.frame.minY - other.frame.maxY
            secondary = abs(other.frame.midX - node.frame.midX)
        case .down:
            primary = other.frame.minY - node.frame.maxY
            secondary = abs(other.frame.midX - node.frame.midX)
        case .left:
            primary = node.frame.minX - other.frame.maxX
            secondary = abs(other.frame.midY - node.frame.midY)
        case .right:
            primary = other.frame.minX - node.frame.maxX
            secondary = abs(other.frame.midY - node.frame.midY)
        }
        return primary + secondary * 2
    }

    private static func nearest(
        from node: FocusableNode,
        in direction: Direction,
        among nodes: [FocusableNode]
    ) -> FocusNodeID? {
        let candidates = nodes.filter {
            $0.id != node.id && isCandidate($0, from: node, in: direction)
        }
        guard !candidates.isEmpty else { return nil }
        return candidates.min { lhs, rhs in
            cost(lhs, from: node, in: direction) < cost(rhs, from: node, in: direction)
        }?.id
    }
}

extension FocusMap {
    public enum Direction: Sendable {
        case up
        case down
        case left
        case right
    }

    public enum TabDirection: Sendable {
        case next
        case previous
    }
}
