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
    @ObservedObject var sceneState: OrbSceneState
    @State private var isDropTargeted = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            if sceneState.isExpanded {
                OrbExpandedView(
                    title: expandedTitle,
                    portals: visiblePortals,
                    layoutMode: $sceneState.layoutMode,
                    constellationColor: selectedConstellationColor,
                    onBack: collapse
                ) { portal in
                    openPortal(portal)
                }
            } else {
                OrbTopBar(title: "Orb", onBack: nil, trailing: nil)

                OrbFieldView(
                    portals: visiblePortals,
                    layoutMode: sceneState.layoutMode,
                    constellationColor: selectedConstellationColor
                ) { portal in
                    openPortal(portal)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .navigationTitle("Orb")
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
    }

    // MARK: - Data

    private var visiblePortals: [Portal] {
        // Use NavigationState for filtering (shared with bottom ornament)
        switch navigationState.filterOption {
        case .all:
            return portalManager.portals
        case .pinned:
            return portalManager.portals.filter { $0.isPinned }
        case .constellation(let id):
            guard let constellation = constellationManager.constellation(withID: id) else {
                return portalManager.portals
            }
            return portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
        }
    }

    private var expandedTitle: String {
        switch navigationState.filterOption {
        case .all:
            return "All Portals"
        case .pinned:
            return "Pinned"
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

    private func expand() {
        withAnimation(.easeInOut(duration: 0.2)) {
            sceneState.isExpanded = true
        }
    }

    private func collapse() {
        withAnimation(.easeInOut(duration: 0.2)) {
            sceneState.isExpanded = false
        }
    }

    // MARK: - Actions

    private func openPortal(_ portal: Portal) {
        guard let url = URL(string: portal.url) else {
            print("❌ Invalid URL: \(portal.url)")
            return
        }

        #if os(visionOS) || os(iOS)
        UIApplication.shared.open(url) { success in
            if success {
                portalManager.updateLastOpened(portal)
                print("🚀 Opened portal: \(portal.name)")
            } else {
                print("❌ Failed to open portal: \(portal.name)")
            }
        }
        #endif
    }

    private func handleDroppedURLs(_ urls: [URL]) {
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
