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

    let initialPortal: Portal?

    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColorHex: String = "#007AFF"
    @State private var hasCustomName: Bool = false

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
        "star.fill", "heart.fill", "bolt.fill", "flame.fill", "sparkles",
        "moon.fill", "sun.max.fill", "leaf.fill", "briefcase.fill", "book.fill",
        "gamecontroller.fill", "music.note", "film.fill", "camera.fill", "house.fill"
    ]

    // MARK: - Icon to Name Mapping

    private let iconNameSuggestions: [String: String] = [
        "star.fill": "Favorites",
        "heart.fill": "Personal",
        "bolt.fill": "Quick Access",
        "flame.fill": "Hot",
        "sparkles": "AI Tools",
        "moon.fill": "Night Mode",
        "sun.max.fill": "Morning",
        "cloud.fill": "Cloud",
        "leaf.fill": "Nature",
        "drop.fill": "Essentials",
        "briefcase.fill": "Work",
        "book.fill": "Reading",
        "gamecontroller.fill": "Gaming",
        "music.note": "Music",
        "film.fill": "Entertainment",
        "camera.fill": "Photos",
        "paintbrush.fill": "Creative",
        "hammer.fill": "Tools",
        "gearshape.fill": "Settings",
        "house.fill": "Home"
    ]

    // MARK: - Color Options

    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#00C7BE"
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
        if let portal = initialPortal {
            portalIDs.append(portal.id)
        }

        let constellation = Constellation(
            name: finalName,
            portalIDs: portalIDs,
            icon: selectedIcon,
            colorHex: selectedColorHex
        )

        constellationManager.add(constellation)
        print("✨ Created constellation: \(finalName)")
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    CreateConstellationView(initialPortal: nil)
        .environment(ConstellationManager())
}

#Preview("With Portal") {
    CreateConstellationView(initialPortal: Portal.sample)
        .environment(ConstellationManager())
}
