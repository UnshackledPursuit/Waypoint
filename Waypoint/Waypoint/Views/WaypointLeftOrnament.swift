//
//  WaypointLeftOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Left Ornament

/// Left-side floating ornament for filters and actions
/// Slim vertical bar positioned further from window
struct WaypointLeftOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    @State private var isConstellationsExpanded = false
    @State private var showQuickAdd = false
    @State private var isHoveringPaste = false
    @State private var isHoveringAdd = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Quick actions section
            quickActionsSection

            Divider()
                .frame(width: 28)
                .padding(.vertical, 6)

            // Filter section
            filterSection

            // Constellation section (expandable)
            if !constellationManager.constellations.isEmpty {
                Divider()
                    .frame(width: 28)
                    .padding(.vertical, 6)

                constellationSection
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .glassBackgroundEffect()
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet()
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(spacing: 4) {
            // Quick Paste
            SlimOrnamentButton(
                icon: "doc.on.clipboard",
                isHovering: $isHoveringPaste,
                action: quickPasteFromClipboard
            )

            // Quick Add URL
            SlimOrnamentButton(
                icon: "link.badge.plus",
                isHovering: $isHoveringAdd,
                action: { showQuickAdd = true }
            )
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: 4) {
            SlimOrnamentButton(
                icon: "square.grid.2x2",
                isSelected: navigationState.filterOption == .all,
                action: {
                    navigationState.filterOption = .all
                    navigationState.selectedConstellationID = nil
                }
            )

            SlimOrnamentButton(
                icon: "pin.fill",
                isSelected: navigationState.filterOption == .pinned,
                action: {
                    navigationState.filterOption = .pinned
                }
            )
        }
    }

    // MARK: - Constellation Section

    private var constellationSection: some View {
        VStack(spacing: 4) {
            // Expand/collapse toggle
            SlimOrnamentButton(
                icon: isConstellationsExpanded ? "star.fill" : "star",
                isSelected: isConstellationSelected,
                action: {
                    withAnimation(.spring(response: 0.3)) {
                        isConstellationsExpanded.toggle()
                    }
                }
            )

            // Constellation list (when expanded)
            if isConstellationsExpanded {
                constellationList
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var constellationList: some View {
        VStack(spacing: 4) {
            ForEach(constellationManager.constellations) { constellation in
                SlimOrnamentButton(
                    icon: constellation.icon,
                    color: constellation.color,
                    isSelected: isConstellation(constellation),
                    action: {
                        navigationState.selectConstellation(constellation)
                    }
                )
            }
        }
    }

    // MARK: - Helpers

    private var isConstellationSelected: Bool {
        if case .constellation = navigationState.filterOption {
            return true
        }
        return false
    }

    private func isConstellation(_ constellation: Constellation) -> Bool {
        if case .constellation(let id) = navigationState.filterOption {
            return id == constellation.id
        }
        return false
    }

    // MARK: - Quick Paste Action

    private func quickPasteFromClipboard() {
        guard let clipboardString = UIPasteboard.general.string else {
            return
        }

        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try to create URL
        var url: URL?

        // Direct URL check
        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            if directURL.scheme == "http" || directURL.scheme == "https" || directURL.scheme == "file" {
                url = directURL
            }
        }

        // Check for domain-like strings (add https://)
        if url == nil && trimmed.contains(".") && !trimmed.contains(" ") {
            url = URL(string: "https://" + trimmed)
        }

        guard let validURL = url else {
            return
        }

        // Check if portal already exists
        if portalManager.portals.contains(where: { $0.url == validURL.absoluteString }) {
            // Already exists - could show feedback
            return
        }

        // Create new portal
        let portal = DropService.createPortal(from: validURL)
        portalManager.add(portal)
        print("📋 Quick Paste created: \(portal.name)")
    }
}

// MARK: - Slim Ornament Button

private struct SlimOrnamentButton: View {
    let icon: String
    var color: Color = .primary
    var isSelected: Bool = false
    @Binding var isHovering: Bool
    let action: () -> Void

    init(icon: String, color: Color = .primary, isSelected: Bool = false, isHovering: Binding<Bool> = .constant(false), action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self._isHovering = isHovering
        self.action = action
    }

    @State private var localHovering = false

    private var hovering: Bool {
        isHovering || localHovering
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                Circle()
                    .fill(isSelected ? color.opacity(0.3) : (hovering ? Color.white.opacity(0.15) : Color.clear))
                    .frame(width: 36, height: 36)

                // Selection ring
                if isSelected {
                    Circle()
                        .stroke(color.opacity(0.6), lineWidth: 1.5)
                        .frame(width: 36, height: 36)
                }

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? color : (hovering ? .primary : .secondary))
            }
        }
        .buttonStyle(.plain)
        .onHover { hover in
            withAnimation(.easeInOut(duration: 0.15)) {
                localHovering = hover
            }
        }
    }
}

// MARK: - Quick Add Sheet

private struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    @State private var urlText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter URL or site name", text: $urlText)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
                    .onSubmit { createPortal() }
                    .padding(.horizontal)

                Text("Examples: google.com, https://example.com")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { createPortal() }
                        .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear { isFocused = true }
        .frame(minWidth: 300, minHeight: 200)
    }

    private func createPortal() {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var urlString = trimmed
        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }
        if !urlString.contains(".") {
            urlString = urlString.replacingOccurrences(of: "https://", with: "https://www.") + ".com"
        }

        guard let url = URL(string: urlString) else { return }

        let portal = DropService.createPortal(from: url)
        portalManager.add(portal)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    WaypointLeftOrnament()
        .environment(NavigationState())
        .environment(ConstellationManager())
        .environment(PortalManager())
        .padding()
}

#endif
