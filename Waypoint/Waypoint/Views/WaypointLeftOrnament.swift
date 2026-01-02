//
//  WaypointLeftOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Left Ornament

/// Left-side floating ornament for tab switching, filters, and constellations
/// Modeled after Apple Photos app ornament pattern
struct WaypointLeftOrnament: View {

    // MARK: - Properties

    @Binding var selectedTab: WaypointApp.AppTab
    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager

    @State private var isConstellationsExpanded = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Tab section
            tabSection

            Divider()
                .frame(width: 32)
                .padding(.vertical, 8)

            // Filter section
            filterSection

            // Constellation section (expandable)
            if !constellationManager.constellations.isEmpty {
                Divider()
                    .frame(width: 32)
                    .padding(.vertical, 8)

                constellationSection
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .glassBackgroundEffect()
    }

    // MARK: - Tab Section

    private var tabSection: some View {
        VStack(spacing: 4) {
            OrnamentIconButton(
                icon: "list.bullet",
                isSelected: selectedTab == .list,
                action: { selectedTab = .list }
            )

            OrnamentIconButton(
                icon: "sparkles",
                isSelected: selectedTab == .orb,
                action: { selectedTab = .orb }
            )
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: 4) {
            OrnamentIconButton(
                icon: "square.grid.2x2",
                isSelected: navigationState.filterOption == .all,
                action: {
                    navigationState.filterOption = .all
                    navigationState.selectedConstellationID = nil
                }
            )

            OrnamentIconButton(
                icon: "pin.fill",
                isSelected: navigationState.filterOption == .pinned,
                action: {
                    navigationState.filterOption = .pinned
                }
            )
        }
    }

    // MARK: - Constellation Section

    private var constellationSection: some View {
        VStack(spacing: 4) {
            // Expand/collapse toggle
            OrnamentIconButton(
                icon: isConstellationsExpanded ? "star.fill" : "star",
                isSelected: isConstellationSelected,
                action: {
                    withAnimation(.spring(response: 0.3)) {
                        isConstellationsExpanded.toggle()
                    }
                }
            )

            // Constellation list (when expanded)
            if isConstellationsExpanded {
                constellationList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var constellationList: some View {
        VStack(spacing: 4) {
            ForEach(constellationManager.constellations) { constellation in
                OrnamentIconButton(
                    icon: constellation.icon,
                    color: constellation.color,
                    isSelected: isConstellation(constellation),
                    action: {
                        navigationState.selectConstellation(constellation)
                    }
                )
            }
        }
    }

    // MARK: - Helpers

    private var isConstellationSelected: Bool {
        if case .constellation = navigationState.filterOption {
            return true
        }
        return false
    }

    private func isConstellation(_ constellation: Constellation) -> Bool {
        if case .constellation(let id) = navigationState.filterOption {
            return id == constellation.id
        }
        return false
    }
}

// MARK: - Ornament Icon Button

private struct OrnamentIconButton: View {
    let icon: String
    var color: Color = .primary
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                Circle()
                    .fill(isSelected ? color.opacity(0.25) : Color.clear)
                    .frame(width: 44, height: 44)

                // Selection ring
                if isSelected {
                    Circle()
                        .stroke(color.opacity(0.6), lineWidth: 2)
                        .frame(width: 44, height: 44)
                }

                // Hover highlight
                if isHovering && !isSelected {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                }

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? color : .secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WaypointLeftOrnament(selectedTab: .constant(.list))
        .environment(NavigationState())
        .environment(ConstellationManager())
        .padding()
}

#endif
