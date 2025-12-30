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

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Icon Options

    private let iconOptions = [
        "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "sunrise.fill", "moon.fill", "cloud.fill", "sparkles",
        "laptopcomputer", "desktopcomputer", "book.fill", "newspaper.fill",
        "gamecontroller.fill", "music.note", "film.fill", "camera.fill",
        "paintbrush.fill", "hammer.fill", "wrench.fill", "gearshape.fill"
    ]

    // MARK: - Color Options

    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#00C7BE"
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name, prompt: Text("Morning Routine"))
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color(hex: selectedColorHex).opacity(0.3) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Button {
                                selectedColorHex = colorHex
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColorHex == colorHex ? 3 : 0)
                                    )
                                    .shadow(color: selectedColorHex == colorHex ? Color(hex: colorHex).opacity(0.5) : .clear, radius: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Preview") {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: selectedColorHex).opacity(0.2))
                                .frame(width: 50, height: 50)

                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundStyle(Color(hex: selectedColorHex))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.isEmpty ? "Constellation Name" : name)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)

                            if let portal = initialPortal {
                                Text("Starting with: \(portal.name)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("0 portals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
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

    // MARK: - Actions

    private func createConstellation() {
        let cleanedName = name.trimmingCharacters(in: .whitespaces)

        var portalIDs: [UUID] = []
        if let portal = initialPortal {
            portalIDs.append(portal.id)
        }

        let constellation = Constellation(
            name: cleanedName,
            portalIDs: portalIDs,
            icon: selectedIcon,
            colorHex: selectedColorHex
        )

        constellationManager.add(constellation)
        print("✨ Created constellation: \(cleanedName)")
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    CreateConstellationView(initialPortal: nil)
        .environment(ConstellationManager())
}
