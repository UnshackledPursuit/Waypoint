//
//  WaypointBottomOrnament.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Bottom Ornament

/// Bottom floating ornament - unified control bar
/// Combines quick actions, filters, constellations, and launch
struct WaypointBottomOrnament: View {

    // MARK: - Properties

    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    @State private var constellationToEdit: Constellation?
    @State private var showQuickAdd = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 6) {
            // Quick Actions
            quickActionsSection

            pillDivider

            // Filters
            filterSection

            pillDivider

            // Constellations
            constellationSection

            // Launch All (only when constellation selected)
            if selectedConstellation != nil {
                pillDivider
                launchAllPill
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .glassBackgroundEffect()
        .sheet(item: $constellationToEdit) { constellation in
            EditConstellationView(constellation: constellation)
        }
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet(activeConstellationID: selectedConstellationID)
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        HStack(spacing: 4) {
            // Quick Paste
            CompactPillButton(
                icon: "doc.on.clipboard",
                action: quickPasteFromClipboard
            )

            // Quick Add URL
            CompactPillButton(
                icon: "link.badge.plus",
                action: { showQuickAdd = true }
            )
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        HStack(spacing: 4) {
            CompactPillButton(
                icon: "square.grid.2x2",
                isSelected: navigationState.filterOption == .all,
                action: {
                    navigationState.filterOption = .all
                    navigationState.selectedConstellationID = nil
                }
            )

            CompactPillButton(
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
        HStack(spacing: 4) {
            ForEach(constellationManager.constellations) { constellation in
                ConstellationPill(
                    constellation: constellation,
                    isSelected: isConstellation(constellation),
                    onTap: {
                        navigationState.selectConstellation(constellation)
                    },
                    onEdit: {
                        constellationToEdit = constellation
                    },
                    onLaunch: {
                        launchConstellation(constellation)
                    }
                )
            }
        }
    }

    // MARK: - Launch All Pill

    private var launchAllPill: some View {
        Button {
            if let constellation = selectedConstellation {
                launchConstellation(constellation)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 12, weight: .medium))
                Text("Launch")
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(selectedConstellation?.color.opacity(0.8) ?? Color.blue.opacity(0.8))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Divider

    private var pillDivider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(width: 1, height: 20)
            .padding(.horizontal, 2)
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

// MARK: - Compact Pill Button

private struct CompactPillButton: View {
    let icon: String
    var isSelected: Bool = false
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.white.opacity(0.25) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
                    .frame(width: 28, height: 28)

                if isSelected {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                }

                Image(systemName: icon)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
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

// MARK: - Constellation Pill

private struct ConstellationPill: View {
    let constellation: Constellation
    let isSelected: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onLaunch: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                // Small orb
                ZStack {
                    Circle()
                        .fill(constellation.color.opacity(isSelected ? 0.5 : 0.3))
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .stroke(constellation.color, lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                    }

                    Image(systemName: constellation.icon)
                        .font(.system(size: 9, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? constellation.color : .secondary)
                }

                // Label on hover or selected
                if isHovering || isSelected {
                    Text(constellation.name)
                        .font(.caption2)
                        .fontWeight(isSelected ? .medium : .regular)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                        .lineLimit(1)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding(.horizontal, isHovering || isSelected ? 6 : 3)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(isSelected ? constellation.color.opacity(0.2) : (isHovering ? Color.white.opacity(0.08) : Color.clear))
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
        }
    }
}

// MARK: - Quick Add Sheet

private struct QuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager

    let activeConstellationID: UUID?

    @State private var urlText = ""
    @FocusState private var isFocused: Bool

    private var activeConstellation: Constellation? {
        guard let id = activeConstellationID else { return nil }
        return constellationManager.constellation(withID: id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Active constellation indicator
                    if let constellation = activeConstellation {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(constellation.color)
                                .frame(width: 12, height: 12)
                            Text("Adding to \(constellation.name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }

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
                            PackSection(pack: pack, activeConstellationID: activeConstellationID) { template in
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

        // Auto-add to active constellation
        if let constellationID = activeConstellationID,
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

        // Auto-add to active constellation
        if let constellationID = activeConstellationID,
           let constellation = constellationManager.constellation(withID: constellationID) {
            constellationManager.addPortal(portal.id, to: constellation)
        }
    }
}

// MARK: - Pack Section

private struct PackSection: View {
    let pack: PortalPack
    let activeConstellationID: UUID?
    let onSelect: (PortalTemplate) -> Void

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
    WaypointBottomOrnament()
        .environment(NavigationState())
        .environment(ConstellationManager())
        .environment(PortalManager())
        .padding()
}

#endif
