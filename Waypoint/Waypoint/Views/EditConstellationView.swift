//
//  EditConstellationView.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import SwiftUI

struct EditConstellationView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(ConstellationManager.self) private var constellationManager

    let constellation: Constellation

    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String
    @State private var showDeleteConfirmation = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Initialization

    init(constellation: Constellation) {
        self.constellation = constellation
        _name = State(initialValue: constellation.name)
        _selectedIcon = State(initialValue: constellation.icon)
        _selectedColorHex = State(initialValue: constellation.colorHex)
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

    // MARK: - Color Options

    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#00C7BE"
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Orb Preview
                    heroOrbPreview
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                    // Compact Form
                    VStack(spacing: 20) {
                        // Name Field with inline preview
                        nameFieldSection

                        // Icon Selection
                        iconSelectionSection

                        // Color Selection
                        colorSelectionSection

                        // Portal count info
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.secondary)
                            Text("\(constellation.portalIDs.count) portal\(constellation.portalIDs.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        // Delete button - inside scroll content with spacing
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Constellation", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Edit Constellation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConstellation()
                    }
                    .disabled(!isValid)
                }
            }
            .confirmationDialog(
                "Delete \"\(constellation.name)\"?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteConstellation()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove the constellation. Your portals will not be deleted.")
            }
        }
    }

    // MARK: - Hero Orb Preview

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
            Text(name.isEmpty ? "Constellation" : name)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Name Field Section

    private var nameFieldSection: some View {
        HStack(spacing: 12) {
            // Small inline orb preview
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
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: selectedColorHex).opacity(0.8), radius: 3)
            }

            // Name text field
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Icon Selection

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

    // MARK: - Color Selection (with Color Picker)

    private var colorSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Preset colors
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

                    // Custom color picker
                    ColorPicker("", selection: Binding(
                        get: { Color(hex: selectedColorHex) },
                        set: { newColor in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedColorHex = newColor.toHex() ?? selectedColorHex
                            }
                        }
                    ), supportsOpacity: false)
                    .labelsHidden()
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Actions

    private func saveConstellation() {
        var updated = constellation
        updated.name = name.trimmingCharacters(in: .whitespaces)
        updated.icon = selectedIcon
        updated.colorHex = selectedColorHex

        constellationManager.update(updated)
        print("✏️ Updated constellation: \(updated.name)")
        dismiss()
    }

    private func deleteConstellation() {
        constellationManager.delete(constellation)
        print("🗑️ Deleted constellation: \(constellation.name)")
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EditConstellationView(constellation: Constellation.sample)
        .environment(ConstellationManager())
}
