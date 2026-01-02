//
//  WaypointLeftOrnament.swift
//  Waypoint
//
//  Created on January 2, 2026.
//

import SwiftUI

#if os(visionOS)

// MARK: - Orb Size Enum

enum OrbSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"

    var displayName: String {
        switch self {
        case .small: return "S"
        case .medium: return "M"
        case .large: return "L"
        }
    }

    /// Icon representing size (small to large circles)
    var icon: String {
        switch self {
        case .small: return "circle"
        case .medium: return "circle.inset.filled"
        case .large: return "circle.fill"
        }
    }

    /// Multiplier applied to base orb size (64pt)
    var multiplier: CGFloat {
        switch self {
        case .small: return 0.55   // ~35pt - compact
        case .medium: return 0.7   // ~45pt - balanced
        case .large: return 1.0    // 64pt - original
        }
    }

    /// Computed size based on base 64pt
    var size: CGFloat {
        64 * multiplier
    }
}

// MARK: - Left Ornament

/// Left floating ornament - tabs + quick actions + intensity slider
/// List/Orb tab switching + Paste/Add buttons + Global Intensity
struct WaypointLeftOrnament: View {

    // MARK: - Properties

    @Binding var selectedTab: WaypointApp.AppTab
    @Environment(NavigationState.self) private var navigationState
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager

    @State private var showQuickAdd = false

    /// Global orb intensity: 0.0 = neutral/frosted, 1.0 = vibrant colors
    @AppStorage("orbIntensity") private var orbIntensity: Double = 0.7

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    /// Global orb size preference
    @AppStorage("orbSizePreference") private var orbSizeRaw: String = OrbSize.medium.rawValue

    private var orbColorMode: Binding<OrbColorMode> {
        Binding(
            get: { OrbColorMode(rawValue: orbColorModeRaw) ?? .defaultStyle },
            set: { orbColorModeRaw = $0.rawValue }
        )
    }

    private var orbSize: Binding<OrbSize> {
        Binding(
            get: { OrbSize(rawValue: orbSizeRaw) ?? .medium },
            set: { orbSizeRaw = $0.rawValue }
        )
    }

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

            // Divider before color controls
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 20, height: 1)
                .padding(.vertical, 2)

            // Collapsible intensity control
            IntensityControl(intensity: $orbIntensity)

            // Color mode toggle (vertical 4-way)
            ColorModeToggle(colorMode: orbColorMode)

            // Orb size picker
            OrbSizeToggle(orbSize: orbSize)
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

// MARK: - Intensity Control (Collapsible)

/// Collapsible intensity slider - tap button to expand slider
/// When collapsed: subtle button that blends in
/// When expanded: slider with improved interaction at extremes
private struct IntensityControl: View {
    @Binding var intensity: Double
    @State private var isExpanded = false

    /// Color mode to determine if in mono mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    private var isMonoMode: Bool {
        OrbColorMode(rawValue: orbColorModeRaw) == .mono
    }

    /// Slider fill color - subtle teal instead of purple
    private var sliderColor: Color {
        if isMonoMode { return Color.gray }
        return Color(red: 0.4, green: 0.7, blue: 0.8) // Soft teal
    }

    /// Icon reflects current intensity level
    private var intensityIcon: String {
        if intensity < 0.3 { return "circle.fill" }
        if intensity < 0.7 { return "sun.min.fill" }
        return "sun.max.fill"
    }

    var body: some View {
        VStack(spacing: 4) {
            if isExpanded {
                expandedSlider
            } else {
                collapsedButton
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    // MARK: - Collapsed Button (Subtle)

    private var collapsedButton: some View {
        Button {
            isExpanded = true
        } label: {
            ZStack {
                // Subtle background - blends in with other buttons
                Circle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 32, height: 32)

                // Icon - secondary color to blend in, not attention-grabbing
                Image(systemName: intensityIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expanded Slider

    private var expandedSlider: some View {
        VStack(spacing: 4) {
            // High intensity icon (tap to set max)
            Button {
                intensity = 1.0
            } label: {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(intensity > 0.7 ? sliderColor : .secondary)
                    .frame(width: 26, height: 20)
            }
            .buttonStyle(.plain)

            // Compact slider track
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Track background
                    Capsule()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 6)

                    // Filled portion
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.4), sliderColor],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 6, height: max(4, geo.size.height * intensity))

                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                        .offset(y: -geo.size.height * intensity + 7)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newIntensity = 1.0 - (value.location.y / geo.size.height)
                            intensity = min(max(newIntensity, 0), 1)
                        }
                )
            }
            .frame(width: 32, height: 60)

            // Low intensity icon (tap to set min)
            Button {
                intensity = 0.0
            } label: {
                Image(systemName: "snowflake")
                    .font(.system(size: 12))
                    .foregroundStyle(intensity < 0.3 ? .white : .secondary)
                    .frame(width: 26, height: 20)
            }
            .buttonStyle(.plain)

            // Close button - easy to hit
            Button {
                isExpanded = false
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.green)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
        )
    }
}

// MARK: - Color Mode Toggle (Collapsible Vertical 4-way)

/// Collapsible vertical 4-way toggle for orb color mode
/// Auto-collapses after inactivity, shows selected mode when collapsed
private struct ColorModeToggle: View {
    @Binding var colorMode: OrbColorMode
    @State private var isExpanded = false
    @State private var collapseWorkItem: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 2) {
            if isExpanded {
                // Expanded: Show all 4 options
                ForEach(OrbColorMode.allCases, id: \.self) { mode in
                    ColorModeButton(
                        mode: mode,
                        isSelected: colorMode == mode,
                        action: {
                            colorMode = mode
                            scheduleCollapse()
                        }
                    )
                }
            } else {
                // Collapsed: Show only selected mode (tap to expand) - subtle, blends in
                Button {
                    isExpanded = true
                    scheduleCollapse()
                } label: {
                    Image(systemName: colorMode.icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary) // Subtle - no color when collapsed
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.15))
        )
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    private func scheduleCollapse() {
        collapseWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation {
                isExpanded = false
            }
        }
        collapseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }

    private func modeColor(for mode: OrbColorMode) -> Color {
        switch mode {
        case .constellation: return .orange
        case .defaultStyle: return .blue
        case .frost: return .cyan
        case .mono: return .secondary
        }
    }
}

private struct ColorModeButton: View {
    let mode: OrbColorMode
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: modeIcon)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? modeColor : .secondary)
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(isSelected ? modeColor.opacity(0.25) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }

    /// Custom icon for better visibility - mono uses a clearer icon
    private var modeIcon: String {
        switch mode {
        case .mono: return "circle.slash" // More visible than circle.lefthalf.strikethrough
        default: return mode.icon
        }
    }

    private var modeColor: Color {
        switch mode {
        case .constellation: return .orange
        case .defaultStyle: return .blue
        case .frost: return .cyan
        case .mono: return .secondary
        }
    }
}

// MARK: - Orb Size Toggle (Collapsible Vertical 4-way)

/// Collapsible vertical 4-way toggle for orb size
/// Auto-collapses after inactivity, shows selected size when collapsed
private struct OrbSizeToggle: View {
    @Binding var orbSize: OrbSize
    @State private var isExpanded = false
    @State private var collapseWorkItem: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 2) {
            if isExpanded {
                // Expanded: Show all 4 size options
                ForEach(OrbSize.allCases, id: \.self) { size in
                    OrbSizeButton(
                        size: size,
                        isSelected: orbSize == size,
                        action: {
                            orbSize = size
                            scheduleCollapse()
                        }
                    )
                }
            } else {
                // Collapsed: Show size icon (tap to expand)
                Button {
                    isExpanded = true
                    scheduleCollapse()
                } label: {
                    Image(systemName: orbSize.icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.15))
        )
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    private func scheduleCollapse() {
        collapseWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            withAnimation {
                isExpanded = false
            }
        }
        collapseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }
}

private struct OrbSizeButton: View {
    let size: OrbSize
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(size.displayName)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.25) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
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
