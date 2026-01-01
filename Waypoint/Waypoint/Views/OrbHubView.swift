//
//  OrbHubView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbHubView: View {

    // MARK: - Properties

    @Binding var selectedConstellationID: UUID?
    let constellations: [Constellation]
    let onSelect: () -> Void
    var onEditConstellation: ((Constellation) -> Void)?
    var onDeleteConstellation: ((Constellation) -> Void)?
    var onCreateConstellation: (() -> Void)?

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                selectionPill(
                    title: "All",
                    systemImage: "circle.grid.3x3.fill",
                    isSelected: selectedConstellationID == nil
                ) {
                    selectedConstellationID = nil
                    onSelect()
                }

                ForEach(constellations) { constellation in
                    selectionPill(
                        title: constellation.name,
                        systemImage: constellation.icon,
                        isSelected: selectedConstellationID == constellation.id
                    ) {
                        selectedConstellationID = constellation.id
                        onSelect()
                    }
                    .contextMenu {
                        Button {
                            onEditConstellation?(constellation)
                        } label: {
                            Label("Edit \(constellation.name)", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive) {
                            onDeleteConstellation?(constellation)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                // Add new constellation button
                if let onCreate = onCreateConstellation {
                    Button {
                        onCreate()
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 44)
    }

    // MARK: - UI

    private func selectionPill(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .lineLimit(1)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.secondarySystemFill))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    OrbHubView(
        selectedConstellationID: .constant(nil),
        constellations: Constellation.samples,
        onSelect: {},
        onCreateConstellation: {}
    )
    .padding()
}
