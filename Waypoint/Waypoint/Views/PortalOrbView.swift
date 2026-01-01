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
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    accentColor.opacity(0.25),
                                    accentColor.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: size * 0.4,
                                endRadius: size * 0.8
                            )
                        )
                        .frame(width: size * 1.5, height: size * 1.5)

                    // Glass sphere base
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    accentColor.opacity(0.15),
                                    accentColor.opacity(0.3)
                                ],
                                center: .topLeading,
                                startRadius: size * 0.05,
                                endRadius: size * 0.6
                            )
                        )
                        .frame(width: size, height: size)
                        .overlay(
                            // Glass highlight rim
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.5),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: accentColor.opacity(0.3), radius: 8, y: 3)

                    // Content: Favicon or Letter
                    orbContent
                }
                .frame(width: size * 1.5, height: size * 1.5)

                // Label
                Text(portal.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .frame(width: size * 1.6)
    }

    // MARK: - Orb Content

    @ViewBuilder
    private var orbContent: some View {
        if let thumbnailData = portal.displayThumbnail,
           let uiImage = UIImage(data: thumbnailData) {
            // Show favicon/thumbnail
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.5, height: size * 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            // Fallback: First letter
            Text(portal.name.prefix(1).uppercased())
                .font(.system(size: size * 0.35, weight: .semibold, design: .rounded))
                .foregroundStyle(accentColor)
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
