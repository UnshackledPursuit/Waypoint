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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var orbSceneState = OrbSceneState()
    @State private var selectedTab: AppTab = .list

    // Clipboard detection state
    @State private var showClipboardPrompt = false
    @State private var clipboardURL: URL?
    @State private var lastCheckedClipboard: String = ""

    // User preferences
    @AppStorage("clipboardDetectionEnabled") private var clipboardDetectionEnabled = true

    // Focus Mode - hides ornaments for distraction-free viewing
    @AppStorage("focusMode") private var focusMode = false
    @State private var temporaryOrnamentReveal = false
    @State private var ornamentRevealWorkItem: DispatchWorkItem?

    // Window size tracking for adaptive layout
    @State private var windowWidth: CGFloat = 400
    @State private var windowHeight: CGFloat = 600

    /// Thresholds below which ornaments are hidden to save space
    private let narrowWidthThreshold: CGFloat = 250
    private let shortHeightThreshold: CGFloat = 200

    /// Whether ornaments should be hidden (focus mode OR window too small)
    private var shouldHideOrnaments: Bool {
        focusMode || windowWidth < narrowWidthThreshold || windowHeight < shortHeightThreshold
    }

    /// Whether ornaments are currently visible (not hidden OR temporarily revealed)
    private var ornamentsVisible: Bool {
        !shouldHideOrnaments || temporaryOrnamentReveal
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            // Manual view switching (no TabView = no native tab ornament)
            GeometryReader { geometry in
                Group {
                    switch selectedTab {
                    case .list:
                        PortalListView()
                    case .orb:
                        OrbSceneView(sceneState: orbSceneState)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: geometry.size) { _, newSize in
                    windowWidth = newSize.width
                    windowHeight = newSize.height
                }
                .onAppear {
                    windowWidth = geometry.size.width
                    windowHeight = geometry.size.height
                }
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
            // Focus mode reveal button - shows when ornaments are hidden
            // Positioned top left to avoid window drag handle interference
            .overlay(alignment: .topLeading) {
                if shouldHideOrnaments && !temporaryOrnamentReveal {
                    FocusModeRevealButton {
                        revealOrnamentsTemporarily()
                    }
                    .padding(12)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: shouldHideOrnaments)
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: temporaryOrnamentReveal)
#if os(visionOS)
            // Left ornament: Tab switching + quick actions (Paste/Add)
            // Visible when: has constellations AND (not in focus mode OR temporarily revealed)
            .ornament(
                visibility: (constellationManager.constellations.count >= 1 && ornamentsVisible) ? .visible : .hidden,
                attachmentAnchor: .scene(.leading),
                contentAlignment: .trailing
            ) {
                WaypointLeftOrnament(selectedTab: $selectedTab, focusMode: $focusMode)
                    .environment(portalManager)
                    .environment(navigationState)
                    .environment(constellationManager)
                    .padding(.trailing, 24)
            }
            // Bottom ornament: Filters, constellations, launch
            // Visible when: has portals AND (not in focus mode OR temporarily revealed)
            .ornament(
                visibility: (portalManager.portals.count >= 1 && ornamentsVisible) ? .visible : .hidden,
                attachmentAnchor: .scene(.bottom),
                contentAlignment: .top
            ) {
                WaypointBottomOrnament()
                    .environment(portalManager)
                    .environment(navigationState)
                    .environment(constellationManager)
                    .padding(.top, 12)
            }
#endif
        }
        .defaultSize(width: 360, height: 500)
        #if os(visionOS)
        .windowResizability(.contentSize)
        #endif
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

    // MARK: - Focus Mode

    /// Temporarily reveals ornaments for 8 seconds, then auto-hides
    private func revealOrnamentsTemporarily() {
        // Cancel any pending hide
        ornamentRevealWorkItem?.cancel()

        // Show ornaments
        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
            temporaryOrnamentReveal = true
        }

        // Schedule auto-hide after 8 seconds
        let workItem = DispatchWorkItem { [self] in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                temporaryOrnamentReveal = false
            }
        }
        ornamentRevealWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: workItem)
    }
}

// MARK: - Focus Mode Reveal Button

/// Small button that appears when ornaments are hidden, tap to temporarily reveal
struct FocusModeRevealButton: View {
    let action: () -> Void

    @State private var isHovering = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 36, height: 36)

                Circle()
                    .stroke(Color.white.opacity(isHovering ? 0.5 : 0.2), lineWidth: 1)
                    .frame(width: 36, height: 36)

                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isHovering ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .help("Show controls")
    }
}

