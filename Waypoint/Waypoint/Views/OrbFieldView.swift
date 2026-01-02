//
//  OrbFieldView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbFieldView: View {

    // MARK: - Properties

    let portals: [Portal]
    let layoutMode: OrbLayoutEngine.Layout
    /// The active constellation's color (used when colorMode is .constellation)
    var constellationColor: Color? = nil
    let onOpen: (Portal) -> Void

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            let needsScroll = layoutMode == .linear && OrbLayoutEngine.needsScroll(count: portals.count, in: proxy.size)
            let orientation = OrbLayoutEngine.orientation(for: proxy.size)

            if portals.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if needsScroll {
                // Scrollable linear layout
                scrollableOrbField(size: proxy.size, orientation: orientation)
            } else {
                // Standard positioned layout
                standardOrbField(size: proxy.size)
            }
        }
        .frame(minHeight: 200)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Standard Orb Field

    @ViewBuilder
    private func standardOrbField(size: CGSize) -> some View {
        let positions = OrbLayoutEngine.positions(
            count: portals.count,
            in: size,
            layout: layoutMode
        )

        ZStack {
            ForEach(Array(portals.enumerated()), id: \.element.id) { index, portal in
                PortalOrbView(
                    portal: portal,
                    constellationColor: constellationColor,
                    onOpen: { onOpen(portal) }
                )
                .position(positions[safe: index] ?? .zero)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Scrollable Orb Field (for Linear with many orbs)

    @ViewBuilder
    private func scrollableOrbField(size: CGSize, orientation: OrbLayoutEngine.Orientation) -> some View {
        let orbSize: CGFloat = 70
        let spacing: CGFloat = 10

        if orientation == .horizontal {
            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(portals) { portal in
                        PortalOrbView(
                            portal: portal,
                            constellationColor: constellationColor,
                            onOpen: { onOpen(portal) }
                        )
                        .frame(width: orbSize, height: orbSize)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: size.height)
            }
        } else {
            // Vertical scroll
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: spacing) {
                    ForEach(portals) { portal in
                        PortalOrbView(
                            portal: portal,
                            constellationColor: constellationColor,
                            onOpen: { onOpen(portal) }
                        )
                        .frame(width: orbSize, height: orbSize)
                    }
                }
                .padding(.vertical, 20)
                .frame(width: size.width)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No portals yet")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Safe Indexing

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    OrbFieldView(portals: Portal.samples, layoutMode: .auto, onOpen: { _ in })
        .padding()
}
