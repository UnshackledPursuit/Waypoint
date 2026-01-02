//
//  WaypointBottomOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Bottom Ornament

/// Bottom floating ornament for contextual controls
/// Shows sort picker for List tab, layout picker for Orb tab
struct WaypointBottomOrnament: View {

    // MARK: - Properties

    let selectedTab: WaypointApp.AppTab
    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @ObservedObject var orbSceneState: OrbSceneState

    // MARK: - Body

    var body: some View {
        Group {
            switch selectedTab {
            case .list:
                listControls
            case .orb:
                orbControls
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassBackgroundEffect()
    }

    // MARK: - List Controls

    private var listControls: some View {
        @Bindable var navState = navigationState

        return HStack(spacing: 12) {
            // Sort picker
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Picker("Sort", selection: $navState.sortOrder) {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .tint(.primary)
        }
    }

    // MARK: - Orb Controls

    private var orbControls: some View {
        HStack(spacing: 16) {
            // Layout picker
            HStack(spacing: 8) {
                Image(systemName: "square.grid.3x3")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Picker("Layout", selection: $orbSceneState.layoutMode) {
                    ForEach(OrbLayoutEngine.Layout.allCases, id: \.self) { layout in
                        Text(layout.rawValue)
                            .tag(layout)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(.primary)
            }

            Divider()
                .frame(height: 20)

            // Constellation picker
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Picker("Constellation", selection: $orbSceneState.selectedConstellationID) {
                    Text("All Portals").tag(nil as UUID?)

                    ForEach(constellationManager.constellations) { constellation in
                        Label(constellation.name, systemImage: constellation.icon)
                            .tag(constellation.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(.primary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        WaypointBottomOrnament(
            selectedTab: .list,
            orbSceneState: OrbSceneState()
        )

        WaypointBottomOrnament(
            selectedTab: .orb,
            orbSceneState: OrbSceneState()
        )
    }
    .environment(NavigationState())
    .environment(ConstellationManager())
    .padding()
}

#endif
