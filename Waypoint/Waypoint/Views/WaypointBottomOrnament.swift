//
//  WaypointBottomOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Bottom Ornament

/// Bottom floating ornament - filters and constellations
/// Contains: All/Pinned | Constellations (scrollable) | Launch
struct WaypointBottomOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    @State private var constellationToEdit: Constellation?

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    private var isMonoMode: Bool {
        OrbColorMode(rawValue: orbColorModeRaw) == .mono
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            // Filters
            filterSection

            pillDivider

            // Scrollable Constellations
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(constellationManager.constellations) { constellation in
                        ConstellationPill(
                            constellation: constellation,
                            isSelected: isConstellation(constellation),
                            isMonoMode: isMonoMode,
                            onTap: {
                                navigationState.selectConstellation(constellation)
                            },
                            onEdit: {
                                constellationToEdit = constellation
                            },
                            onLaunch: {
                                launchConstellation(constellation)
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(maxWidth: 350)

            // Launch All (only when constellation selected)
            if selectedConstellation != nil {
                launchAllPill
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassBackgroundEffect()
        .sheet(item: $constellationToEdit) { constellation in
            EditConstellationView(constellation: constellation)
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        HStack(spacing: 4) {
            CompactPillButton(
                icon: "square.grid.2x2",
                isSelected: navigationState.filterOption == .all,
                action: {
                    navigationState.filterOption = .all
                    navigationState.selectedConstellationID = nil
                }
            )

            CompactPillButton(
                icon: "pin.fill",
                isSelected: navigationState.filterOption == .pinned,
                action: {
                    navigationState.filterOption = .pinned
                }
            )
        }
    }

    // MARK: - Launch All Pill

    private var launchAllPill: some View {
        let pillColor = isMonoMode ? Color.secondary : (selectedConstellation?.color ?? .blue)
        return Button {
            if let constellation = selectedConstellation {
                launchConstellation(constellation)
            }
        } label: {
            ZStack {
                Circle()
                    .fill(pillColor.opacity(0.8))
                    .frame(width: 36, height: 36)

                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Divider

    private var pillDivider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(width: 1, height: 28)
            .padding(.horizontal, 4)
    }

    // MARK: - Helpers

    private var selectedConstellationID: UUID? {
        if case .constellation(let id) = navigationState.filterOption {
            return id
        }
        return nil
    }

    private var selectedConstellation: Constellation? {
        guard let id = selectedConstellationID else { return nil }
        return constellationManager.constellation(withID: id)
    }

    private func isConstellation(_ constellation: Constellation) -> Bool {
        if case .constellation(let id) = navigationState.filterOption {
            return id == constellation.id
        }
        return false
    }

    // MARK: - Actions

    private func launchConstellation(_ constellation: Constellation) {
        for (index, portalID) in constellation.portalIDs.enumerated() {
            if let portal = portalManager.portal(withID: portalID),
               let url = URL(string: portal.url) {
                let delay = Double(index) * constellation.launchDelay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    UIApplication.shared.open(url)
                    portalManager.updateLastOpened(portal)
                }
            }
        }
        print("🚀 Launched constellation: \(constellation.name)")
    }
}

// MARK: - Compact Pill Button

private struct CompactPillButton: View {
    let icon: String
    var isSelected: Bool = false
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.25) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
                    .frame(width: 36, height: 36)

                if isSelected {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 36, height: 36)
                }

                Image(systemName: icon)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
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

// MARK: - Constellation Pill

private struct ConstellationPill: View {
    let constellation: Constellation
    let isSelected: Bool
    var isMonoMode: Bool = false
    let onTap: () -> Void
    let onEdit: () -> Void
    let onLaunch: () -> Void

    @State private var isHovering = false

    /// Effective color - grayscale in mono mode
    private var effectiveColor: Color {
        isMonoMode ? .secondary : constellation.color
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                // Small orb
                ZStack {
                    Circle()
                        .fill(effectiveColor.opacity(isSelected ? 0.5 : 0.3))
                        .frame(width: 28, height: 28)

                    if isSelected {
                        Circle()
                            .stroke(effectiveColor, lineWidth: 2)
                            .frame(width: 28, height: 28)
                    }

                    Image(systemName: constellation.icon)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? effectiveColor : .secondary)
                }

                // Label on hover or selected
                if isHovering || isSelected {
                    Text(constellation.name)
                        .font(.caption)
                        .fontWeight(isSelected ? .medium : .regular)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding(.horizontal, isHovering || isSelected ? 8 : 4)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isSelected ? effectiveColor.opacity(0.2) : (isHovering ? Color.white.opacity(0.08) : Color.clear))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }

            Button {
                onLaunch()
            } label: {
                Label("Launch All", systemImage: "arrow.up.right.square")
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Preview

#Preview {
    WaypointBottomOrnament()
        .environment(NavigationState())
        .environment(ConstellationManager())
        .environment(PortalManager())
        .padding()
}

#endif
