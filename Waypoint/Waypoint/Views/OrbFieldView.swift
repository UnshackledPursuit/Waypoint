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
    let onOpen: (Portal) -> Void

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            let positions = OrbLayoutEngine.positions(
                count: portals.count,
                in: proxy.size,
                layout: layoutMode
            )

            ZStack {
                if portals.isEmpty {
                    emptyState
                } else {
                    ForEach(Array(portals.enumerated()), id: \.element.id) { index, portal in
                        PortalOrbView(portal: portal) {
                            onOpen(portal)
                        }
                            .position(positions[safe: index] ?? .zero)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 320)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
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
