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

    /// The name to use - custom if user typed, otherwise auto-generated
    private var displayName: String {
        if hasCustomName && !name.isEmpty {
            return name
        }
        return iconNameSuggestions[selectedIcon] ?? "My Constellation"
    }

    // MARK: - Icon Options (2 rows worth)

    private let iconOptionsRow1 = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill", "sparkles",
        "moon.fill", "sun.max.fill", "cloud.fill", "leaf.fill", "drop.fill"
    ]

    private let iconOptionsRow2 = [
        "briefcase.fill", "book.fill", "gamecontroller.fill", "music.note", "film.fill",
        "camera.fill", "paintbrush.fill", "hammer.fill", "gearshape.fill", "house.fill"
    ]

    private var allIconOptions: [String] {
        iconOptionsRow1 + iconOptionsRow2
    }

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
            VStack(spacing: 0) {
                // Hero Orb Preview (Large - Version B)
                heroOrbPreview
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                // Compact Form (no scrolling needed)
                VStack(spacing: 20) {
                    // Name Field with inline preview (Version A option)
                    nameFieldSection

                    // Icon Selection (horizontal scroll, 2 rows)
                    iconSelectionSection

                    // Color Selection (horizontal scroll, 1 row)
                    colorSelectionSection

                    // Starting portal info
                    if let portal = initialPortal {
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.secondary)
                            Text("Starting with: \(portal.name)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)

                Spacer()
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
        VStack(spacing: 12) {
            // Glass sphere orb
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: selectedColorHex).opacity(0.3),
                                Color(hex: selectedColorHex).opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                // Glass sphere
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color(hex: selectedColorHex).opacity(0.2),
                                Color(hex: selectedColorHex).opacity(0.4)
                            ],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color(hex: selectedColorHex).opacity(0.4), radius: 10, y: 4)

                // Icon
                Image(systemName: selectedIcon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Color(hex: selectedColorHex))
            }

            // Name under orb
            Text(displayName)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Name Field Section (with small inline preview - Version A)

    private var nameFieldSection: some View {
        HStack(spacing: 12) {
            // Small inline orb preview (Version A)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color(hex: selectedColorHex).opacity(0.3)
                            ],
                            center: .topLeading,
                            startRadius: 2,
                            endRadius: 25
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: selectedIcon)
                    .font(.title3)
                    .foregroundStyle(Color(hex: selectedColorHex))
            }

            // Name text field - shows auto-suggestion, user types to replace
            TextField("Name", text: $name, prompt: Text(iconNameSuggestions[selectedIcon] ?? "Constellation Name"))
                .textFieldStyle(.roundedBorder)
                .onChange(of: name) { _, newValue in
                    hasCustomName = !newValue.isEmpty
                }
        }
    }

    // MARK: - Icon Selection (Horizontal Scroll, 2 Rows)

    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Icon")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 12) {
                    // Row 1
                    HStack(spacing: 12) {
                        ForEach(iconOptionsRow1, id: \.self) { icon in
                            iconButton(for: icon)
                        }
                    }

                    // Row 2
                    HStack(spacing: 12) {
                        ForEach(iconOptionsRow2, id: \.self) { icon in
                            iconButton(for: icon)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
    }

    private func iconButton(for icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedIcon = icon
                // Only auto-fill name if user hasn't customized it
                if !hasCustomName {
                    name = ""  // Clear to use auto-suggestion
                }
            }
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(
                    selectedIcon == icon
                        ? Color(hex: selectedColorHex).opacity(0.3)
                        : Color.secondary.opacity(0.1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(selectedIcon == icon ? 1.05 : 1.0)
    }

    // MARK: - Color Selection (Horizontal Scroll, 1 Row)

    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(colorOptions, id: \.self) { colorHex in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedColorHex = colorHex
                            }
                        } label: {
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColorHex == colorHex ? 3 : 0)
                                )
                                .shadow(
                                    color: selectedColorHex == colorHex
                                        ? Color(hex: colorHex).opacity(0.5)
                                        : .clear,
                                    radius: 6
                                )
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(selectedColorHex == colorHex ? 1.1 : 1.0)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Actions

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
