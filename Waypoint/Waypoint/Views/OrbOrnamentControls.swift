//
//  OrbOrnamentControls.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbOrnamentControls: View {

    // MARK: - Properties

    enum Layout {
        case vertical
        case horizontal
    }

    enum LabelStyle {
        case always
        case hoverReveal
    }

    @Binding var selectedConstellationID: UUID?
    @Binding var layoutMode: OrbLayoutEngine.Layout
    let constellations: [Constellation]
    var layout: Layout = .vertical
    var labelStyle: LabelStyle = .always

    // MARK: - Body

    var body: some View {
        Group {
            switch layout {
            case .vertical:
                VStack(spacing: 8) {
                    constellationMenu
                    layoutMenu
                }
            case .horizontal:
                HStack(spacing: 8) {
                    constellationMenu
                    layoutMenu
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Menus

    private var constellationMenu: some View {
        Menu {
            Button {
                selectedConstellationID = nil
            } label: {
                Label("All", systemImage: "circle.grid.3x3.fill")
            }

            ForEach(constellations) { constellation in
                Button {
                    selectedConstellationID = constellation.id
                } label: {
                    Label(constellation.name, systemImage: constellation.icon)
                }
            }
        } label: {
            OrbOrnamentLabel(
                title: constellationLabel,
                systemImage: constellationIcon,
                style: labelStyle
            )
        }
        .buttonStyle(.bordered)
    }

    private var layoutMenu: some View {
        Menu {
            ForEach(OrbLayoutEngine.Layout.allCases, id: \.self) { layout in
                Button {
                    layoutMode = layout
                } label: {
                    Label(layout.rawValue, systemImage: layoutMode == layout ? "checkmark" : "circle")
                }
            }
        } label: {
            OrbOrnamentLabel(
                title: "Layout",
                systemImage: "square.grid.2x2",
                style: labelStyle
            )
        }
        .buttonStyle(.bordered)
    }

    // MARK: - Helpers

    private var constellationLabel: String {
        guard let selected = selectedConstellation else {
            return "All"
        }
        return selected.name
    }

    private var constellationIcon: String {
        guard let selected = selectedConstellation else {
            return "circle.grid.3x3.fill"
        }
        return selected.icon
    }

    private var selectedConstellation: Constellation? {
        guard let selectedConstellationID else { return nil }
        return constellations.first { $0.id == selectedConstellationID }
    }
}

// MARK: - Label

private struct OrbOrnamentLabel: View {
    let title: String
    let systemImage: String
    let style: OrbOrnamentControls.LabelStyle
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            if style == .always || isHovering {
                Text(title)
                    .lineLimit(1)
            }
        }
        .onHover { isHovering = $0 }
    }
}

// MARK: - Preview

#Preview {
    OrbOrnamentControls(
        selectedConstellationID: .constant(Constellation.sample.id),
        layoutMode: .constant(.auto),
        constellations: Constellation.samples,
        layout: .horizontal,
        labelStyle: .hoverReveal
    )
    .padding()
}
