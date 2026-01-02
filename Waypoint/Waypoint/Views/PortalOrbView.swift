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
        ZStack {
            // Main orb content
            orbBody
                .contentShape(Circle())
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
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showMicroActions = true
                                showConstellationPicker = false
                            }
                            scheduleMicroActionsDismiss()
                        }
                )

            // Radial arc micro-actions overlay
            if showMicroActions {
                radialMicroActions
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: size * 1.7, height: showMicroActions ? size * 2.8 : size * 1.8 + 20)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showMicroActions)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showConstellationPicker)
    }

    // MARK: - Orb Body

    private var orbBody: some View {
        VStack(spacing: 8) {
            // Glass sphere orb
            ZStack {
                // Outer glow - ambient light effect (intensity affects glow strength)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                effectiveColor.opacity(0.3 * colorOpacity),
                                effectiveColor.opacity(0.12 * colorOpacity),
                                effectiveColor.opacity(0.03 * colorOpacity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.35,
                            endRadius: size * 0.85
                        )
                    )
                    .frame(width: size * 1.6, height: size * 1.6)

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

            // Label
            Text(portal.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .frame(width: size * 1.7)
    }

    // MARK: - Radial Micro-Actions

    private var radialMicroActions: some View {
        VStack(spacing: 8) {
            // Constellation picker (expands above actions)
            if showConstellationPicker {
                constellationOrbitalPicker
                    .transition(.scale.combined(with: .opacity))
            }

            // Action arc - positioned below the orb
            HStack(spacing: 10) {
                // Constellation toggle
                if !constellations.isEmpty || onCreateConstellation != nil {
                    microActionButton(
                        icon: portalConstellationIDs.isEmpty ? "sparkle" : "sparkles",
                        color: .purple
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showConstellationPicker.toggle()
                            if showConstellationPicker {
                                pauseAutoDismiss()
                            } else {
                                scheduleMicroActionsDismiss()
                            }
                        }
                    }
                }

                // Pin toggle
                if let onTogglePin {
                    microActionButton(
                        icon: portal.isPinned ? "pin.slash.fill" : "pin.fill",
                        color: .orange
                    ) {
                        onTogglePin()
                        scheduleMicroActionsDismiss()
                    }
                }

                // Edit
                if let onEdit {
                    microActionButton(
                        icon: "pencil",
                        color: .blue
                    ) {
                        dismissMicroActions()
                        onEdit()
                    }
                }

                // Delete
                if let onDelete {
                    microActionButton(
                        icon: "trash",
                        color: .red
                    ) {
                        dismissMicroActions()
                        onDelete()
                    }
                }

                // Done/dismiss
                microActionButton(
                    icon: "checkmark",
                    color: .green
                ) {
                    dismissMicroActions()
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
        .offset(y: size * 0.9 + 20) // Position below the orb
    }

    @ViewBuilder
    private func microActionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Constellation Orbital Picker

    private var constellationOrbitalPicker: some View {
        HStack(spacing: 12) {
            ForEach(constellations) { constellation in
                let isAssigned = portalConstellationIDs.contains(constellation.id)

                Button {
                    onToggleConstellation?(constellation)
                    // Don't dismiss, allow multiple toggles
                } label: {
                    ZStack {
                        Circle()
                            .fill(constellation.color.opacity(isAssigned ? 1.0 : 0.6))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(isAssigned ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: constellation.color.opacity(isAssigned ? 0.5 : 0.2), radius: isAssigned ? 4 : 2)

                        Image(systemName: constellation.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)

                        // Checkmark badge when assigned
                        if isAssigned {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .offset(x: 10, y: 10)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            // Add new constellation
            if let onCreateConstellation {
                Button {
                    dismissMicroActions()
                    onCreateConstellation()
                } label: {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        #if os(visionOS)
        .glassBackgroundEffect(in: Capsule())
        #else
        .background(.regularMaterial, in: Capsule())
        #endif
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
        if let thumbnailData = portal.displayThumbnail,
           let uiImage = UIImage(data: thumbnailData) {
            // Show favicon/thumbnail with visibility enhancements
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
                .saturation(shouldDesaturateContent ? 0 : 1) // Grayscale in mono mode
        } else {
            // Fallback: First letter with enhanced visibility
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
