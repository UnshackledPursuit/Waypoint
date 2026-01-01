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
                    onBack: collapse
                ) { portal in
                    openPortal(portal)
                }
            } else {
                OrbTopBar(title: "Orb", onBack: nil, trailing: nil)

                OrbFieldView(
                    portals: visiblePortals,
                    layoutMode: sceneState.layoutMode
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
        .onChange(of: sceneState.selectedConstellationID) { oldValue, newValue in
            guard newValue != nil, sceneState.isExpanded == false else { return }
            expand()
        }
    }

    // MARK: - Data

    private var visiblePortals: [Portal] {
        guard let selectedID = sceneState.selectedConstellationID,
              let constellation = constellationManager.constellation(withID: selectedID) else {
            return portalManager.portals
        }

        return portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
    }

    private var expandedTitle: String {
        guard let selectedID = sceneState.selectedConstellationID,
              let constellation = constellationManager.constellation(withID: selectedID) else {
            return "All Portals"
        }
        return constellation.name
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
        guard let selectedID = sceneState.selectedConstellationID,
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
    }
}
