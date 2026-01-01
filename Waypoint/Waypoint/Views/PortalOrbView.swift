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
    var size: CGFloat = 64
    let onOpen: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: onOpen) {
            VStack(spacing: 8) {
                // Glass sphere orb
                ZStack {
                    // Outer glow - ambient light effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accentColor.opacity(0.3),
                                    accentColor.opacity(0.12),
                                    accentColor.opacity(0.03),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: size * 0.35,
                                endRadius: size * 0.85
                            )
                        )
                        .frame(width: size * 1.6, height: size * 1.6)

                    // Main sphere body - deeper 3D gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accentColor.opacity(0.2),
                                    accentColor.opacity(0.35),
                                    accentColor.opacity(0.5),
                                    accentColor.opacity(0.6)
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
                .shadow(color: accentColor.opacity(0.35), radius: 10, y: 4)
                .shadow(color: Color.black.opacity(0.15), radius: 5, y: 2)

                // Label
                Text(portal.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .frame(width: size * 1.7)
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
        } else {
            // Fallback: First letter with enhanced visibility
            Text(portal.name.prefix(1).uppercased())
                .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: accentColor.opacity(0.8), radius: 4)
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
