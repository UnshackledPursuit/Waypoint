//
//  ConstellationOrbView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct ConstellationOrbView: View {

    // MARK: - Properties

    let constellation: Constellation
    let isSelected: Bool
    var size: CGFloat = 44
    var showLabel: Bool = true
    var onEdit: ((Constellation) -> Void)?
    var onDelete: ((Constellation) -> Void)?

    // MARK: - Computed

    private var orbSize: CGFloat { size }
    private var iconSize: CGFloat { size * 0.4 }

    var body: some View {
        VStack(spacing: 6) {
            // Glass sphere orb with enhanced 3D effect
            ZStack {
                // Outer glow - ambient light
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                constellation.color.opacity(isSelected ? 0.35 : 0.2),
                                constellation.color.opacity(0.1),
                                constellation.color.opacity(0.03),
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
                                constellation.color.opacity(0.2),
                                constellation.color.opacity(0.35),
                                constellation.color.opacity(isSelected ? 0.55 : 0.45),
                                constellation.color.opacity(isSelected ? 0.65 : 0.5)
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
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.25),
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
                        lineWidth: 1
                    )
                    .frame(width: orbSize, height: orbSize)

                // Bottom reflection
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.clear
                            ],
                            center: UnitPoint(x: 0.6, y: 0.85),
                            startRadius: 0,
                            endRadius: orbSize * 0.2
                        )
                    )
                    .frame(width: orbSize, height: orbSize)

                // Icon with enhanced visibility
                Image(systemName: constellation.icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: constellation.color.opacity(0.9), radius: 4)
                    .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)
            }
            .frame(width: orbSize * 1.5, height: orbSize * 1.5)
            .shadow(color: constellation.color.opacity(0.3), radius: 8, y: 3)
            .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)

            if showLabel {
                Text(constellation.name)
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
        .frame(width: showLabel ? 70 : orbSize * 1.5)
        .contextMenu {
            if let onEdit = onEdit {
                Button {
                    onEdit(constellation)
                } label: {
                    Label("Edit \(constellation.name)", systemImage: "pencil")
                }
            }

            if let onDelete = onDelete {
                Divider()

                Button(role: .destructive) {
                    onDelete(constellation)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        ConstellationOrbView(constellation: .sample, isSelected: true)
        ConstellationOrbView(constellation: .sample, isSelected: false)
    }
    .padding()
}
