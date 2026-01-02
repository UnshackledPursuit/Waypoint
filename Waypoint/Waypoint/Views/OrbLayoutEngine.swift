//
//  OrbLayoutEngine.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import CoreGraphics

// MARK: - Orb Layout Engine

enum OrbLayoutEngine {

    enum Layout: String, CaseIterable {
        case auto = "Auto"
        case linear = "Linear"
        case arc = "Arc"
        case spiral = "Spiral"
        case hemisphere = "Hemisphere"
    }

    /// Returns the orientation based on window dimensions
    enum Orientation {
        case vertical
        case horizontal
    }

    static func orientation(for size: CGSize) -> Orientation {
        // If width is significantly greater than height (aspect ratio > 1.5), go horizontal
        return size.width > size.height * 1.3 ? .horizontal : .vertical
    }

    /// Check if scrolling is needed for linear layout
    static func needsScroll(count: Int, in size: CGSize, orbSize: CGFloat = 80) -> Bool {
        let orientation = orientation(for: size)
        let spacing = orbSize + 10
        let totalNeeded = CGFloat(count) * spacing
        if orientation == .vertical {
            return totalNeeded > size.height
        } else {
            return totalNeeded > size.width
        }
    }

    /// Calculate content size for scrolling
    static func contentSize(count: Int, in size: CGSize, orbSize: CGFloat = 80) -> CGSize {
        let orientation = orientation(for: size)
        let spacing = orbSize + 10
        let totalNeeded = CGFloat(count) * spacing + 40 // padding
        if orientation == .vertical {
            return CGSize(width: size.width, height: max(totalNeeded, size.height))
        } else {
            return CGSize(width: max(totalNeeded, size.width), height: size.height)
        }
    }

    static func positions(
        count: Int,
        in size: CGSize,
        layout: Layout
    ) -> [CGPoint] {
        guard count > 0 else { return [] }
        let resolved = resolveLayout(layout, count: count, in: size)
        switch resolved {
        case .linear:
            return linearPositions(count: count, in: size)
        case .arc:
            return arcPositions(count: count, in: size)
        case .spiral:
            return spiralPositions(count: count, in: size)
        case .hemisphere:
            return hemispherePositions(count: count, in: size)
        case .auto:
            return linearPositions(count: count, in: size)
        }
    }

    // MARK: - Layout Resolution

    private static func resolveLayout(_ layout: Layout, count: Int, in size: CGSize) -> Layout {
        guard layout == .auto else { return layout }
        switch count {
        case 0...6:
            return .linear
        case 7...14:
            return .arc
        case 15...30:
            return .spiral
        default:
            return .hemisphere
        }
    }

    // MARK: - Layout Implementations

    /// Linear layout that auto-adapts to vertical or horizontal based on window dimensions
    private static func linearPositions(count: Int, in size: CGSize) -> [CGPoint] {
        let orientation = orientation(for: size)

        if orientation == .horizontal {
            // Horizontal linear layout
            let spacing = min(90.0, size.width / CGFloat(max(count, 1)) * 0.8)
            let startX = (size.width - spacing * CGFloat(count - 1)) / 2.0
            let centerY = size.height / 2.0
            return (0..<count).map { index in
                CGPoint(x: startX + spacing * CGFloat(index), y: centerY)
            }
        } else {
            // Vertical linear layout (default)
            let spacing = min(90.0, size.height / CGFloat(max(count, 1)) * 0.8)
            let startY = (size.height - spacing * CGFloat(count - 1)) / 2.0
            let centerX = size.width / 2.0
            return (0..<count).map { index in
                CGPoint(x: centerX, y: startY + spacing * CGFloat(index))
            }
        }
    }

    private static func arcPositions(count: Int, in size: CGSize) -> [CGPoint] {
        let radius = min(size.width, size.height) * 0.35
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let startAngle = -CGFloat.pi * 0.75
        let endAngle = -CGFloat.pi * 0.25
        let step = count > 1 ? (endAngle - startAngle) / CGFloat(count - 1) : 0
        return (0..<count).map { index in
            let angle = startAngle + step * CGFloat(index)
            return CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
        }
    }

    private static func spiralPositions(count: Int, in size: CGSize) -> [CGPoint] {
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let maxRadius = min(size.width, size.height) * 0.4
        let angleStep = CGFloat.pi * 0.4
        return (0..<count).map { index in
            let progress = CGFloat(index) / CGFloat(max(count - 1, 1))
            let radius = maxRadius * progress
            let angle = angleStep * CGFloat(index)
            return CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
        }
    }

    private static func hemispherePositions(count: Int, in size: CGSize) -> [CGPoint] {
        let center = CGPoint(x: size.width / 2.0, y: size.height * 0.55)
        let radius = min(size.width, size.height) * 0.45
        let startAngle = CGFloat.pi
        let endAngle = 0.0
        let step = count > 1 ? (endAngle - startAngle) / CGFloat(count - 1) : 0
        return (0..<count).map { index in
            let angle = startAngle + step * CGFloat(index)
            return CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
        }
    }
}
