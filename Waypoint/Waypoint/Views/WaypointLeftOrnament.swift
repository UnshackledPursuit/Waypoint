//
//  WaypointLeftOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Left Ornament

/// Left-side floating ornament for quick actions and filters
/// Slim vertical bar - constellations now on bottom ornament
struct WaypointLeftOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(PortalManager.self) private var portalManager

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
            ScrollView {
                VStack(spacing: 24) {
                    // URL Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter URL")
                            .font(.headline)

                        TextField("google.com or https://example.com", text: $urlText)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isFocused)
                            .onSubmit { createPortalFromURL() }
                    }
                    .padding(.horizontal)

                    Divider()

                    // Portal Packs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Start")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(PortalPack.allPacks) { pack in
                            PackSection(pack: pack) { template in
                                createPortal(from: template)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { createPortalFromURL() }
                        .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear { isFocused = true }
        .frame(minWidth: 400, minHeight: 500)
    }

    private func createPortalFromURL() {
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

    private func createPortal(from template: PortalTemplate) {
        guard let url = URL(string: template.url) else { return }

        // Check if already exists
        if portalManager.portals.contains(where: { $0.url == template.url }) {
            return
        }

        let portal = DropService.createPortal(from: url)
        portalManager.add(portal)
    }
}

// MARK: - Pack Section

private struct PackSection: View {
    let pack: PortalPack
    let onSelect: (PortalTemplate) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: pack.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text(pack.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal)

            // Portal chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(pack.portals) { template in
                        PortalChip(template: template, onTap: onSelect)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Portal Chip

private struct PortalChip: View {
    let template: PortalTemplate
    let onTap: (PortalTemplate) -> Void
    @Environment(PortalManager.self) private var portalManager

    private var isAdded: Bool {
        portalManager.portals.contains { $0.url == template.url }
    }

    var body: some View {
        Button {
            onTap(template)
        } label: {
            HStack(spacing: 6) {
                Text(template.name)
                    .font(.caption)
                    .fontWeight(.medium)

                if isAdded {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isAdded ? Color.green.opacity(0.15) : Color.secondary.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isAdded ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isAdded)
    }
}

// MARK: - Preview

#Preview {
    WaypointLeftOrnament()
        .environment(NavigationState())
        .environment(PortalManager())
        .padding()
}

#endif
