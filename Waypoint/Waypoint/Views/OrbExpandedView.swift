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
    var icon: String? = nil
    var headerColor: Color = .secondary
    let portals: [Portal]
    var constellationColor: Color? = nil
    var constellationColorForPortal: ((Portal) -> Color?)? = nil
    var constellationSections: [ConstellationSection]? = nil
    /// When true, hide the title and only show the icon (for narrow views)
    var isCompact: Bool = false
    let onBack: () -> Void
    let onOpen: (Portal) -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            OrbTopBar(
                title: title,
                icon: icon,
                color: headerColor,
                onBack: onBack,
                trailing: nil,
                isCompact: isCompact
            )

            OrbLinearField(
                portals: portals,
                constellationColor: constellationColor,
                constellationColorForPortal: constellationColorForPortal,
                constellationSections: constellationSections,
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
        onBack: {},
        onOpen: { _ in }
    )
    .padding()
}
