//
//  WaypointLeftOrnament.swift
//  Waypoint
//
//  Created on January 2, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Left Ornament

/// Left floating ornament - tabs + quick actions
/// List/Orb tab switching + Paste/Add buttons
struct WaypointLeftOrnament: View {

    // MARK: - Properties

    @Binding var selectedTab: WaypointApp.AppTab
    @Environment(NavigationState.self) private var navigationState
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager

    @State private var showQuickAdd = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 4) {
            // Tab switching
            TabIconButton(
                icon: "list.bullet",
                isSelected: selectedTab == .list,
                action: { selectedTab = .list }
            )

            TabIconButton(
                icon: "circle.grid.3x3",
                isSelected: selectedTab == .orb,
                action: { selectedTab = .orb }
            )

            // Divider
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 20, height: 1)
                .padding(.vertical, 2)

            // Quick actions
            TabIconButton(
                icon: "doc.on.clipboard",
                isSelected: false,
                action: quickPasteFromClipboard
            )

            TabIconButton(
                icon: "link.badge.plus",
                isSelected: false,
                action: { showQuickAdd = true }
            )
        }
        .padding(6)
        .glassBackgroundEffect()
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet(activeConstellationID: selectedConstellationID)
        }
    }

    // MARK: - Helpers

    private var selectedConstellationID: UUID? {
        if case .constellation(let id) = navigationState.filterOption {
            return id
        }
        return nil
    }

    // MARK: - Actions

    private func quickPasteFromClipboard() {
        guard let clipboardString = UIPasteboard.general.string else { return }

        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        var url: URL?

        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            if directURL.scheme == "http" || directURL.scheme == "https" || directURL.scheme == "file" {
                url = directURL
            }
        }

        if url == nil && trimmed.contains(".") && !trimmed.contains(" ") {
            url = URL(string: "https://" + trimmed)
        }

        guard let validURL = url else { return }

        if portalManager.portals.contains(where: { $0.url == validURL.absoluteString }) {
            return
        }

        let portal = DropService.createPortal(from: validURL)
        portalManager.add(portal)

        // Auto-add to active constellation
        if let constellationID = selectedConstellationID,
           let constellation = constellationManager.constellation(withID: constellationID) {
            constellationManager.addPortal(portal.id, to: constellation)
            print("📋 Quick Paste added to \(constellation.name): \(portal.name)")
        } else {
            print("📋 Quick Paste created: \(portal.name)")
        }
    }
}

// MARK: - Tab Icon Button

private struct TabIconButton: View {
    let icon: String
    var isSelected: Bool = false
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.25) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
                    .frame(width: 32, height: 32)

                if isSelected {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                }

                Image(systemName: icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
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

// MARK: - Quick Add Sheet

struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager

    let activeConstellationID: UUID?

    @State private var selectedConstellationID: UUID?
    @State private var urlText = ""
    @FocusState private var isFocused: Bool

    private var effectiveConstellationID: UUID? {
        selectedConstellationID ?? activeConstellationID
    }

    private var effectiveConstellation: Constellation? {
        guard let id = effectiveConstellationID else { return nil }
        return constellationManager.constellation(withID: id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Constellation Picker
                    constellationPicker

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
                            PackSection(
                                pack: pack,
                                activeConstellationID: effectiveConstellationID,
                                onSelect: { template in
                                    createPortal(from: template)
                                },
                                onAddToConstellation: { portal, constellationID in
                                    addPortalToConstellation(portal, constellationID: constellationID)
                                },
                                onRemoveFromConstellation: { portal, constellationID in
                                    removePortalFromConstellation(portal, constellationID: constellationID)
                                }
                            )
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { createPortalFromURL() }
                        .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            // Don't auto-focus keyboard - let user tap the field if they want it
            selectedConstellationID = activeConstellationID
        }
        .frame(minWidth: 400, minHeight: 500)
    }

    // MARK: - Constellation Picker

    private var constellationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add to Constellation")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // None option
                    ConstellationPickerChip(
                        name: "None",
                        icon: "circle.slash",
                        color: .secondary,
                        isSelected: effectiveConstellationID == nil,
                        onTap: { selectedConstellationID = nil }
                    )

                    ForEach(constellationManager.constellations) { constellation in
                        ConstellationPickerChip(
                            name: constellation.name,
                            icon: constellation.icon,
                            color: constellation.color,
                            isSelected: effectiveConstellationID == constellation.id,
                            onTap: { selectedConstellationID = constellation.id }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
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

        // Auto-add to selected constellation
        if let constellationID = effectiveConstellationID,
           let constellation = constellationManager.constellation(withID: constellationID) {
            constellationManager.addPortal(portal.id, to: constellation)
        }

        dismiss()
    }

    private func createPortal(from template: PortalTemplate) {
        guard let url = URL(string: template.url) else { return }

        if portalManager.portals.contains(where: { $0.url == template.url }) {
            return
        }

        let portal = DropService.createPortal(from: url)
        portalManager.add(portal)

        // Auto-add to selected constellation
        if let constellationID = effectiveConstellationID,
           let constellation = constellationManager.constellation(withID: constellationID) {
            constellationManager.addPortal(portal.id, to: constellation)
        }
    }

    private func addPortalToConstellation(_ portal: Portal, constellationID: UUID) {
        guard let constellation = constellationManager.constellation(withID: constellationID) else { return }

        // Only add if not already in this constellation
        if !constellation.portalIDs.contains(portal.id) {
            constellationManager.addPortal(portal.id, to: constellation)
            print("➕ Added \(portal.name) to \(constellation.name)")
        }
    }

    private func removePortalFromConstellation(_ portal: Portal, constellationID: UUID) {
        guard let constellation = constellationManager.constellation(withID: constellationID) else { return }

        // Only remove if in this constellation
        if constellation.portalIDs.contains(portal.id) {
            constellationManager.removePortal(portal.id, from: constellation)
            print("➖ Removed \(portal.name) from \(constellation.name)")
        }
    }
}

// MARK: - Constellation Picker Chip

private struct ConstellationPickerChip: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isSelected ? 0.5 : 0.3))
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? color : .secondary)
                }

                Text(name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.2) : Color.secondary.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pack Section

struct PackSection: View {
    let pack: PortalPack
    let activeConstellationID: UUID?
    let onSelect: (PortalTemplate) -> Void
    let onAddToConstellation: ((Portal, UUID) -> Void)?
    let onRemoveFromConstellation: ((Portal, UUID) -> Void)?

    init(pack: PortalPack, activeConstellationID: UUID?, onSelect: @escaping (PortalTemplate) -> Void, onAddToConstellation: ((Portal, UUID) -> Void)? = nil, onRemoveFromConstellation: ((Portal, UUID) -> Void)? = nil) {
        self.pack = pack
        self.activeConstellationID = activeConstellationID
        self.onSelect = onSelect
        self.onAddToConstellation = onAddToConstellation
        self.onRemoveFromConstellation = onRemoveFromConstellation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: pack.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text(pack.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(pack.portals) { template in
                        PortalChip(
                            template: template,
                            activeConstellationID: activeConstellationID,
                            onTap: onSelect,
                            onAddToConstellation: onAddToConstellation,
                            onRemoveFromConstellation: onRemoveFromConstellation
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Portal Chip

struct PortalChip: View {
    let template: PortalTemplate
    let activeConstellationID: UUID?
    let onTap: (PortalTemplate) -> Void
    let onAddToConstellation: ((Portal, UUID) -> Void)?
    let onRemoveFromConstellation: ((Portal, UUID) -> Void)?

    init(template: PortalTemplate, activeConstellationID: UUID?, onTap: @escaping (PortalTemplate) -> Void, onAddToConstellation: ((Portal, UUID) -> Void)? = nil, onRemoveFromConstellation: ((Portal, UUID) -> Void)? = nil) {
        self.template = template
        self.activeConstellationID = activeConstellationID
        self.onTap = onTap
        self.onAddToConstellation = onAddToConstellation
        self.onRemoveFromConstellation = onRemoveFromConstellation
    }

    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager

    private var existingPortal: Portal? {
        portalManager.portals.first { $0.url == template.url }
    }

    private var isAdded: Bool {
        existingPortal != nil
    }

    /// Returns all constellations this portal belongs to
    private var memberConstellations: [Constellation] {
        guard let portal = existingPortal else { return [] }
        return constellationManager.constellations.filter { $0.portalIDs.contains(portal.id) }
    }

    /// Check if already in the selected constellation
    private var isInSelectedConstellation: Bool {
        guard let portal = existingPortal,
              let constellationID = activeConstellationID,
              let constellation = constellationManager.constellation(withID: constellationID) else {
            return false
        }
        return constellation.portalIDs.contains(portal.id)
    }

    /// Can add to selected constellation (portal exists but not in this constellation)
    private var canAddToConstellation: Bool {
        guard let _ = existingPortal,
              let _ = activeConstellationID else {
            return false
        }
        return !isInSelectedConstellation
    }

    /// Disabled only when: portal exists AND no constellation is selected (can't do anything)
    private var isDisabled: Bool {
        if !isAdded {
            return false // Can always create new portal
        }
        // Portal exists - can toggle if constellation is selected
        return activeConstellationID == nil
    }

    var body: some View {
        Button {
            if let portal = existingPortal, let constellationID = activeConstellationID {
                if isInSelectedConstellation {
                    // Remove from constellation
                    onRemoveFromConstellation?(portal, constellationID)
                } else {
                    // Add to constellation
                    onAddToConstellation?(portal, constellationID)
                }
            } else if !isAdded {
                // Create new portal
                onTap(template)
            }
        } label: {
            HStack(spacing: 6) {
                Text(template.name)
                    .font(.caption)
                    .fontWeight(.medium)

                if isAdded {
                    // Show constellation membership indicators
                    constellationIndicators
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(chipBackground)
            .overlay(chipOverlay)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var constellationIndicators: some View {
        let constellations = memberConstellations
        if constellations.isEmpty {
            // Added but not in any constellation - show plain checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.green)
        } else if constellations.count == 1 {
            // Single constellation - show colored checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(constellations[0].color)
        } else {
            // Multiple constellations - show colored dots
            HStack(spacing: 2) {
                ForEach(constellations.prefix(3)) { constellation in
                    Circle()
                        .fill(constellation.color)
                        .frame(width: 6, height: 6)
                }
                if constellations.count > 3 {
                    Text("+\(constellations.count - 3)")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var chipBackground: some View {
        let constellations = memberConstellations
        if !isAdded {
            Capsule().fill(Color.secondary.opacity(0.1))
        } else if constellations.isEmpty {
            Capsule().fill(Color.green.opacity(0.15))
        } else if constellations.count == 1 {
            Capsule().fill(constellations[0].color.opacity(0.15))
        } else {
            // Gradient for multiple constellations
            Capsule().fill(
                LinearGradient(
                    colors: constellations.prefix(3).map { $0.color.opacity(0.15) },
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }

    @ViewBuilder
    private var chipOverlay: some View {
        let constellations = memberConstellations
        if !isAdded {
            Capsule().stroke(Color.clear, lineWidth: 1)
        } else if constellations.isEmpty {
            Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1)
        } else if constellations.count == 1 {
            Capsule().stroke(constellations[0].color.opacity(0.3), lineWidth: 1)
        } else {
            // Gradient stroke for multiple
            Capsule().stroke(
                LinearGradient(
                    colors: constellations.prefix(3).map { $0.color.opacity(0.4) },
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 1
            )
        }
    }
}

// MARK: - Preview

#Preview {
    WaypointLeftOrnament(selectedTab: .constant(.list))
        .padding()
}

#endif
