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
/// Long-press for Edit/Launch All context menu
struct WaypointBottomOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    @State private var constellationToEdit: Constellation?

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
                },
                contextMenuItems: nil
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
                    },
                    contextMenuItems: {
                        Button {
                            constellationToEdit = constellation
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button {
                            launchConstellation(constellation)
                        } label: {
                            Label("Launch All", systemImage: "arrow.up.right.square")
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassBackgroundEffect()
        .sheet(item: $constellationToEdit) { constellation in
            EditConstellationView(constellation: constellation)
        }
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

    // MARK: - Helpers

    private func isConstellation(_ constellation: Constellation) -> Bool {
        if case .constellation(let id) = navigationState.filterOption {
            return id == constellation.id
        }
        return false
    }
}

// MARK: - Constellation Pill

private struct ConstellationPill<MenuContent: View>: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    let contextMenuItems: (() -> MenuContent)?

    @State private var isHovering = false

    init(
        name: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder contextMenuItems: @escaping () -> MenuContent
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
        self.contextMenuItems = contextMenuItems
    }

    var body: some View {
        Button(action: action) {
            pillContent
        }
        .buttonStyle(.plain)
        .if(contextMenuItems != nil) { view in
            view.contextMenu {
                if let menuItems = contextMenuItems {
                    menuItems()
                }
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    private var pillContent: some View {
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
}

// Convenience init for nil context menu
extension ConstellationPill where MenuContent == EmptyView {
    init(
        name: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void,
        contextMenuItems: (() -> MenuContent)?
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.action = action
        self.contextMenuItems = nil
    }
}

// MARK: - View Extension for conditional modifier

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
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
    .environment(PortalManager())
    .padding()
}

#endif
