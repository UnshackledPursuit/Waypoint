//
//  OrbExpandedView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbExpandedView: View {

    // MARK: - Properties

    let title: String
    let portals: [Portal]
    @Binding var layoutMode: OrbLayoutEngine.Layout
    var constellationColor: Color? = nil
    let onBack: () -> Void
    let onOpen: (Portal) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            OrbTopBar(title: title, onBack: onBack, trailing: nil)

            OrbFieldView(
                portals: portals,
                layoutMode: layoutMode,
                constellationColor: constellationColor,
                onOpen: onOpen
            )
        }
    }
}

// MARK: - Preview

#Preview {
    OrbExpandedView(
        title: "Focus",
        portals: Portal.samples,
        layoutMode: .constant(.auto),
        onBack: {},
        onOpen: { _ in }
    )
    .padding()
}
