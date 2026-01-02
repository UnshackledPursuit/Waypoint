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

    // Micro-action callbacks (passed through to OrbLinearField)
    var onEdit: ((Portal) -> Void)? = nil
    var onDelete: ((Portal) -> Void)? = nil
    var onTogglePin: ((Portal) -> Void)? = nil
    var onToggleConstellation: ((Portal, Constellation) -> Void)? = nil
    var allConstellations: [Constellation] = []
    var constellationIDsForPortal: ((Portal) -> Set<UUID>)? = nil
    var onCreateConstellation: ((Portal) -> Void)? = nil

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
                onOpen: onOpen,
                onEdit: onEdit,
                onDelete: onDelete,
                onTogglePin: onTogglePin,
                onToggleConstellation: onToggleConstellation,
                allConstellations: allConstellations,
                constellationIDsForPortal: constellationIDsForPortal,
                onCreateConstellation: onCreateConstellation
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
