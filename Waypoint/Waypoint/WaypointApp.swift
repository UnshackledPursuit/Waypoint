//
//  WaypointApp.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI
import UIKit
import Combine

@main
struct WaypointApp: App {

    // MARK: - Properties

    enum AppTab: Hashable {
        case list
        case orb
    }

    @State private var portalManager = PortalManager()
    @State private var constellationManager = ConstellationManager()
    @State private var navigationState = NavigationState()
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var orbSceneState = OrbSceneState()
    @State private var selectedTab: AppTab = .list

    // Clipboard detection state
    @State private var showClipboardPrompt = false
    @State private var clipboardURL: URL?
    @State private var lastCheckedClipboard: String = ""

    // User preferences
    @AppStorage("clipboardDetectionEnabled") private var clipboardDetectionEnabled = true

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                PortalListView()
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                    .tag(AppTab.list)

                OrbSceneView(sceneState: orbSceneState)
                    .tabItem {
                        Label("Orb", systemImage: "sparkles")
                    }
                    .tag(AppTab.orb)
            }
            .environment(portalManager)
            .environment(constellationManager)
            .environment(navigationState)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active && clipboardDetectionEnabled {
                    checkClipboardForURL()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if clipboardDetectionEnabled {
                    // Small delay to ensure clipboard is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        checkClipboardForURL()
                    }
                }
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .alert("Create Portal from Clipboard?", isPresented: $showClipboardPrompt) {
                Button("Create") {
                    createPortalFromClipboard()
                }
                Button("Not Now", role: .cancel) { }
                Button("Don't Ask Again") {
                    clipboardDetectionEnabled = false
                }
            } message: {
                if let url = clipboardURL {
                    Text("Detected URL:\n\(url.absoluteString.prefix(50))...")
                }
            }
#if os(visionOS)
            // Left ornament: Tab switching + filters + constellations
            .ornament(visibility: .visible, attachmentAnchor: .scene(.leading), contentAlignment: .trailing) {
                WaypointLeftOrnament(selectedTab: $selectedTab)
                    .environment(navigationState)
                    .environment(constellationManager)
            }
            // Bottom ornament: Contextual controls (sort for List, layout for Orb)
            .ornament(visibility: .visible, attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
                WaypointBottomOrnament(
                    selectedTab: selectedTab,
                    orbSceneState: orbSceneState
                )
                .environment(navigationState)
                .environment(constellationManager)
            }
#endif
        }
        .defaultSize(width: 400, height: 600)
    }

    // MARK: - Clipboard Detection

    private func checkClipboardForURL() {
        #if os(visionOS) || os(iOS)
        guard let clipboardString = UIPasteboard.general.string else { return }

        // Don't prompt for the same URL twice
        guard clipboardString != lastCheckedClipboard else { return }
        lastCheckedClipboard = clipboardString

        // Check if it looks like a URL
        if let url = extractURL(from: clipboardString) {
            // Don't prompt if portal already exists
            let urlExists = portalManager.portals.contains { $0.url == url.absoluteString }
            if !urlExists {
                clipboardURL = url
                showClipboardPrompt = true
            }
        }
        #endif
    }

    private func extractURL(from string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

        // Direct URL check
        if let url = URL(string: trimmed), url.scheme != nil {
            if url.scheme == "http" || url.scheme == "https" || url.scheme == "file" {
                return url
            }
        }

        // Check for domain-like strings
        if trimmed.contains(".") && !trimmed.contains(" ") {
            if let url = URL(string: "https://" + trimmed) {
                return url
            }
        }

        return nil
    }

    private func createPortalFromClipboard() {
        guard let url = clipboardURL else { return }

        let portal = DropService.createPortal(from: url)
        portalManager.add(portal)
        print("📋 Created portal from clipboard: \(portal.name)")

        clipboardURL = nil
    }

    // MARK: - URL Scheme Handling

    /// Handles incoming URLs via waypoint:// scheme
    /// Supported formats:
    /// - waypoint://add?url=<encoded-url>&name=<optional-name>
    /// - waypoint://open?id=<portal-uuid>
    /// - waypoint://launch?constellation=<constellation-uuid>
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "waypoint" else {
            print("⚠️ Unknown URL scheme: \(url.scheme ?? "nil")")
            return
        }

        guard let host = url.host else {
            print("⚠️ Missing URL host")
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        switch host {
        case "add":
            handleAddCommand(queryItems: queryItems)

        case "open":
            handleOpenCommand(queryItems: queryItems)

        case "launch":
            handleLaunchCommand(queryItems: queryItems)

        default:
            print("⚠️ Unknown command: \(host)")
        }
    }

    private func handleAddCommand(queryItems: [URLQueryItem]) {
        // Get URL parameter
        guard let urlString = queryItems.first(where: { $0.name == "url" })?.value,
              let portalURL = URL(string: urlString) else {
            print("❌ Missing or invalid 'url' parameter")
            return
        }

        // Optional name parameter
        let name = queryItems.first(where: { $0.name == "name" })?.value

        // Create portal
        var portal = DropService.createPortal(from: portalURL)
        if let customName = name {
            portal.name = customName
        }

        portalManager.add(portal)
        print("🔗 Created portal via URL scheme: \(portal.name)")
    }

    private func handleOpenCommand(queryItems: [URLQueryItem]) {
        guard let idString = queryItems.first(where: { $0.name == "id" })?.value,
              let uuid = UUID(uuidString: idString),
              let portal = portalManager.portal(withID: uuid) else {
            print("❌ Portal not found")
            return
        }

        // Open the portal
        if let url = URL(string: portal.url) {
            #if os(visionOS) || os(iOS)
            UIApplication.shared.open(url)
            #endif
            portalManager.updateLastOpened(portal)
            print("🚀 Opened portal via URL scheme: \(portal.name)")
        }
    }

    private func handleLaunchCommand(queryItems: [URLQueryItem]) {
        guard let idString = queryItems.first(where: { $0.name == "constellation" })?.value,
              let uuid = UUID(uuidString: idString),
              let constellation = constellationManager.constellation(withID: uuid) else {
            print("❌ Constellation not found")
            return
        }

        // Launch all portals in constellation
        for (index, portalID) in constellation.portalIDs.enumerated() {
            if let portal = portalManager.portal(withID: portalID),
               let url = URL(string: portal.url) {
                let delay = Double(index) * constellation.launchDelay
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    #if os(visionOS) || os(iOS)
                    UIApplication.shared.open(url)
                    #endif
                    self.portalManager.updateLastOpened(portal)
                }
            }
        }
        print("🌟 Launched constellation via URL scheme: \(constellation.name)")
    }
}

