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
/// Auto-collapses to show only selected filter, expands on interaction
struct WaypointBottomOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    @State private var constellationToEdit: Constellation?

    /// Whether the ornament is expanded (showing all controls)
    @State private var isExpanded = true

    /// Timer work item for auto-collapse
    @State private var collapseWorkItem: DispatchWorkItem?

    /// Auto-collapse delay in seconds
    private let collapseDelay: TimeInterval = 8.0

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    private var isMonoMode: Bool {
        OrbColorMode(rawValue: orbColorModeRaw) == .mono
    }

    // MARK: - Body

    var body: some View {
        Group {
            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .onHover { hovering in
            if hovering {
                expand()
            }
        }
        .onAppear {
            scheduleCollapse()
        }
        .sheet(item: $constellationToEdit) { constellation in
            EditConstellationView(constellation: constellation)
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
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
                                scheduleCollapse()
                            },
                            onEdit: {
                                constellationToEdit = constellation
                            },
                            onLaunch: {
                                launchConstellation(constellation)
                            },
                            onInteraction: scheduleCollapse
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
    }

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        Button {
            expand()
        } label: {
            HStack(spacing: 6) {
                selectedFilterIndicator
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassBackgroundEffect()
        }
        .buttonStyle(.plain)
    }

    /// Shows the currently selected filter in collapsed state
    @ViewBuilder
    private var selectedFilterIndicator: some View {
        switch navigationState.filterOption {
        case .all:
            // All filter - just icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 36)

                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 36, height: 36)

                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }

        case .pinned:
            // Pinned filter - just icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 36)

                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 36, height: 36)

                Image(systemName: "pin.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }

        case .constellation(let id):
            // Constellation - icon + name
            if let constellation = constellationManager.constellation(withID: id) {
                let effectiveColor = isMonoMode ? Color.secondary : constellation.color

                HStack(spacing: 5) {
                    ZStack {
                        Circle()
                            .fill(effectiveColor.opacity(0.5))
                            .frame(width: 28, height: 28)

                        Circle()
                            .stroke(effectiveColor, lineWidth: 2)
                            .frame(width: 28, height: 28)

                        Image(systemName: constellation.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(effectiveColor)
                    }

                    Text(constellation.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(effectiveColor.opacity(0.2))
                )
            }
        }
    }

    // MARK: - Collapse/Expand

    private func expand() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isExpanded = true
        }
        scheduleCollapse()
    }

    private func collapse() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isExpanded = false
        }
    }

    private func scheduleCollapse() {
        collapseWorkItem?.cancel()
        let workItem = DispatchWorkItem { [self] in
            collapse()
        }
        collapseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + collapseDelay, execute: workItem)
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        HStack(spacing: 4) {
            // All filter with sort options context menu
            CompactPillButton(
                icon: "square.grid.2x2",
                isSelected: navigationState.filterOption == .all,
                action: {
                    navigationState.filterOption = .all
                    navigationState.selectedConstellationID = nil
                    scheduleCollapse()
                },
                onInteraction: scheduleCollapse
            )
            .contextMenu {
                // Sort options as immediate actions (not submenu)
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Button {
                        navigationState.sortOrder = order
                        scheduleCollapse()
                    } label: {
                        Label(order.rawValue, systemImage: navigationState.sortOrder == order ? "checkmark" : order.icon)
                    }
                }
            }

            CompactPillButton(
                icon: "pin.fill",
                isSelected: navigationState.filterOption == .pinned,
                action: {
                    navigationState.filterOption = .pinned
                    scheduleCollapse()
                },
                onInteraction: scheduleCollapse
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
    var onInteraction: (() -> Void)? = nil

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
            if hovering {
                onInteraction?()
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
    var onInteraction: (() -> Void)? = nil

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
            if hovering {
                onInteraction?()
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
