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

/// Left floating ornament with auto-collapse behavior
/// Collapsed: View toggle only | Expanded: All controls
/// Auto-collapses after 4 seconds, expands on hover/interaction
struct WaypointLeftOrnament: View {

    // MARK: - Properties

    @Binding var selectedTab: WaypointApp.AppTab
    @Binding var focusMode: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(NavigationState.self) private var navigationState
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager

    @State private var showQuickAdd = false
    @State private var showCreateConstellation = false
    @State private var constellationToEdit: Constellation?
    @State private var showConstellationPopover = false

    /// Whether the ornament is expanded (showing all controls)
    @State private var isExpanded = true
    /// Timer work item for auto-collapse
    @State private var collapseWorkItem: DispatchWorkItem?

    /// Global orb intensity: 0.0 = neutral/frosted, 1.0 = vibrant colors
    @AppStorage("orbIntensity") private var orbIntensity: Double = 0.7

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    /// Global orb size preference
    @AppStorage("orbSizePreference") private var orbSizeRaw: String = OrbSize.medium.rawValue

    /// Whether to show constellation section headers in grouped views
    @AppStorage("showSectionHeaders") private var showSectionHeaders: Bool = false

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

    /// Auto-collapse delay in seconds
    private let collapseDelay: TimeInterval = 8.0

    /// Whether left ornament should auto-collapse (default: false = stay open)
    @AppStorage("leftOrnamentAutoCollapse") private var autoCollapseEnabled: Bool = false

    /// Whether to show advanced controls (view toggle, aesthetics)
    /// Only show after 10 portals AND 1 constellation
    private var showAdvancedControls: Bool {
        portalManager.portals.count >= 10 && constellationManager.constellations.count >= 1
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 4) {
            // View mode toggle - only show after 10 portals + 1 constellation
            if showAdvancedControls {
                CompactViewToggle(selectedTab: $selectedTab, onInteraction: scheduleCollapse)
            }

            if isExpanded {
                // Focus Mode toggle (always visible when expanded)
                FocusModeToggle(focusMode: $focusMode, onInteraction: scheduleCollapse)

                // Divider (only if view toggle is shown)
                if showAdvancedControls {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 20, height: 1)
                        .padding(.vertical, 2)
                }

                // Quick actions (always visible when expanded)
                TabIconButton(
                    icon: "doc.on.clipboard",
                    helpText: "Paste from Clipboard",
                    action: {
                        quickPasteFromClipboard()
                        scheduleCollapse()
                    }
                )

                TabIconButton(
                    icon: "link.badge.plus",
                    helpText: "Add Portal",
                    action: {
                        showQuickAdd = true
                        scheduleCollapse()
                    }
                )

                // Divider before constellation controls
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 20, height: 1)
                    .padding(.vertical, 2)

                // Constellation quick access (popover with list + actions)
                TabIconButton(
                    icon: "sparkles",
                    helpText: constellationManager.constellations.isEmpty ? "Create Constellation" : "Constellations",
                    action: {
                        if constellationManager.constellations.isEmpty {
                            showCreateConstellation = true
                        } else {
                            // Toggle to ensure proper state sync after dismiss
                            showConstellationPopover.toggle()
                        }
                        scheduleCollapse()
                    }
                )
                .popover(isPresented: $showConstellationPopover, arrowEdge: .trailing) {
                    ConstellationQuickPopover(
                        constellations: constellationManager.constellations,
                        onSelect: { constellation in
                            navigationState.filterOption = .constellation(constellation.id)
                            showConstellationPopover = false
                        },
                        onEdit: { constellation in
                            showConstellationPopover = false
                            constellationToEdit = constellation
                        },
                        onCreate: {
                            showConstellationPopover = false
                            showCreateConstellation = true
                        },
                        onReorder: { sourceID, targetID in
                            // Reorder and auto-update bottom ornament via @Observable
                            constellationManager.moveConstellation(sourceID, before: targetID)
                        }
                    )
                    .environment(portalManager)
                }

                // Settings menu (only for power users) - contains Appearance, Sort & Filter, Ornament Settings
                if showAdvancedControls {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 20, height: 1)
                        .padding(.vertical, 2)

                    SettingsMenuToggle(
                        intensity: $orbIntensity,
                        colorMode: orbColorMode,
                        orbSize: orbSize,
                        focusMode: $focusMode,
                        onInteraction: scheduleCollapse
                    )
                    .environment(navigationState)
                    .environment(constellationManager)
                    .environment(portalManager)
                }

                #if DEBUG
                // Divider before debug controls
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 20, height: 1)
                    .padding(.vertical, 2)

                // Debug menu
                DebugMenuButton(
                    portalManager: portalManager,
                    constellationManager: constellationManager,
                    onInteraction: scheduleCollapse
                )
                #endif
            } else {
                // Collapsed: show expand button
                Button {
                    expand()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.secondary.opacity(0.15)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .glassBackgroundEffect()
        .animation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
        .onHover { hovering in
            if hovering {
                expand()
            }
        }
        .onChange(of: autoCollapseEnabled) { _, newValue in
            if newValue {
                scheduleCollapse()
            } else {
                collapseWorkItem?.cancel()
            }
        }
        .sheet(isPresented: $showQuickAdd) {
            QuickAddSheet(activeConstellationID: selectedConstellationID)
        }
        .sheet(isPresented: $showCreateConstellation) {
            CreateConstellationView(initialPortal: nil)
        }
        .sheet(item: $constellationToEdit) { constellation in
            EditConstellationView(constellation: constellation)
        }
    }

    // MARK: - Expand/Collapse

    private func expand() {
        withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8)) {
            isExpanded = true
        }
        scheduleCollapse()
    }

    private func collapse() {
        withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.8)) {
            isExpanded = false
        }
    }

    private func scheduleCollapse() {
        guard autoCollapseEnabled else { return }
        collapseWorkItem?.cancel()
        let workItem = DispatchWorkItem { [self] in
            collapse()
        }
        collapseWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + collapseDelay, execute: workItem)
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
        HapticService.success()

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

// MARK: - Compact View Toggle (List/Orb)

/// Simple toggle for switching between List and Orb views
/// Single button that shows current mode icon, tap to switch
private struct CompactViewToggle: View {
    @Binding var selectedTab: WaypointApp.AppTab
    var onInteraction: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            HapticService.selection()
            withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = selectedTab == .list ? .orb : .list
            }
            onInteraction?()
        } label: {
            ZStack {
                // Background
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)

                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 32, height: 32)

                // Icon morphs between modes
                Image(systemName: selectedTab == .list ? "list.bullet" : "circle.grid.3x3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .buttonStyle(.plain)
        .help(selectedTab == .list ? "Switch to Orb View" : "Switch to List View")
    }
}

// MARK: - Focus Mode Toggle

/// Toggle button for Focus Mode (hides ornaments for distraction-free viewing)
/// Shows "eye.slash" when focus mode is on, "eye" when off
private struct FocusModeToggle: View {
    @Binding var focusMode: Bool
    var onInteraction: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    var body: some View {
        Button {
            withAnimation(reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7)) {
                focusMode.toggle()
            }
            onInteraction?()
        } label: {
            ZStack {
                // Background - highlight when active
                Circle()
                    .fill(focusMode ? Color.white.opacity(0.25) : (isHovering ? Color.white.opacity(0.1) : Color.clear))
                    .frame(width: 32, height: 32)

                if focusMode {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                }

                // Icon - eye.slash when focused, eye when not
                Image(systemName: focusMode ? "eye.slash" : "eye")
                    .font(.system(size: 14, weight: focusMode ? .semibold : .regular))
                    .foregroundStyle(focusMode ? .primary : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .help(focusMode ? "Exit Focus Mode" : "Enter Focus Mode")
    }
}

// MARK: - Tab Icon Button

private struct TabIconButton: View {
    let icon: String
    var isSelected: Bool = false
    var helpText: String? = nil
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .help(helpText ?? "")
    }
}

// MARK: - Settings Menu Toggle

/// Unified settings menu containing Appearance, Sort & Filter, and Ornament Settings
private struct SettingsMenuToggle: View {
    @Binding var intensity: Double
    @Binding var colorMode: OrbColorMode
    @Binding var orbSize: OrbSize
    @Binding var focusMode: Bool
    var onInteraction: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    @State private var isExpanded = false
    @State private var showAestheticPopover = false
    @State private var showFilterSortPopover = false
    @State private var showOrnamentPopover = false

    var body: some View {
        VStack(spacing: 2) {
            // Appearance button (icon only)
            SettingsIconButton(
                icon: "slider.horizontal.3",
                helpText: "Appearance",
                action: {
                    showAestheticPopover = true
                    onInteraction?()
                }
            )
            .popover(isPresented: $showAestheticPopover, arrowEdge: .trailing) {
                AestheticPopover(
                    intensity: $intensity,
                    colorMode: $colorMode,
                    orbSize: $orbSize
                )
            }
            .frame(height: isExpanded ? nil : 0)
            .opacity(isExpanded ? 1 : 0)
            .clipped()

            // Sort & Filter button (icon only)
            SettingsIconButton(
                icon: "line.3.horizontal.decrease",
                helpText: "Sort & Filter",
                action: {
                    showFilterSortPopover = true
                    onInteraction?()
                }
            )
            .popover(isPresented: $showFilterSortPopover, arrowEdge: .trailing) {
                FilterSortPopover()
                    .environment(navigationState)
                    .environment(constellationManager)
                    .environment(portalManager)
            }
            .frame(height: isExpanded ? nil : 0)
            .opacity(isExpanded ? 1 : 0)
            .clipped()

            // Ornament Settings button (icon only) - opens popover
            SettingsIconButton(
                icon: "square.2.layers.3d",
                helpText: "Ornaments",
                action: {
                    showOrnamentPopover = true
                    onInteraction?()
                }
            )
            .popover(isPresented: $showOrnamentPopover, arrowEdge: .trailing) {
                OrnamentSettingsPopover(focusMode: $focusMode)
            }
            .frame(height: isExpanded ? nil : 0)
            .opacity(isExpanded ? 1 : 0)
            .clipped()

            // Settings gear - toggles expanded state
            Button {
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
                onInteraction?()
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isExpanded ? .primary : .secondary)
                    .frame(width: 26, height: 26)
                    .background(
                        Circle()
                            .fill(isExpanded ? Color.white.opacity(0.2) : Color.secondary.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.15))
        )
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: isExpanded)
    }
}

// MARK: - Ornament Settings Popover

/// Popover for ornament visibility and focus mode settings
/// Includes descriptions to educate users on each option
private struct OrnamentSettingsPopover: View {
    @Binding var focusMode: Bool

    @AppStorage("leftOrnamentAutoCollapse") private var leftAutoCollapse: Bool = false
    @AppStorage("bottomOrnamentAutoCollapse") private var bottomAutoCollapse: Bool = false

    /// Track which setting was last changed for footer description
    @State private var lastChanged: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "square.2.layers.3d")
                    .font(.system(size: 14, weight: .semibold))
                Text("Ornaments")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
                .padding(.horizontal, 12)

            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Focus Mode
                OrnamentSettingRow(
                    icon: "eye",
                    slashWhenOn: true,
                    label: "Focus Mode",
                    description: "Hide all controls",
                    isOn: $focusMode,
                    onChange: { lastChanged = "focus" }
                )

                Divider()
                    .padding(.horizontal, 4)

                // Auto-hide section label
                Text("Auto-Hide")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)

                // Left ornament
                OrnamentSettingRow(
                    icon: "sidebar.left",
                    slashWhenOn: true,
                    label: "Side Panel",
                    description: "Left controls",
                    isOn: $leftAutoCollapse,
                    onChange: { lastChanged = "left" }
                )

                // Bottom ornament
                OrnamentSettingRow(
                    icon: "dock.rectangle",
                    slashWhenOn: true,
                    label: "Bottom Bar",
                    description: "Filters & constellations",
                    isOn: $bottomAutoCollapse,
                    onChange: { lastChanged = "bottom" }
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            // Footer - contextual description
            Divider()
                .padding(.horizontal, 12)

            Text(footerDescription)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .frame(width: 200)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var footerDescription: String {
        switch lastChanged {
        case "focus":
            return focusMode ? "Controls hidden. Hover edges to reveal." : "All controls visible"
        case "left":
            return leftAutoCollapse ? "Side panel auto-hides after 8s" : "Side panel stays visible"
        case "bottom":
            return bottomAutoCollapse ? "Bottom bar auto-hides after 8s" : "Bottom bar stays visible"
        default:
            return "Configure panel visibility"
        }
    }
}

/// Row for ornament setting with icon, label, description, and toggle
private struct OrnamentSettingRow: View {
    let icon: String
    var slashWhenOn: Bool = false
    let label: String
    let description: String
    @Binding var isOn: Bool
    var onChange: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    var body: some View {
        Button {
            isOn.toggle()
            onChange?()
        } label: {
            HStack(spacing: 10) {
                // Icon with optional slash overlay
                ZStack {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(isOn && slashWhenOn ? .secondary : .primary)

                    if isOn && slashWhenOn {
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: 2, height: 18)
                            .rotationEffect(.degrees(45))
                    }
                }
                .frame(width: 24)

                // Label and description
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Toggle indicator
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(isOn ? .green : .secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

/// Icon-only button for settings menu (compact, matches ornament style)
private struct SettingsIconButton: View {
    let icon: String
    let helpText: String
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isHovering ? .primary : .secondary)
                .frame(width: 26, height: 26)
                .background(
                    Circle()
                        .fill(isHovering ? Color.white.opacity(0.15) : Color.clear)
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        #if os(visionOS)
        .hoverEffect(.highlight)
        #endif
        .help(helpText)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Aesthetic Popover

/// Beautiful popover for appearance controls - intensity, color mode, orb size
/// Uses trailing popover pattern from left ornament
/// Note: Description footer pattern can be reused for Portal Pack popover later
private struct AestheticPopover: View {
    @Binding var intensity: Double
    @Binding var colorMode: OrbColorMode
    @Binding var orbSize: OrbSize

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Ordered color modes: Mono, Portal, Frost, Group (left to right)
    private let colorModeOrder: [OrbColorMode] = [.mono, .defaultStyle, .frost, .constellation]

    /// Maximum intensity value (1.5 = 150% for boost effect)
    private let maxIntensity: Double = 1.5

    /// Boost accent color (black/dark for subtle emphasis)
    private let boostColor = Color(white: 0.15)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text("Appearance")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)

            Divider()
                .padding(.horizontal, 12)

            VStack(spacing: 16) {
                // MARK: Vibrancy Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vibrancy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    HStack(spacing: 10) {
                        // Low vibrancy icon (dim)
                        Button {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                intensity = 0.0
                                switchToColorModeIfNeeded()
                            }
                        } label: {
                            Image(systemName: "circle.dotted")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(intensity < 0.2 ? .white : .secondary)
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(intensity < 0.2 ? Color.white.opacity(0.3) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)

                        // Slider - supports 0 to 1.5 (150% boost)
                        GeometryReader { geo in
                            let normalizedIntensity = intensity / maxIntensity
                            let normalPoint = 1.0 / maxIntensity // Where 100% sits on the slider

                            ZStack(alignment: .leading) {
                                // Track
                                Capsule()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 6)

                                // Fill - gradient with boost zone
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: intensity > 1.0
                                                ? [.secondary.opacity(0.3), .white.opacity(0.8), boostColor.opacity(0.6)]
                                                : [.secondary.opacity(0.3), .white.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(6, geo.size.width * normalizedIntensity), height: 6)

                                // 100% marker (subtle tick)
                                Rectangle()
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 1, height: 10)
                                    .offset(x: geo.size.width * normalPoint - 0.5)

                                // Thumb
                                Circle()
                                    .fill(intensity > 1.0 ? boostColor : .white)
                                    .frame(width: 18, height: 18)
                                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                                    .offset(x: (geo.size.width - 18) * normalizedIntensity)
                            }
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newValue = (value.location.x / geo.size.width) * maxIntensity
                                        intensity = min(max(newValue, 0), maxIntensity)
                                        switchToColorModeIfNeeded()
                                    }
                            )
                        }
                        .frame(height: 24)

                        // High vibrancy icon (boost)
                        Button {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                intensity = maxIntensity
                                switchToColorModeIfNeeded()
                            }
                        } label: {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(intensity > 1.2 ? boostColor : (intensity > 0.8 ? .white : .secondary))
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(intensity > 1.2 ? boostColor.opacity(0.3) : (intensity > 0.8 ? Color.white.opacity(0.3) : Color.clear))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // MARK: Color Style Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color Style")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    HStack(spacing: 6) {
                        ForEach(colorModeOrder, id: \.self) { mode in
                            ColorStyleButton(
                                mode: mode,
                                isSelected: colorMode == mode,
                                action: {
                                    withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                        colorMode = mode
                                    }
                                }
                            )
                        }
                    }
                }

                // MARK: Orb Size Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Orb Size")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    HStack(spacing: 6) {
                        ForEach(OrbSize.allCases, id: \.self) { size in
                            OrbSizeStyleButton(
                                size: size,
                                isSelected: orbSize == size,
                                action: {
                                    withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                        orbSize = size
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            // Footer - contextual description
            Divider()
                .padding(.horizontal, 12)

            Text(footerDescription)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .frame(width: 240)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    /// Dynamic footer description based on current settings
    private var footerDescription: String {
        if intensity > 1.0 {
            let boostPercent = Int((intensity - 1.0) * 100)
            return "Boost mode: +\(boostPercent)% vibrancy"
        }
        return colorMode.description
    }

    private func switchToColorModeIfNeeded() {
        if colorMode == .mono || colorMode == .frost {
            colorMode = .constellation
        }
    }
}

/// Individual color style button with icon and label
/// Uses consistent white/neutral color scheme for cohesive appearance
private struct ColorStyleButton: View {
    let mode: OrbColorMode
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    private var modeIcon: String {
        switch mode {
        case .constellation: return "sparkles"
        case .defaultStyle: return "paintpalette"
        case .frost: return "snowflake"
        case .mono: return "circle.slash"
        }
    }

    private var modeLabel: String {
        switch mode {
        case .constellation: return "Group"
        case .defaultStyle: return "Portal"
        case .frost: return "Frost"
        case .mono: return "Mono"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.white.opacity(0.2) : (isHovering ? Color.white.opacity(0.1) : Color.secondary.opacity(0.1)))
                        .frame(width: 44, height: 36)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 44, height: 36)
                    }

                    Image(systemName: modeIcon)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? .primary : .secondary)
                }

                Text(modeLabel)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

/// Orb size button - S/M/L with visual indicator
private struct OrbSizeStyleButton: View {
    let size: OrbSize
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    /// Visual circle size to represent orb size
    private var circleSize: CGFloat {
        switch size {
        case .small: return 12
        case .medium: return 18
        case .large: return 24
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.white.opacity(0.2) : (isHovering ? Color.white.opacity(0.1) : Color.secondary.opacity(0.1)))
                        .frame(width: 56, height: 36)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 56, height: 36)
                    }

                    // Visual orb size indicator
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.8) : Color.secondary.opacity(0.4))
                        .frame(width: circleSize, height: circleSize)
                }

                Text(size.displayName)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Filter/Sort Popover

/// Popover for sort order and filter options
/// Uses trailing popover pattern from left ornament
private struct FilterSortPopover: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(NavigationState.self) private var navigationState
    @Environment(ConstellationManager.self) private var constellationManager

    /// Count of ungrouped portals for badge display
    @Environment(PortalManager.self) private var portalManager

    private var ungroupedCount: Int {
        portalManager.portals.filter { portal in
            !constellationManager.constellations.contains { $0.portalIDs.contains(portal.id) }
        }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 14, weight: .semibold))
                Text("Sort & Filter")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
                .padding(.horizontal, 12)

            // Content
            VStack(alignment: .leading, spacing: 14) {
                // MARK: Sort Section - Compact grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sort")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    // 3x2 grid for compact display
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 6) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            CompactSortButton(
                                order: order,
                                isSelected: navigationState.sortOrder == order,
                                action: {
                                    withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                        navigationState.sortOrder = order
                                    }
                                }
                            )
                        }
                    }
                }

                // MARK: Filter Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Filter")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 2)

                    // Ungrouped filter toggle - compact
                    CompactFilterButton(
                        label: "Ungrouped",
                        icon: "tray",
                        count: ungroupedCount,
                        isActive: navigationState.filterOption == .ungrouped,
                        action: {
                            withAnimation(reduceMotion ? .none : .spring(response: 0.3)) {
                                if navigationState.filterOption == .ungrouped {
                                    navigationState.filterOption = .all
                                } else {
                                    navigationState.filterOption = .ungrouped
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            // Footer - contextual description
            Divider()
                .padding(.horizontal, 12)

            Text(footerDescription)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .frame(width: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var footerDescription: String {
        if navigationState.filterOption == .ungrouped {
            return "Portals not in any constellation"
        }
        return navigationState.sortOrder.footerDescription
    }
}

/// Compact sort button for grid layout
private struct CompactSortButton: View {
    let order: SortOrder
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: order.icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)

                Text(order.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.white.opacity(0.2) : (isHovering ? Color.white.opacity(0.1) : Color.secondary.opacity(0.08)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.white.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

/// Compact filter button with icon, label, and count
private struct CompactFilterButton: View {
    let label: String
    let icon: String
    let count: Int
    let isActive: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? .primary : .secondary)

                Text(label)
                    .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? .primary : .secondary)

                Spacer()

                // Count badge
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isActive ? .primary : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isActive ? Color.white.opacity(0.2) : Color.secondary.opacity(0.15))
                        )
                }

                // Toggle indicator
                Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundStyle(isActive ? .primary : .secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? Color.white.opacity(0.15) : (isHovering ? Color.white.opacity(0.08) : Color.secondary.opacity(0.08)))
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - OrbColorMode Extension

extension OrbColorMode {
    var description: String {
        switch self {
        case .constellation: return "Orbs use active constellation color"
        case .defaultStyle: return "Each portal uses its own style"
        case .frost: return "Frosted glass with colored icons"
        case .mono: return "Complete grayscale mode"
        }
    }
}

// MARK: - Constellation Quick Popover

/// Quick access popover for constellations - shows list with actions
/// Allows filtering, editing, and creating constellations without modal sheets
/// Supports drag and drop reordering
private struct ConstellationQuickPopover: View {
    let constellations: [Constellation]
    let onSelect: (Constellation) -> Void
    let onEdit: (Constellation) -> Void
    let onCreate: () -> Void
    let onReorder: (UUID, UUID) -> Void  // (sourceID, targetID)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(PortalManager.self) private var portalManager
    @State private var showEditButtons = false
    @State private var showInfoPopover = false
    @State private var draggedConstellation: Constellation?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Text("Constellations")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                // Info button with popover
                Button {
                    showInfoPopover.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showInfoPopover) {
                    Text("Organize portals into constellations to filter and launch them together.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .frame(width: 200)
                }

                Spacer()

                // Edit mode toggle
                Button {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                        showEditButtons.toggle()
                    }
                } label: {
                    Image(systemName: showEditButtons ? "pencil.circle.fill" : "pencil.circle")
                        .font(.system(size: 16))
                        .foregroundStyle(showEditButtons ? .primary : .secondary)
                }
                .buttonStyle(.plain)

                // Create button
                Button {
                    onCreate()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 8)

            Divider()
                .padding(.horizontal, 10)

            // Constellation list with drag and drop reordering
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(constellations) { constellation in
                        ConstellationPopoverRow(
                            constellation: constellation,
                            portalCount: portalCount(for: constellation),
                            showEditButton: showEditButtons,
                            isDragging: draggedConstellation?.id == constellation.id,
                            onSelect: { onSelect(constellation) },
                            onEdit: { onEdit(constellation) }
                        )
                        .draggable(constellation.id.uuidString) {
                            // Drag preview
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(constellation.color.opacity(0.8))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: constellation.icon)
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundStyle(.white)
                                    )
                                Text(constellation.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                        .dropDestination(for: String.self) { items, _ in
                            guard let sourceIDString = items.first,
                                  let sourceID = UUID(uuidString: sourceIDString),
                                  sourceID != constellation.id else {
                                return false
                            }
                            onReorder(sourceID, constellation.id)
                            return true
                        } isTargeted: { isTargeted in
                            // Visual feedback handled by row
                        }
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
            .frame(maxHeight: 260)
        }
        .frame(width: 230)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func portalCount(for constellation: Constellation) -> Int {
        constellation.portalIDs.filter { id in
            portalManager.portal(withID: id) != nil
        }.count
    }
}

/// Individual row in constellation popover - glassy with colored icon
/// Supports drag and drop reordering
private struct ConstellationPopoverRow: View {
    let constellation: Constellation
    let portalCount: Int
    var showEditButton: Bool = false
    var isDragging: Bool = false
    let onSelect: () -> Void
    let onEdit: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false
    @State private var isDropTarget = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                // Drag handle indicator (subtle)
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)

                // Colored constellation icon orb
                ZStack {
                    Circle()
                        .fill(constellation.color.opacity(0.8))
                        .frame(width: 28, height: 28)

                    Image(systemName: constellation.icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }

                // Name and count
                VStack(alignment: .leading, spacing: 1) {
                    Text(constellation.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text("\(portalCount) portal\(portalCount == 1 ? "" : "s")")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Edit button (show when edit mode or hovering)
                if showEditButton || isHovering {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovering ? Color.white.opacity(0.1) : Color.clear)
            )
            .opacity(isDragging ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Debug Menu Button

#if DEBUG
private struct DebugMenuButton: View {
    let portalManager: PortalManager
    let constellationManager: ConstellationManager
    var onInteraction: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false
    @State private var showOrbCatalog = false

    /// Resets onboarding state via AppStorage
    private func resetOnboarding() {
        OnboardingState.reset()
    }

    var body: some View {
        VStack(spacing: 2) {
            if isExpanded {
                // Orb Style Catalog
                Button {
                    showOrbCatalog = true
                    isExpanded = false
                } label: {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.cyan)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.cyan.opacity(0.2)))
                }
                .buttonStyle(.plain)
                .help("Orb Style Catalog")

                // Load Sample Data (portals + constellations)
                Button {
                    portalManager.loadSampleData()
                    constellationManager.loadSampleData()
                    isExpanded = false
                    onInteraction?()
                } label: {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color(white: 0.25)))
                }
                .buttonStyle(.plain)
                .help("Load sample portals + constellations")

                // Clear All (nuclear option)
                Button {
                    portalManager.clearAll()
                    constellationManager.clearAll()
                    isExpanded = false
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color(white: 0.15)))
                }
                .buttonStyle(.plain)
                .help("Clear all data")

                // Reset Onboarding
                Button {
                    resetOnboarding()
                    isExpanded = false
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color(white: 0.35)))
                }
                .buttonStyle(.plain)
                .help("Reset onboarding hints")

                // Close
                Button {
                    isExpanded = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.secondary.opacity(0.15)))
                }
                .buttonStyle(.plain)
            } else {
                // Collapsed - show debug icon
                Button {
                    isExpanded = true
                } label: {
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.secondary.opacity(0.15)))
                }
                .buttonStyle(.plain)
                .help("Debug menu")
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondary.opacity(0.15))
        )
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.2), value: isExpanded)
        .sheet(isPresented: $showOrbCatalog) {
            OrbStyleCatalog()
        }
    }
}
#endif

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
        .frame(minWidth: 280, minHeight: 400)
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
    WaypointLeftOrnament(selectedTab: .constant(.list), focusMode: .constant(false))
        .padding()
}

#endif
