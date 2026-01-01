//
//  PortalOrbView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct PortalOrbView: View {

    // MARK: - Properties

    let portal: Portal
    let onOpen: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onOpen) {
            VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 64, height: 64)

                Text(portal.name.prefix(1).uppercased())
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Text(portal.name)
                .font(.caption)
                .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 90)
    }
}

// MARK: - Preview

#Preview {
    PortalOrbView(portal: Portal.sample, onOpen: {})
        .padding()
}
