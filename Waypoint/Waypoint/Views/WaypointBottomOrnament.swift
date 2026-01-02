//
//  WaypointBottomOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Bottom Ornament

/// Bottom floating ornament - skinny horizontal bar for constellation quick-switch
/// Tap any constellation orb to filter to that group
struct WaypointBottomOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            // "All" option
            ConstellationPill(
                name: "All",
                icon: "square.grid.2x2",
                color: .secondary,
                isSelected: navigationState.filterOption == .all,
                action: {
                    navigationState.filterOption = .all
                    navigationState.selectedConstellationID = nil
                }
            )

            // Constellation pills
            ForEach(constellationManager.constellations) { constellation in
                ConstellationPill(
                    name: constellation.name,
                    icon: constellation.icon,
                    color: constellation.color,
                    isSelected: isConstellation(constellation),
                    action: {
                        navigationState.selectConstellation(constellation)
                    }
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassBackgroundEffect()
    }

    // MARK: - Helpers

    private func isConstellation(_ constellation: Constellation) -> Bool {
        if case .constellation(let id) = navigationState.filterOption {
            return id == constellation.id
        }
        return false
    }
}

// MARK: - Constellation Pill

private struct ConstellationPill: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // Small orb indicator
                ZStack {
                    Circle()
                        .fill(color.opacity(isSelected ? 0.4 : 0.2))
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? color : .secondary)
                }

                // Label (shows on hover or when selected)
                if isHovering || isSelected {
                    Text(name)
                        .font(.caption)
                        .fontWeight(isSelected ? .medium : .regular)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .padding(.horizontal, isHovering || isSelected ? 8 : 4)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.15) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        WaypointBottomOrnament()
    }
    .environment(NavigationState())
    .environment(ConstellationManager())
    .padding()
}

#endif
