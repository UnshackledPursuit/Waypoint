//
//  PortalOrbView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct PortalOrbView: View {

    // MARK: - Properties

    let portal: Portal
    var accentColor: Color = .blue
    /// Optional constellation color - used when colorMode is .constellation
    var constellationColor: Color? = nil
    var size: CGFloat = 64
    /// Whether to show the label below the orb (set to false for strip/compact modes)
    var showLabel: Bool = true
    let onOpen: () -> Void

    // MARK: - Micro-Action Callbacks (optional - enables micro-actions when provided)

    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onTogglePin: (() -> Void)? = nil
    var onToggleConstellation: ((Constellation) -> Void)? = nil
    var constellations: [Constellation] = []
    var portalConstellationIDs: Set<UUID> = []
    var onCreateConstellation: (() -> Void)? = nil

    // MARK: - Micro-Action State

    @State private var showMicroActions = false
    @State private var showConstellationPicker = false
    @State private var microActionsWorkItem: DispatchWorkItem?
    @State private var isHovering = false

    /// Notification name for dismissing all micro-action menus
    private static let dismissAllMenusNotification = Notification.Name("DismissAllOrbMicroActions")

    /// Global orb intensity from user preferences (0.0 = neutral/frosted, 1.0 = vibrant)
    @AppStorage("orbIntensity") private var orbIntensity: Double = 0.7

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    private var orbColorMode: OrbColorMode {
        OrbColorMode(rawValue: orbColorModeRaw) ?? .defaultStyle
    }

    /// The portal's natural color (from its style settings or fallback)
    private var portalNaturalColor: Color {
        if portal.useCustomStyle {
            return portal.displayColor
        } else {
            return portal.fallbackColor
        }
    }

    /// The effective color after applying color mode and intensity
    /// - constellation mode: Use constellation color for all orbs
    /// - default mode: Use portal's actual style color
    /// - frost mode: Gray bubbles, icons keep color
    /// - mono mode: Everything grayscale
    private var effectiveColor: Color {
        // First determine base color from color mode
        let baseColor: Color
        switch orbColorMode {
        case .constellation:
            baseColor = constellationColor ?? portalNaturalColor
        case .defaultStyle:
            baseColor = portalNaturalColor
        case .frost, .mono:
            return Color.gray
        }

        // Then apply intensity
        if orbIntensity < 0.1 {
            return Color.gray
        }
        return baseColor
    }

    /// Opacity multiplier based on intensity for color elements
    private var colorOpacity: Double {
        if orbColorMode == .frost || orbColorMode == .mono {
            return 0.4 // Frosted glass look
        }
        // Range: 0.3 (very faded) to 1.0 (full vibrant)
        return 0.3 + (orbIntensity * 0.7)
    }

    /// Whether to desaturate icons/favicons (only in mono mode)
    private var shouldDesaturateContent: Bool {
        orbColorMode == .mono
    }

    /// Whether micro-actions are enabled (callbacks provided)
    private var microActionsEnabled: Bool {
        onEdit != nil || onDelete != nil || onTogglePin != nil
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 4) {
            // Micro-actions ABOVE the orb (horizontal)
            if showMicroActions {
                radialMicroActions
                    .transition(.scale.combined(with: .opacity))
            }

            // Main orb content
            orbBody
                .contentShape(Circle())
                // Hover effect: lift toward user on gaze
                #if os(visionOS)
                .hoverEffect(.lift)
                .hoverEffect { effect, isActive, _ in
                    effect
                        .scaleEffect(isActive ? 1.05 : 1.0)
                }
                #endif
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHovering = hovering
                    }
                }
                .scaleEffect(isHovering ? 1.02 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovering)
                .help(portal.name)
                .onTapGesture {
                    if showMicroActions {
                        dismissMicroActions()
                    } else {
                        onOpen()
                    }
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            guard microActionsEnabled else { return }
                            // Dismiss all other menus first
                            NotificationCenter.default.post(
                                name: Self.dismissAllMenusNotification,
                                object: portal.id
                            )
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showMicroActions = true
                                showConstellationPicker = false
                            }
                            scheduleMicroActionsDismiss()
                        }
                )
                // Context menu as accessibility fallback
                .contextMenu {
                    if microActionsEnabled {
                        Button {
                            onOpen()
                        } label: {
                            Label("Open", systemImage: "arrow.up.right.square")
                        }

                        if !constellations.isEmpty {
                            Menu {
                                ForEach(constellations) { constellation in
                                    Button {
                                        onToggleConstellation?(constellation)
                                    } label: {
                                        let isAssigned = portalConstellationIDs.contains(constellation.id)
                                        Label(
                                            constellation.name,
                                            systemImage: isAssigned ? "checkmark.circle.fill" : "circle"
                                        )
                                    }
                                }
                                if let onCreateConstellation {
                                    Divider()
                                    Button {
                                        onCreateConstellation()
                                    } label: {
                                        Label("New Constellation", systemImage: "plus")
                                    }
                                }
                            } label: {
                                Label("Constellations", systemImage: "sparkles")
                            }
                        }

                        Divider()

                        if let onTogglePin {
                            Button {
                                onTogglePin()
                            } label: {
                                Label(
                                    portal.isPinned ? "Unpin" : "Pin",
                                    systemImage: portal.isPinned ? "mappin.slash" : "mappin"
                                )
                            }
                        }

                        if let onEdit {
                            Button {
                                onEdit()
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }

                        if let onDelete {
                            Divider()
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showMicroActions)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showConstellationPicker)
        .onReceive(NotificationCenter.default.publisher(for: Self.dismissAllMenusNotification)) { notification in
            // Dismiss this menu unless we're the one that sent the notification
            if let senderID = notification.object as? UUID, senderID != portal.id {
                dismissMicroActions()
            }
        }
    }

    // MARK: - Orb Body

    /// Glow multiplier - increases when hovering for visual feedback
    private var glowMultiplier: Double {
        isHovering ? 1.4 : 1.0
    }

    private var orbBody: some View {
        VStack(spacing: 8) {
            // Glass sphere orb
            ZStack {
                // Outer glow - ambient light effect (intensity affects glow strength)
                // Intensifies on hover for visual feedback
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                effectiveColor.opacity(0.3 * colorOpacity * glowMultiplier),
                                effectiveColor.opacity(0.12 * colorOpacity * glowMultiplier),
                                effectiveColor.opacity(0.03 * colorOpacity * glowMultiplier),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.35,
                            endRadius: size * (isHovering ? 0.95 : 0.85)
                        )
                    )
                    .frame(width: size * 1.6, height: size * 1.6)
                    .animation(.easeInOut(duration: 0.2), value: isHovering)

                // Main sphere body - deeper 3D gradient (intensity affects color saturation)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                effectiveColor.opacity(0.2 * colorOpacity),
                                effectiveColor.opacity(0.35 * colorOpacity),
                                effectiveColor.opacity(0.5 * colorOpacity),
                                effectiveColor.opacity(0.6 * colorOpacity)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.25),
                            startRadius: size * 0.05,
                            endRadius: size * 0.55
                        )
                    )
                    .frame(width: size, height: size)

                // Top-left specular highlight (key light reflection)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.0)
                            ],
                            center: UnitPoint(x: 0.25, y: 0.2),
                            startRadius: 0,
                            endRadius: size * 0.35
                        )
                    )
                    .frame(width: size, height: size)

                // Rim light effect (subtle edge highlight)
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: size, height: size)

                // Bottom reflection (ground bounce light)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ],
                            center: UnitPoint(x: 0.6, y: 0.85),
                            startRadius: 0,
                            endRadius: size * 0.25
                        )
                    )
                    .frame(width: size, height: size)

                // Content: Favicon or Letter
                orbContent

                // Glass inner reflection arc (subtle)
                Circle()
                    .trim(from: 0.1, to: 0.4)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size * 0.7, height: size * 0.7)
                    .rotationEffect(.degrees(-30))
            }
            .frame(width: size * 1.6, height: size * 1.6)
            .shadow(color: effectiveColor.opacity(0.35 * colorOpacity), radius: 10, y: 4)
            .shadow(color: Color.black.opacity(0.15), radius: 5, y: 2)

            // Label (optional - hidden in strip/compact modes)
            if showLabel {
                Text(portal.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
        }
        .frame(width: showLabel ? size * 1.7 : size * 1.3)
    }

    // MARK: - Micro-Actions (horizontal bar above orb)

    private var radialMicroActions: some View {
        Group {
            if showConstellationPicker {
                // Constellation picker REPLACES main menu
                constellationOrbitalPicker
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Main action buttons (horizontal)
                HStack(spacing: 8) {
                    // Constellation toggle button
                    if !constellations.isEmpty || onCreateConstellation != nil {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showConstellationPicker = true
                                pauseAutoDismiss()
                            }
                        } label: {
                            Image(systemName: portalConstellationIDs.isEmpty ? "sparkle" : "sparkles")
                                .font(.title3)
                                .symbolVariant(.circle.fill)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                    }

                    // Pin button
                    if onTogglePin != nil {
                        Button {
                            onTogglePin?()
                            scheduleMicroActionsDismiss()
                        } label: {
                            Image(systemName: portal.isPinned ? "mappin.slash" : "mappin")
                                .font(.title3)
                                .symbolVariant(.circle.fill)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                    }

                    // Edit button
                    if let onEdit {
                        Button {
                            dismissMicroActions()
                            onEdit()
                        } label: {
                            Image(systemName: "pencil")
                                .font(.title3)
                                .symbolVariant(.circle.fill)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                    }

                    // Delete button
                    if let onDelete {
                        Button {
                            dismissMicroActions()
                            onDelete()
                        } label: {
                            Image(systemName: "trash")
                                .font(.title3)
                                .symbolVariant(.circle.fill)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                    }

                    // Done button (green checkmark)
                    Button {
                        dismissMicroActions()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .symbolVariant(.circle.fill)
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                #if os(visionOS)
                .glassBackgroundEffect(in: Capsule())
                #else
                .background(.regularMaterial, in: Capsule())
                #endif
            }
        }
    }

    // MARK: - Constellation Orbital Picker (horizontal bar above orb)

    private var constellationOrbitalPicker: some View {
        HStack(spacing: 8) {
            // Scrollable constellation buttons (max 5 visible)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(constellations) { constellation in
                        constellationButton(for: constellation)
                    }
                }
            }
            .frame(maxWidth: 5 * 32) // ~5 buttons visible

            // Add new constellation
            if let onCreateConstellation {
                Button {
                    dismissMicroActions()
                    onCreateConstellation()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .symbolVariant(.circle)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        #if os(visionOS)
        .glassBackgroundEffect(in: Capsule())
        #else
        .background(.regularMaterial, in: Capsule())
        #endif
    }

    /// Individual constellation button - uses constellation's color when assigned
    private func constellationButton(for constellation: Constellation) -> some View {
        let isAssigned = portalConstellationIDs.contains(constellation.id)

        return Button {
            onToggleConstellation?(constellation)
        } label: {
            Image(systemName: constellation.icon)
                .font(.title3)
                .symbolVariant(isAssigned ? .circle.fill : .circle)
                .foregroundStyle(isAssigned ? constellation.color : .secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Micro-Actions Timer

    private func scheduleMicroActionsDismiss(after delay: TimeInterval = 6.0) {
        microActionsWorkItem?.cancel()
        let workItem = DispatchWorkItem { [self] in
            dismissMicroActions()
        }
        microActionsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func pauseAutoDismiss() {
        microActionsWorkItem?.cancel()
        microActionsWorkItem = nil
    }

    private func dismissMicroActions() {
        microActionsWorkItem?.cancel()
        microActionsWorkItem = nil
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showMicroActions = false
            showConstellationPicker = false
        }
    }

    // MARK: - Orb Content

    @ViewBuilder
    private var orbContent: some View {
        if portal.useCustomStyle && portal.keepFaviconWithCustomStyle,
           let thumbnailData = portal.displayThumbnail,
           let uiImage = UIImage(data: thumbnailData) {
            // Custom style with kept favicon
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.45, height: size * 0.45)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: size * 0.5, height: size * 0.5)
                )
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 3, y: 1)
                .saturation(shouldDesaturateContent ? 0 : 1)
        } else if portal.useCustomStyle {
            // Custom style - show icon or initials based on toggle
            if portal.useIconInsteadOfInitials {
                Image(systemName: portal.displayIcon)
                    .font(.system(size: size * 0.32, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: effectiveColor.opacity(0.8 * colorOpacity), radius: 4)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
            } else {
                Text(portal.displayInitials)
                    .font(.system(size: portal.displayInitials.count > 1 ? size * 0.24 : size * 0.32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: effectiveColor.opacity(0.8 * colorOpacity), radius: 4)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
            }
        } else if let thumbnailData = portal.displayThumbnail,
           let uiImage = UIImage(data: thumbnailData) {
            // Show favicon/thumbnail
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.45, height: size * 0.45)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: size * 0.5, height: size * 0.5)
                )
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 3, y: 1)
                .saturation(shouldDesaturateContent ? 0 : 1)
        } else if portal.type != .web {
            // Non-web portals (iCloud, folder, PDF, etc.) - show type icon
            Image(systemName: portal.type.iconName)
                .font(.system(size: size * 0.32, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: effectiveColor.opacity(0.8 * colorOpacity), radius: 4)
                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
        } else {
            // Web portals without favicon - first letter
            Text(portal.name.prefix(1).uppercased())
                .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: effectiveColor.opacity(0.8 * colorOpacity), radius: 4)
                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    PortalOrbView(portal: Portal.sample, onOpen: {})
        .padding()
}

#Preview("Different Colors") {
    HStack(spacing: 20) {
        PortalOrbView(portal: Portal.sample, accentColor: .blue, onOpen: {})
        PortalOrbView(portal: Portal.sample, accentColor: .purple, onOpen: {})
        PortalOrbView(portal: Portal.sample, accentColor: .green, onOpen: {})
        PortalOrbView(portal: Portal.sample, accentColor: .orange, onOpen: {})
    }
    .padding()
}

#Preview("Sizes") {
    HStack(spacing: 30) {
        PortalOrbView(portal: Portal.sample, size: 48, onOpen: {})
        PortalOrbView(portal: Portal.sample, size: 64, onOpen: {})
        PortalOrbView(portal: Portal.sample, size: 80, onOpen: {})
    }
    .padding()
}
