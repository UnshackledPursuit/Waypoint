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

    let initialConstellation: Constellation

    @State private var selectedConstellationID: UUID
    @State private var name: String
    @State private var selectedIcon: String
    @State private var selectedColorHex: String
    @State private var showDeleteConfirmation = false

    private var selectedConstellation: Constellation? {
        constellationManager.constellation(withID: selectedConstellationID)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Initialization

    init(constellation: Constellation) {
        self.initialConstellation = constellation
        _selectedConstellationID = State(initialValue: constellation.id)
        _name = State(initialValue: constellation.name)
        _selectedIcon = State(initialValue: constellation.icon)
        _selectedColorHex = State(initialValue: constellation.colorHex)
    }

    // MARK: - Icon Options (single row)

    private let iconOptions = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill", "sparkles",
        "moon.fill", "sun.max.fill", "leaf.fill", "briefcase.fill", "book.fill",
        "gamecontroller.fill", "music.note", "film.fill", "camera.fill", "house.fill"
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
                    // Constellation Picker (if multiple constellations exist)
                    if constellationManager.constellations.count > 1 {
                        constellationPicker
                    }

                    // Hero Orb Preview with name
                    heroOrbPreview
                        .padding(.top, 8)

                    // Name Field - simple
                    TextField("Constellation Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    // Icon and Color in compact sections
                    VStack(spacing: 12) {
                        iconSelectionSection
                        colorSelectionSection
                    }
                    .padding(.horizontal)

                    // Footer info and delete
                    VStack(spacing: 16) {
                        if let constellation = selectedConstellation {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundStyle(.tertiary)
                                Text("\(constellation.portalIDs.count) portal\(constellation.portalIDs.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                Spacer()
                            }
                        }

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Text("Delete Constellation")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
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
                "Delete \"\(selectedConstellation?.name ?? "")\"?",
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

    // MARK: - Constellation Picker

    private var constellationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with drag hint
            HStack {
                Text("Constellations")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Spacer()
                Text("Drag to Reorder")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(constellationManager.constellations) { constellation in
                        constellationPickerItem(constellation)
                            .draggable(constellation.id.uuidString) {
                                // Drag preview orb
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    constellation.color.opacity(0.6),
                                                    constellation.color.opacity(0.9)
                                                ],
                                                center: UnitPoint(x: 0.3, y: 0.3),
                                                startRadius: 0,
                                                endRadius: 22
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    Image(systemName: constellation.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .dropDestination(for: String.self) { items, _ in
                                guard let draggedIDString = items.first,
                                      let draggedID = UUID(uuidString: draggedIDString),
                                      draggedID != constellation.id else {
                                    return false
                                }
                                constellationManager.moveConstellation(draggedID, before: constellation.id)
                                return true
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }

    private func constellationPickerItem(_ constellation: Constellation) -> some View {
        let isSelected = constellation.id == selectedConstellationID

        return Button {
            switchToConstellation(constellation)
        } label: {
            VStack(spacing: 6) {
                // Beautiful glass orb
                ZStack {
                    // Glow behind selected
                    if isSelected {
                        Circle()
                            .fill(constellation.color.opacity(0.3))
                            .frame(width: 52, height: 52)
                            .blur(radius: 6)
                    }

                    // Main orb with gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    constellation.color.opacity(isSelected ? 0.5 : 0.3),
                                    constellation.color.opacity(isSelected ? 0.85 : 0.55)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 22
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                        )

                    // Top highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                center: UnitPoint(x: 0.35, y: 0.3),
                                startRadius: 0,
                                endRadius: 12
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: constellation.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                }
                .frame(width: 52, height: 52)

                Text(constellation.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .frame(width: 60)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Switch Constellation

    private func switchToConstellation(_ constellation: Constellation) {
        guard constellation.id != selectedConstellationID else { return }

        // Save current constellation changes first (if valid)
        if isValid, let current = selectedConstellation {
            var updated = current
            updated.name = name.trimmingCharacters(in: .whitespaces)
            updated.icon = selectedIcon
            updated.colorHex = selectedColorHex
            constellationManager.update(updated)
            print("💾 Auto-saved: \(updated.name)")
        }

        // Switch to new constellation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedConstellationID = constellation.id
            name = constellation.name
            selectedIcon = constellation.icon
            selectedColorHex = constellation.colorHex
        }
        print("🔄 Switched to: \(constellation.name)")
    }

    // MARK: - Hero Orb Preview

    private var heroOrbPreview: some View {
        let orbSize: CGFloat = 80  // Larger hero orb
        let color = Color(hex: selectedColorHex)

        return VStack(spacing: 12) {
            // Beautiful glass sphere orb
            ZStack {
                // Outer glow - ambient light
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.4),
                                color.opacity(0.2),
                                color.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: orbSize * 0.3,
                            endRadius: orbSize * 1.0
                        )
                    )
                    .frame(width: orbSize * 1.6, height: orbSize * 1.6)

                // Main sphere body - deeper 3D gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.25),
                                color.opacity(0.45),
                                color.opacity(0.65),
                                color.opacity(0.8)
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
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.12)
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
                            endRadius: orbSize * 0.2
                        )
                    )
                    .frame(width: orbSize, height: orbSize)

                // Icon with enhanced visibility
                Image(systemName: selectedIcon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: color.opacity(0.9), radius: 6)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
            }
            .frame(width: orbSize * 1.6, height: orbSize * 1.6)
            .shadow(color: color.opacity(0.4), radius: 12, y: 4)
            .shadow(color: Color.black.opacity(0.1), radius: 6, y: 3)

            // Name under orb
            Text(name.isEmpty ? "Constellation" : name)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Icon Selection

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

    // MARK: - Color Selection

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

    // MARK: - Actions

    private func saveConstellation() {
        guard let constellation = selectedConstellation else { return }

        var updated = constellation
        updated.name = name.trimmingCharacters(in: .whitespaces)
        updated.icon = selectedIcon
        updated.colorHex = selectedColorHex

        constellationManager.update(updated)
        print("✏️ Updated constellation: \(updated.name)")
        dismiss()
    }

    private func deleteConstellation() {
        guard let constellation = selectedConstellation else { return }

        let deletedName = constellation.name
        constellationManager.delete(constellation)
        print("🗑️ Deleted constellation: \(deletedName)")

        // If there are remaining constellations, switch to the first one
        if let firstRemaining = constellationManager.constellations.first {
            selectedConstellationID = firstRemaining.id
            name = firstRemaining.name
            selectedIcon = firstRemaining.icon
            selectedColorHex = firstRemaining.colorHex
        } else {
            // No constellations left, dismiss
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    EditConstellationView(constellation: Constellation.sample)
        .environment(ConstellationManager())
}
