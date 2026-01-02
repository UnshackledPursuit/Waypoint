//
//  OrbLinearField.swift
//  Waypoint
//
//  Created on January 2, 2026.
//

import SwiftUI

// MARK: - Orb Linear Field

/// A simple, reliable orb layout using standard SwiftUI layout primitives.
/// - Uses VStack (portrait) or HStack (landscape) based on aspect ratio
/// - Scrolls automatically when orbs exceed available space
/// - No complex positioning math - just SwiftUI doing what it does best
struct OrbLinearField: View {

    // MARK: - Properties

    let portals: [Portal]
    /// The active constellation's color (used when colorMode is .constellation)
    var constellationColor: Color? = nil
    let onOpen: (Portal) -> Void

    // MARK: - Layout Constants

    /// Size of each orb (the PortalOrbView has internal padding for glow)
    private let orbSize: CGFloat = 64
    /// Spacing between orbs
    private let orbSpacing: CGFloat = 16
    /// Padding around the scroll content
    private let contentPadding: CGFloat = 24

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height * 1.3

            Group {
                if portals.isEmpty {
                    emptyState
                } else if isLandscape {
                    horizontalLayout(containerSize: proxy.size)
                } else {
                    verticalLayout(containerSize: proxy.size)
                }
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 200)
    }

    // MARK: - Vertical Layout (Portrait)

    private func verticalLayout(containerSize: CGSize) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: orbSpacing) {
                ForEach(portals) { portal in
                    PortalOrbView(
                        portal: portal,
                        constellationColor: constellationColor,
                        size: orbSize,
                        onOpen: { onOpen(portal) }
                    )
                }
            }
            .padding(contentPadding)
            .frame(minHeight: containerSize.height)
        }
        .frame(width: containerSize.width)
    }

    // MARK: - Horizontal Layout (Landscape)

    private func horizontalLayout(containerSize: CGSize) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: orbSpacing) {
                ForEach(portals) { portal in
                    PortalOrbView(
                        portal: portal,
                        constellationColor: constellationColor,
                        size: orbSize,
                        onOpen: { onOpen(portal) }
                    )
                }
            }
            .padding(contentPadding)
            .frame(minWidth: containerSize.width)
        }
        .frame(height: containerSize.height)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)

            Text("No portals")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Drop links here or select a constellation")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview("Few Portals - Vertical") {
    OrbLinearField(
        portals: Array(Portal.samples.prefix(3)),
        onOpen: { _ in }
    )
    .frame(width: 300, height: 500)
    .padding()
}

#Preview("Many Portals - Vertical Scroll") {
    OrbLinearField(
        portals: Portal.samples,
        onOpen: { _ in }
    )
    .frame(width: 300, height: 400)
    .padding()
}

#Preview("Landscape - Horizontal") {
    OrbLinearField(
        portals: Portal.samples,
        onOpen: { _ in }
    )
    .frame(width: 600, height: 250)
    .padding()
}

#Preview("Empty State") {
    OrbLinearField(
        portals: [],
        onOpen: { _ in }
    )
    .frame(width: 300, height: 400)
    .padding()
}
