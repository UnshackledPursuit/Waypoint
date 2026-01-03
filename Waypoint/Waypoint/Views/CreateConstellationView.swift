//
//  CreateConstellationView.swift
//  Waypoint
//
//  Created on December 29, 2024.
//

import SwiftUI

struct CreateConstellationView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(ConstellationManager.self) private var constellationManager
    @Environment(PortalManager.self) private var portalManager

    let initialPortal: Portal?

    @State private var name: String = ""
    @State private var selectedIcon: String = "sparkles"
    @State private var selectedColorHex: String = "#007AFF"
    @State private var hasCustomName: Bool = false
    @State private var selectedPortalIDs: Set<UUID> = []

    /// Portals to show for selection - prioritize ungrouped, then recent (max 8)
    private var suggestedPortals: [Portal] {
        let allPortals = portalManager.portals.filter { $0.id != initialPortal?.id }

        // Find portals not in any constellation
        let ungroupedPortals = allPortals.filter { portal in
            !constellationManager.constellations.contains { $0.portalIDs.contains(portal.id) }
        }

        // Start with ungrouped portals
        var result = ungroupedPortals

        // Fill remaining slots with other portals (most recently used)
        let remaining = allPortals.filter { !ungroupedPortals.contains($0) }
        result.append(contentsOf: remaining)

        return Array(result.prefix(8))
    }

    private var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Existing constellations the portal can be added to (not already in)
    private var availableConstellations: [Constellation] {
        guard let portal = initialPortal else { return [] }
        return constellationManager.constellations.filter { !$0.portalIDs.contains(portal.id) }
    }

    /// The name to use - custom if user typed, otherwise auto-generated
    private var displayName: String {
        if hasCustomName && !name.isEmpty {
            return name
        }
        return iconNameSuggestions[selectedIcon] ?? "My Constellation"
    }

    // MARK: - Icon Options (single row - matches EditConstellationView)

    private let iconOptions = [
        "sparkles", "heart.fill", "bolt.fill", "flame.fill", "moon.fill",
        "sun.max.fill", "leaf.fill", "briefcase.fill", "book.fill",
        "gamecontroller.fill", "music.note", "film.fill", "wand.and.stars", "house.fill"
    ]

    // MARK: - Icon to Name Mapping

    private let iconNameSuggestions: [String: String] = [
        "sparkles": "Collection",
        "heart.fill": "Saved",
        "bolt.fill": "Quick Access",
        "flame.fill": "Trending",
        "moon.fill": "Night Owl",
        "sun.max.fill": "Daily",
        "leaf.fill": "Wellness",
        "briefcase.fill": "Work",
        "book.fill": "Articles",
        "gamecontroller.fill": "Gaming",
        "music.note": "Music",
        "film.fill": "Watch",
        "wand.and.stars": "Creative",
        "house.fill": "Home"
    ]

    // MARK: - Color Options

    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#FFCC00", "#5856D6", "#00C7BE", "#1C1C1E"
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Quick Add to Existing (only if portal provided)
                    if initialPortal != nil && !constellationManager.constellations.isEmpty {
                        if availableConstellations.isEmpty {
                            // Portal is already in all constellations
                            Text("Already in all constellations")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                        } else {
                            quickAddSection
                        }

                        // Divider between quick add and create new
                        HStack {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 1)
                            Text("or create new")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal)
                    }

                    // Hero Orb Preview with name
                    heroOrbPreview
                        .padding(.top, 8)

                    // Name Field - simple (matches EditConstellationView)
                    TextField("Constellation Name", text: $name, prompt: Text(iconNameSuggestions[selectedIcon] ?? "Constellation Name"))
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onChange(of: name) { _, newValue in
                            hasCustomName = !newValue.isEmpty
                        }

                    // Icon and Color in compact sections (matches EditConstellationView)
                    VStack(spacing: 12) {
                        iconSelectionSection
                        colorSelectionSection
                    }
                    .padding(.horizontal)

                    // Portal picker - show when creating without initial portal
                    if initialPortal == nil && !suggestedPortals.isEmpty {
                        portalPickerSection
                    }

                    // Footer info
                    VStack(spacing: 16) {
                        if let portal = initialPortal {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundStyle(.tertiary)
                                Text("Starting with: \(portal.name)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                Spacer()
                            }
                        } else if !selectedPortalIDs.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text("\(selectedPortalIDs.count) portal\(selectedPortalIDs.count == 1 ? "" : "s") selected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("New Constellation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createConstellation()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Hero Orb Preview (Large - Version B)

    private var heroOrbPreview: some View {
        let orbSize: CGFloat = 80
        let color = Color(hex: selectedColorHex)

        return VStack(spacing: 12) {
            // Glass sphere orb with enhanced 3D effect
            ZStack {
                // Outer glow - ambient light
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.35),
                                color.opacity(0.15),
                                color.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: orbSize * 0.4,
                            endRadius: orbSize * 0.9
                        )
                    )
                    .frame(width: orbSize * 1.5, height: orbSize * 1.5)

                // Main sphere body - deeper 3D gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.2),
                                color.opacity(0.4),
                                color.opacity(0.55),
                                color.opacity(0.65)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.25),
                            startRadius: orbSize * 0.05,
                            endRadius: orbSize * 0.55
                        )
                    )
                    .frame(width: orbSize, height: orbSize)

                // Top-left specular highlight
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
                            endRadius: orbSize * 0.35
                        )
                    )
                    .frame(width: orbSize, height: orbSize)

                // Rim light
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
                    .frame(width: orbSize, height: orbSize)

                // Bottom reflection
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ],
                            center: UnitPoint(x: 0.6, y: 0.85),
                            startRadius: 0,
                            endRadius: orbSize * 0.25
                        )
                    )
                    .frame(width: orbSize, height: orbSize)

                // Icon with enhanced visibility
                Image(systemName: selectedIcon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: color.opacity(0.9), radius: 6)
                    .shadow(color: Color.black.opacity(0.25), radius: 3, y: 1)

                // Glass inner reflection arc
                Circle()
                    .trim(from: 0.1, to: 0.4)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: orbSize * 0.65, height: orbSize * 0.65)
                    .rotationEffect(.degrees(-30))
            }
            .frame(width: orbSize * 1.5, height: orbSize * 1.5)
            .shadow(color: color.opacity(0.4), radius: 12, y: 5)
            .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)

            // Name under orb
            Text(displayName)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }


    // MARK: - Icon Selection (matches EditConstellationView)

    private var iconSelectionSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(iconOptions, id: \.self) { icon in
                    iconButton(for: icon)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func iconButton(for icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedIcon = icon
                // Only auto-fill name if user hasn't customized it
                if !hasCustomName {
                    name = ""  // Clear to use auto-suggestion
                }
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
                .background(
                    selectedIcon == icon
                        ? Color(hex: selectedColorHex).opacity(0.4)
                        : Color.secondary.opacity(0.1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Color Selection (matches EditConstellationView)

    private var colorSelectionSection: some View {
        VStack(spacing: 8) {
            // Centered color orbs with glass effects
            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { colorHex in
                    colorOrbButton(for: colorHex)
                }

                // Custom color picker styled as orb
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                center: .center
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        center: UnitPoint(x: 0.3, y: 0.3),
                                        startRadius: 0,
                                        endRadius: 15
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 4, y: 2)

                    ColorPicker("", selection: Binding(
                        get: { Color(hex: selectedColorHex) },
                        set: { newColor in
                            selectedColorHex = newColor.toHex() ?? selectedColorHex
                        }
                    ), supportsOpacity: false)
                    .labelsHidden()
                    .opacity(0.02)  // Nearly invisible but tappable
                }
                .frame(width: 40, height: 40)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func colorOrbButton(for colorHex: String) -> some View {
        let color = Color(hex: colorHex)
        let isSelected = selectedColorHex == colorHex

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedColorHex = colorHex
            }
        } label: {
            ZStack {
                // Glow behind selected
                if isSelected {
                    Circle()
                        .fill(color.opacity(0.4))
                        .frame(width: 48, height: 48)
                        .blur(radius: 6)
                }

                // Main color orb with gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.6),
                                color.opacity(0.85),
                                color
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)

                // Top highlight for glass effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.5), Color.clear],
                            center: UnitPoint(x: 0.35, y: 0.25),
                            startRadius: 0,
                            endRadius: 12
                        )
                    )
                    .frame(width: 40, height: 40)

                // Selection ring
                Circle()
                    .stroke(
                        isSelected ? Color.white : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 3 : 1
                    )
                    .frame(width: 40, height: 40)
            }
            .frame(width: 48, height: 48)
            .shadow(color: color.opacity(isSelected ? 0.5 : 0.2), radius: isSelected ? 6 : 3, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Portal Picker Section

    private var portalPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Add portals")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal)

            // Scrollable orb picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(suggestedPortals) { portal in
                        portalOrbButton(for: portal)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .padding(.top, 8)
    }

    private func portalOrbButton(for portal: Portal) -> some View {
        let isSelected = selectedPortalIDs.contains(portal.id)
        let color = colorForURL(portal.url)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                if isSelected {
                    selectedPortalIDs.remove(portal.id)
                } else {
                    selectedPortalIDs.insert(portal.id)
                }
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    // Selection glow
                    if isSelected {
                        Circle()
                            .fill(Color(hex: selectedColorHex).opacity(0.4))
                            .frame(width: 56, height: 56)
                            .blur(radius: 8)
                    }

                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 12,
                                endRadius: 26
                            )
                        )
                        .frame(width: 48, height: 48)

                    // Glass orb background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)

                    // Favicon or fallback letter
                    AsyncImage(url: faviconURL(for: portal.url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                        case .failure, .empty:
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [color.opacity(0.6), color.opacity(0.85)],
                                            center: UnitPoint(x: 0.3, y: 0.25),
                                            startRadius: 0,
                                            endRadius: 13
                                        )
                                    )
                                    .frame(width: 26, height: 26)
                                Text(String(portal.name.prefix(1)).uppercased())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }

                    // Glass highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                center: UnitPoint(x: 0.25, y: 0.2),
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 40, height: 40)

                    // Rim light
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isSelected ? 0.6 : 0.4),
                                    Color.white.opacity(isSelected ? 0.3 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 2 : 0.5
                        )
                        .frame(width: 40, height: 40)

                    // Selection checkmark badge
                    if isSelected {
                        Circle()
                            .fill(Color(hex: selectedColorHex))
                            .frame(width: 18, height: 18)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .offset(x: 16, y: -16)
                    }
                }
                .frame(width: 52, height: 52)
                .shadow(color: isSelected ? Color(hex: selectedColorHex).opacity(0.4) : color.opacity(0.3), radius: isSelected ? 8 : 4, y: 2)

                // Portal name
                Text(portal.name)
                    .font(.caption2)
                    .fontWeight(isSelected ? .medium : .regular)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                    .frame(width: 56)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - URL Helpers

    private func faviconURL(for urlString: String) -> URL? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }
        return URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    private func colorForURL(_ urlString: String) -> Color {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return .blue
        }
        return Color.fromHost(host)
    }

    // MARK: - Quick Add Section

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add to existing")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableConstellations) { constellation in
                        quickAddButton(for: constellation)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }

    private func quickAddButton(for constellation: Constellation) -> some View {
        Button {
            addToExisting(constellation)
        } label: {
            VStack(spacing: 6) {
                // Mini orb with constellation color
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    constellation.color.opacity(0.3),
                                    constellation.color.opacity(0.6)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 20
                            )
                        )
                        .frame(width: 44, height: 44)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.5), Color.clear],
                                center: UnitPoint(x: 0.3, y: 0.25),
                                startRadius: 0,
                                endRadius: 15
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: constellation.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: constellation.color.opacity(0.8), radius: 3)
                }
                .shadow(color: constellation.color.opacity(0.3), radius: 4, y: 2)

                Text(constellation.name)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(width: 60)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func addToExisting(_ constellation: Constellation) {
        guard let portal = initialPortal else { return }
        constellationManager.addPortal(portal.id, to: constellation)
        print("✨ Added \(portal.name) to \(constellation.name)")
        dismiss()
    }

    private func createConstellation() {
        let finalName = displayName.trimmingCharacters(in: .whitespaces)

        var portalIDs: [UUID] = []

        // Add initial portal if provided
        if let portal = initialPortal {
            portalIDs.append(portal.id)
        }

        // Add selected portals from picker
        portalIDs.append(contentsOf: selectedPortalIDs)

        let constellation = Constellation(
            name: finalName,
            portalIDs: portalIDs,
            icon: selectedIcon,
            colorHex: selectedColorHex
        )

        constellationManager.add(constellation)
        print("✨ Created constellation: \(finalName) with \(portalIDs.count) portals")
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    CreateConstellationView(initialPortal: nil)
        .environment(ConstellationManager())
        .environment(PortalManager())
}

#Preview("With Portal") {
    CreateConstellationView(initialPortal: Portal.sample)
        .environment(ConstellationManager())
        .environment(PortalManager())
}
