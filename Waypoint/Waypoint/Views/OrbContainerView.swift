//
//  OrbContainerView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct OrbContainerView: View {

    // MARK: - Properties

    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(NavigationState.self) private var navigationState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ObservedObject var sceneState: OrbSceneState
    @State private var isDropTargeted = false

    // User preferences
    @AppStorage("showSectionHeaders") private var showSectionHeaders: Bool = false

    // Micro-actions state
    @State private var portalToEdit: Portal?
    @State private var showCreateConstellation = false
    @State private var portalForNewConstellation: Portal?

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            let isNarrow = proxy.size.width < 200
            let isVeryNarrow = proxy.size.width < 150

            // Adaptive padding: less padding at narrow widths to maximize content space
            let adaptivePadding: CGFloat = {
                if isVeryNarrow { return 8 }
                if isNarrow { return 12 }
                if proxy.size.width < 300 { return 16 }
                return 24
            }()

            VStack(spacing: isVeryNarrow ? 8 : 16) {
                if sceneState.isExpanded {
                    OrbExpandedView(
                        title: expandedTitle,
                        icon: headerIcon,
                        headerColor: headerColor,
                        portals: visiblePortals,
                        constellationColor: selectedConstellationColor,
                        constellationColorForPortal: shouldUsePerPortalColors ? constellationColorForPortal : nil,
                        constellationSections: constellationSections,
                        isCompact: isNarrow,
                        onBack: collapse,
                        onOpen: { portal in
                            openPortal(portal)
                        },
                        onEdit: { portal in
                            portalToEdit = portal
                        },
                        onDelete: { portal in
                            portalManager.delete(portal)
                        },
                        onTogglePin: { portal in
                            portalManager.togglePin(portal)
                        },
                        onToggleConstellation: { portal, constellation in
                            toggleConstellationAssignment(portal: portal, constellation: constellation)
                        },
                        allConstellations: constellationManager.constellations,
                        constellationIDsForPortal: { portal in
                            constellationIDsForPortal(portal)
                        },
                        onCreateConstellation: { portal in
                            portalForNewConstellation = portal
                            showCreateConstellation = true
                        }
                    )
                } else {
                    OrbLinearField(
                        portals: visiblePortals,
                        constellationColor: selectedConstellationColor,
                        constellationColorForPortal: shouldUsePerPortalColors ? constellationColorForPortal : nil,
                        constellationSections: constellationSections,
                        onOpen: { portal in
                            openPortal(portal)
                        },
                        onEdit: { portal in
                            portalToEdit = portal
                        },
                        onDelete: { portal in
                            portalManager.delete(portal)
                        },
                        onTogglePin: { portal in
                            portalManager.togglePin(portal)
                        },
                        onToggleConstellation: { portal, constellation in
                            toggleConstellationAssignment(portal: portal, constellation: constellation)
                        },
                        allConstellations: constellationManager.constellations,
                        constellationIDsForPortal: { portal in
                            constellationIDsForPortal(portal)
                        },
                        onCreateConstellation: { portal in
                            portalForNewConstellation = portal
                            showCreateConstellation = true
                        }
                    )
                }
            }
            .padding(adaptivePadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        #if os(visionOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .overlay {
            DropInteractionView(
                allowedTypeIdentifiers: [
                    UTType.url.identifier,
                    UTType.fileURL.identifier,
                    UTType.text.identifier,
                    UTType.pdf.identifier,
                    UTType.item.identifier
                ],
                onTargetedChange: { targeted in
                    isDropTargeted = targeted
                },
                onDrop: { providers in
                    Task {
                        let urls = await DropParser.extractURLs(from: providers)
                        await MainActor.run {
                            handleDroppedURLs(urls)
                        }
                    }
                }
            )
            .ignoresSafeArea()
        }
        .onChange(of: navigationState.filterOption) { oldValue, newValue in
            // Auto-expand when selecting a constellation
            if case .constellation = newValue, sceneState.isExpanded == false {
                expand()
            }
        }
        .sheet(item: $portalToEdit) { portal in
            AddPortalView(editingPortal: portal)
        }
        .sheet(isPresented: $showCreateConstellation) {
            CreateConstellationView(initialPortal: portalForNewConstellation)
        }
    }

    // MARK: - Data

    private var visiblePortals: [Portal] {
        // Use NavigationState for filtering (shared with bottom ornament)
        let filtered: [Portal]
        switch navigationState.filterOption {
        case .all:
            filtered = portalManager.portals
        case .pinned:
            filtered = portalManager.portals.filter { $0.isPinned }
        case .ungrouped:
            // Portals not in any constellation
            filtered = portalManager.portals.filter { portal in
                !constellationManager.constellations.contains { $0.portalIDs.contains(portal.id) }
            }
        case .constellation(let id):
            guard let constellation = constellationManager.constellation(withID: id) else {
                filtered = portalManager.portals
                break
            }
            filtered = portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
        }

        // Apply sorting (same logic as PortalListView)
        return filtered.sorted { portal1, portal2 in
            // Pinned always comes first regardless of sort
            if portal1.isPinned != portal2.isPinned {
                return portal1.isPinned
            }

            // Then apply selected sort
            switch navigationState.sortOrder {
            case .custom:
                return portal1.sortIndex < portal2.sortIndex
            case .dateAdded:
                return portal1.dateAdded > portal2.dateAdded
            case .recent:
                let date1 = portal1.lastOpened ?? portal1.dateAdded
                let date2 = portal2.lastOpened ?? portal2.dateAdded
                return date1 > date2
            case .name:
                return portal1.name.localizedCaseInsensitiveCompare(portal2.name) == .orderedAscending
            case .constellation:
                // Sort by constellation order (first constellation a portal belongs to)
                let index1 = constellationIndex(for: portal1)
                let index2 = constellationIndex(for: portal2)
                if index1 != index2 {
                    return index1 < index2
                }
                // Within same constellation, sort by name
                return portal1.name.localizedCaseInsensitiveCompare(portal2.name) == .orderedAscending
            case .constellationColor:
                // Sort by constellation color (hue), no section headers
                let color1 = constellationColor(for: portal1)
                let color2 = constellationColor(for: portal2)
                let hue1 = color1?.hueValue ?? 999 // Ungrouped go last
                let hue2 = color2?.hueValue ?? 999
                if hue1 != hue2 {
                    return hue1 < hue2
                }
                // Within same color, sort by name
                return portal1.name.localizedCaseInsensitiveCompare(portal2.name) == .orderedAscending
            }
        }
    }

    /// Returns the index of the first constellation containing this portal, or Int.max if none
    private func constellationIndex(for portal: Portal) -> Int {
        for (index, constellation) in constellationManager.constellations.enumerated() {
            if constellation.portalIDs.contains(portal.id) {
                return index
            }
        }
        return Int.max // Portals not in any constellation go last
    }

    /// Returns the color of the first constellation containing this portal, or nil if ungrouped
    private func constellationColor(for portal: Portal) -> Color? {
        for constellation in constellationManager.constellations {
            if constellation.portalIDs.contains(portal.id) {
                return constellation.color
            }
        }
        return nil
    }

    private var expandedTitle: String {
        switch navigationState.filterOption {
        case .all:
            return "All Portals"
        case .pinned:
            return "Favorites"
        case .ungrouped:
            return "Ungrouped"
        case .constellation(let id):
            guard let constellation = constellationManager.constellation(withID: id) else {
                return "All Portals"
            }
            return constellation.name
        }
    }

    private var selectedConstellationID: UUID? {
        if case .constellation(let id) = navigationState.filterOption {
            return id
        }
        return nil
    }

    /// The active constellation's color (for color mode)
    private var selectedConstellationColor: Color? {
        guard let id = selectedConstellationID,
              let constellation = constellationManager.constellation(withID: id) else {
            return nil
        }
        return constellation.color
    }

    /// Icon for the header capsule
    private var headerIcon: String? {
        switch navigationState.filterOption {
        case .all:
            return "square.grid.2x2"
        case .pinned:
            return "star.fill"
        case .ungrouped:
            return "tray"
        case .constellation(let id):
            guard let constellation = constellationManager.constellation(withID: id) else {
                return "square.grid.2x2"
            }
            return constellation.icon
        }
    }

    /// Color for the header capsule
    private var headerColor: Color {
        switch navigationState.filterOption {
        case .all:
            return .secondary
        case .pinned:
            return .yellow
        case .ungrouped:
            return .gray
        case .constellation(let id):
            guard let constellation = constellationManager.constellation(withID: id) else {
                return .secondary
            }
            return constellation.color
        }
    }

    /// Whether we're in All view (not filtering by constellation)
    private var isAllView: Bool {
        if case .all = navigationState.filterOption {
            return true
        }
        return false
    }

    /// Whether we should use per-portal constellation colors (All or Pinned view, not a specific constellation)
    private var shouldUsePerPortalColors: Bool {
        switch navigationState.filterOption {
        case .all, .pinned, .ungrouped:
            return true
        case .constellation:
            return false
        }
    }

    /// Lookup function for per-portal constellation color (used in All view)
    private var constellationColorForPortal: (Portal) -> Color? {
        { portal in
            // Find the first constellation containing this portal
            for constellation in self.constellationManager.constellations {
                if constellation.portalIDs.contains(portal.id) {
                    return constellation.color
                }
            }
            return nil // Portal not in any constellation
        }
    }

    /// Whether we're sorted by constellation (show section headers)
    private var isSortedByConstellation: Bool {
        navigationState.sortOrder == .constellation
    }

    /// Constellation sections for grouped layout (only when sorted by constellation in All view and headers enabled)
    private var constellationSections: [ConstellationSection]? {
        guard showSectionHeaders && isAllView && isSortedByConstellation else { return nil }

        var sections: [ConstellationSection] = []
        var assignedPortalIDs = Set<UUID>()

        // Create a section for each constellation (in order)
        for constellation in constellationManager.constellations {
            let portalsInConstellation = visiblePortals.filter { portal in
                constellation.portalIDs.contains(portal.id) && !assignedPortalIDs.contains(portal.id)
            }

            if !portalsInConstellation.isEmpty {
                // Sort portals within constellation: pinned first, then by name
                let sortedPortals = portalsInConstellation.sorted { p1, p2 in
                    if p1.isPinned != p2.isPinned {
                        return p1.isPinned // Pinned items come first
                    }
                    return p1.name.localizedCaseInsensitiveCompare(p2.name) == .orderedAscending
                }

                sections.append(ConstellationSection(
                    id: constellation.id,
                    name: constellation.name,
                    icon: constellation.icon,
                    color: constellation.color,
                    portals: sortedPortals
                ))

                // Mark these portals as assigned
                for portal in portalsInConstellation {
                    assignedPortalIDs.insert(portal.id)
                }
            }
        }

        // Add ungrouped portals (not in any constellation)
        let ungroupedPortals = visiblePortals.filter { !assignedPortalIDs.contains($0.id) }
        if !ungroupedPortals.isEmpty {
            // Sort ungrouped: pinned first, then by name
            let sortedUngrouped = ungroupedPortals.sorted { p1, p2 in
                if p1.isPinned != p2.isPinned {
                    return p1.isPinned // Pinned items come first
                }
                return p1.name.localizedCaseInsensitiveCompare(p2.name) == .orderedAscending
            }
            sections.append(ConstellationSection.ungrouped(portals: sortedUngrouped))
        }

        return sections.isEmpty ? nil : sections
    }

    private func expand() {
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
            sceneState.isExpanded = true
        }
    }

    private func collapse() {
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
            sceneState.isExpanded = false
        }
    }

    // MARK: - Actions

    private func openPortal(_ portal: Portal) {
        guard let url = URL(string: portal.url) else {
            print("❌ Invalid URL: \(portal.url)")
            return
        }

        // Haptic feedback for portal open
        HapticService.lightImpact()

        #if os(visionOS) || os(iOS)
        UIApplication.shared.open(url) { success in
            if success {
                portalManager.updateLastOpened(portal)
                print("🚀 Opened portal: \(portal.name)")
            } else {
                HapticService.error()
                print("❌ Failed to open portal: \(portal.name)")
            }
        }
        #endif
    }

    private func handleDroppedURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        HapticService.success()
        for url in urls {
            createPortalIfNeeded(from: url)
        }
    }

    private func createPortalIfNeeded(from url: URL) {
        if let existingPortal = existingPortal(for: url) {
            addPortalToSelectedConstellation(existingPortal.id)
            return
        }
        let portal = DropService.createPortal(from: url)
        portalManager.add(portal)
        addPortalToSelectedConstellation(portal.id)
    }

    private func existingPortal(for url: URL) -> Portal? {
        portalManager.portals.first { URLNormalizer.matches($0.url, url.absoluteString) }
    }

    // MARK: - Micro-Actions Helpers

    private func constellationIDsForPortal(_ portal: Portal) -> Set<UUID> {
        Set(constellationManager.constellations.filter { $0.portalIDs.contains(portal.id) }.map { $0.id })
    }

    private func toggleConstellationAssignment(portal: Portal, constellation: Constellation) {
        if constellation.portalIDs.contains(portal.id) {
            constellationManager.removePortal(portal.id, from: constellation)
        } else {
            constellationManager.addPortal(portal.id, to: constellation)
        }
    }

    private func addPortalToSelectedConstellation(_ portalID: UUID) {
        guard let selectedID = selectedConstellationID,
              let constellation = constellationManager.constellation(withID: selectedID) else {
            return
        }
        constellationManager.addPortal(portalID, to: constellation)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OrbContainerView(sceneState: OrbSceneState())
            .environment(PortalManager())
            .environment(ConstellationManager())
            .environment(NavigationState())
    }
}
