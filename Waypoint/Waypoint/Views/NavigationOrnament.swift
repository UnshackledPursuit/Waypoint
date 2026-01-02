//
//  NavigationOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

// MARK: - Navigation Ornament

/// Left-side ornament for constellation and filter selection
/// Works across both List and Orb tabs
struct NavigationOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager

    @State private var isExpanded = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            // Filter buttons
            filterSection

            Divider()
                .frame(width: 40)
                .padding(.vertical, 4)

            // Constellation section
            constellationSection
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: 6) {
            NavigationOrnamentButton(
                icon: "square.grid.2x2",
                label: "All",
                isSelected: navigationState.filterOption == .all
            ) {
                navigationState.filterOption = .all
                navigationState.selectedConstellationID = nil
            }

            NavigationOrnamentButton(
                icon: "pin.fill",
                label: "Pinned",
                isSelected: navigationState.filterOption == .pinned
            ) {
                navigationState.filterOption = .pinned
            }
        }
    }

    // MARK: - Constellation Section

    private var constellationSection: some View {
        VStack(spacing: 6) {
            // Constellation header with expand toggle
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                    if isExpanded {
                        Text("Constellations")
                            .font(.caption)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            if isExpanded {
                constellationList
            }
        }
    }

    private var constellationList: some View {
        VStack(spacing: 4) {
            ForEach(constellationManager.constellations) { constellation in
                NavigationOrnamentButton(
                    icon: constellation.icon,
                    label: constellation.name,
                    color: constellation.color,
                    isSelected: isConstellationSelected(constellation)
                ) {
                    navigationState.selectConstellation(constellation)
                }
            }

            if constellationManager.constellations.isEmpty {
                Text("No constellations")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Helpers

    private func isConstellationSelected(_ constellation: Constellation) -> Bool {
        if case .constellation(let id) = navigationState.filterOption {
            return id == constellation.id
        }
        return navigationState.selectedConstellationID == constellation.id
    }
}

// MARK: - Ornament Button

private struct NavigationOrnamentButton: View {
    let icon: String
    let label: String
    var color: Color = .primary
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon orb
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.3) : Color.clear)
                        .frame(width: 32, height: 32)

                    if isSelected {
                        Circle()
                            .stroke(color.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? color : .secondary)
                }

                // Label (shows on hover or when selected)
                if isHovering || isSelected {
                    Text(label)
                        .font(.caption)
                        .fontWeight(isSelected ? .medium : .regular)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isHovering ? Color.primary.opacity(0.05) : Color.clear)
            )
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
    NavigationOrnament()
        .environment(NavigationState())
        .environment(ConstellationManager())
        .padding()
        .frame(width: 200)
}
