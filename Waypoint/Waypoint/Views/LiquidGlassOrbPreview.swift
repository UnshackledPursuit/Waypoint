//
//  LiquidGlassOrbPreview.swift
//  Waypoint
//
//  Preview file to explore Liquid Glass orb styling.
//  This simulates the liquid glass aesthetic using current visionOS APIs.
//  True .glassEffect() requires visionOS 26 SDK.
//
//  Created on January 3, 2026.
//

import SwiftUI

// MARK: - Liquid Glass Orb (Simulated)

/// A simpler, cleaner orb design inspired by Apple's Liquid Glass aesthetic.
/// Key differences from current 7-layer orb:
/// - Fewer layers (3-4 vs 7)
/// - More transparency/translucency
/// - Subtler highlights
/// - Relies more on blur/material effects
struct LiquidGlassOrb: View {

    let color: Color
    var size: CGFloat = 64
    var icon: String? = nil
    var label: String? = nil

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Layer 1: Soft outer glow (minimal)
                Circle()
                    .fill(color.opacity(0.15))
                    .blur(radius: size * 0.2)
                    .frame(width: size * 1.3, height: size * 1.3)

                // Layer 2: Glass body with material
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.4),
                                        color.opacity(0.2),
                                        color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                // Layer 3: Single specular highlight (top-left)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.0)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.25),
                            startRadius: 0,
                            endRadius: size * 0.4
                        )
                    )
                    .frame(width: size, height: size)

                // Layer 4: Subtle rim
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
                        lineWidth: 1
                    )
                    .frame(width: size, height: size)

                // Icon content
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.35, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .shadow(color: color.opacity(0.3), radius: 8, y: 4)

            // Label
            if let label {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Compact Card Orb (Icon-Only / Rectangle)

/// A compact card-style orb for collapsed/dense layouts.
/// Can be square or small rectangle.
struct CompactCardOrb: View {

    let color: Color
    var size: CGFloat = 48
    var icon: String? = nil
    var faviconURL: URL? = nil
    var isSquare: Bool = true  // false = small rectangle with mini label
    var label: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: size * 0.25)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.25)
                            .fill(color.opacity(0.25))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.25)
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )

                // Icon
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: size, height: isSquare ? size : size * 0.8)
            .shadow(color: color.opacity(0.25), radius: 4, y: 2)

            // Mini label for rectangle mode
            if !isSquare, let label {
                Text(label)
                    .font(.system(size: 9))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: size)
            }
        }
    }
}

// MARK: - Comparison Preview

struct OrbStyleComparison: View {

    let colors: [Color] = [.blue, .green, .orange, .purple, .red]
    let icons = ["globe", "star.fill", "folder.fill", "doc.fill", "play.fill"]

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {

                // Section: Liquid Glass Orbs
                VStack(spacing: 16) {
                    Text("Liquid Glass Style")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Simpler, more translucent, material-based")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 24) {
                        ForEach(0..<5) { i in
                            LiquidGlassOrb(
                                color: colors[i],
                                size: 64,
                                icon: icons[i],
                                label: "Portal \(i + 1)"
                            )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                // Section: Compact Square Cards
                VStack(spacing: 16) {
                    Text("Compact Square Cards")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Icon-only, dense grid layout")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 12) {
                        ForEach(0..<5) { i in
                            CompactCardOrb(
                                color: colors[i],
                                size: 48,
                                icon: icons[i],
                                isSquare: true
                            )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                // Section: Compact Rectangle Cards
                VStack(spacing: 16) {
                    Text("Compact Rectangle Cards")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text("Icon + mini label, collapsed list")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 12) {
                        ForEach(0..<5) { i in
                            CompactCardOrb(
                                color: colors[i],
                                size: 52,
                                icon: icons[i],
                                isSquare: false,
                                label: "Portal"
                            )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                // Section: Size Comparison
                VStack(spacing: 16) {
                    Text("Size Comparison")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 32) {
                        VStack {
                            LiquidGlassOrb(color: .blue, size: 80, icon: "globe", label: "Large")
                        }
                        VStack {
                            LiquidGlassOrb(color: .blue, size: 64, icon: "globe", label: "Medium")
                        }
                        VStack {
                            LiquidGlassOrb(color: .blue, size: 48, icon: "globe", label: "Small")
                        }
                        VStack {
                            CompactCardOrb(color: .blue, size: 40, icon: "globe", isSquare: true)
                            Text("Card")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

            }
            .padding(32)
        }
    }
}

// MARK: - Preview

#Preview("Orb Style Comparison") {
    OrbStyleComparison()
        .frame(width: 600, height: 800)
        .background(Color.black.opacity(0.8))
}

#Preview("Liquid Glass Orb") {
    HStack(spacing: 24) {
        LiquidGlassOrb(color: .blue, size: 64, icon: "globe", label: "Safari")
        LiquidGlassOrb(color: .green, size: 64, icon: "message.fill", label: "Messages")
        LiquidGlassOrb(color: .orange, size: 64, icon: "envelope.fill", label: "Mail")
    }
    .padding(40)
    .background(Color.black.opacity(0.8))
}

#Preview("Compact Cards") {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            ForEach(0..<6) { i in
                CompactCardOrb(
                    color: [Color.blue, .green, .orange, .purple, .red, .teal][i],
                    size: 44,
                    icon: ["globe", "star.fill", "folder", "doc", "play", "music.note"][i],
                    isSquare: true
                )
            }
        }

        HStack(spacing: 12) {
            ForEach(0..<6) { i in
                CompactCardOrb(
                    color: [Color.blue, .green, .orange, .purple, .red, .teal][i],
                    size: 48,
                    icon: ["globe", "star.fill", "folder", "doc", "play", "music.note"][i],
                    isSquare: false,
                    label: ["Web", "Faves", "Files", "Docs", "Media", "Music"][i]
                )
            }
        }
    }
    .padding(40)
    .background(Color.black.opacity(0.8))
}
