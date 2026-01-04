//
//  OrbStyleCatalog.swift
//  Waypoint
//
//  Debug catalog showing all orb style variations across the app.
//  Use this to compare styles and identify the best designs.
//
//  Created on January 3, 2026.
//

import SwiftUI

// MARK: - Orb Style Catalog

struct OrbStyleCatalog: View {
    @Environment(\.dismiss) private var dismiss

    // Sample colors for demonstrations
    private let sampleColors: [Color] = [
        .blue, .green, .orange, .purple, .red, .teal, .cyan, .yellow,
        Color(red: 0.1, green: 0.1, blue: 0.1)  // Near-black
    ]

    // Sample icons for comparison
    private let sampleIcons = ["globe", "star.fill", "heart.fill", "bolt.fill", "sparkles", "flame.fill"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Final Comparison (Top Candidates)
                    Text("FINAL COMPARISON - TOP CANDIDATES")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal)

                    finalComparisonSection(
                        title: "Frosted Material",
                        subtitle: "User feedback: Looks great ⭐",
                        ranking: 1
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<6) { i in
                                    FrostedOrb(color: sampleColors[i], icon: sampleIcons[i], size: 64)
                                }
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Deep Glass",
                        subtitle: "User feedback: Pretty good",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<6) { i in
                                    DeepGlassOrb(color: sampleColors[i], icon: sampleIcons[i], size: 64)
                                }
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Lifted Icons",
                        subtitle: "User feedback: Pretty good",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<6) { i in
                                    LiftedIconOrb(color: sampleColors[i], icon: sampleIcons[i], size: 64)
                                }
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Convex Bubble",
                        subtitle: "User feedback: Not bad",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<6) { i in
                                    ConvexBubbleOrb(color: sampleColors[i], icon: sampleIcons[i], size: 64)
                                }
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Constellation Style",
                        subtitle: "User feedback: Very good",
                        ranking: 1
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<6) { i in
                                    ConstellationStyleOrb(color: sampleColors[i], icon: sampleIcons[i], size: 64)
                                }
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Pack Header Style",
                        subtitle: "User feedback: Looks good (shown at native 28pt + scaled 48pt)",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<6) { i in
                                    PackHeaderStyleOrb(color: sampleColors[i], icon: sampleIcons[i], size: 48)
                                }
                            }
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - Side-by-Side Direct Comparison
                    Text("SIDE-BY-SIDE: SAME ICON, ALL STYLES")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.cyan)
                        .padding(.horizontal)

                    catalogSection(
                        title: "Globe Icon Comparison",
                        subtitle: "Same icon across all top candidates",
                        ranking: nil
                    ) {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                FrostedOrb(color: .blue, icon: "globe", size: 52)
                                Text("Frosted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                DeepGlassOrb(color: .blue, icon: "globe", size: 52)
                                Text("Deep Glass")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                LiftedIconOrb(color: .blue, icon: "globe", size: 52)
                                Text("Lifted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConvexBubbleOrb(color: .blue, icon: "globe", size: 52)
                                Text("Convex")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConstellationStyleOrb(color: .blue, icon: "globe", size: 52)
                                Text("Const.")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    catalogSection(
                        title: "Star Icon Comparison",
                        subtitle: "Orange color variant",
                        ranking: nil
                    ) {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                FrostedOrb(color: .orange, icon: "star.fill", size: 52)
                                Text("Frosted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                DeepGlassOrb(color: .orange, icon: "star.fill", size: 52)
                                Text("Deep Glass")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                LiftedIconOrb(color: .orange, icon: "star.fill", size: 52)
                                Text("Lifted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConvexBubbleOrb(color: .orange, icon: "star.fill", size: 52)
                                Text("Convex")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConstellationStyleOrb(color: .orange, icon: "star.fill", size: 52)
                                Text("Const.")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    catalogSection(
                        title: "Dark Color Comparison",
                        subtitle: "Near-black - the 'record' problem area",
                        ranking: nil
                    ) {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                FrostedOrb(color: Color(white: 0.1), icon: "bolt.fill", size: 52)
                                Text("Frosted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                DeepGlassOrb(color: Color(white: 0.1), icon: "bolt.fill", size: 52)
                                Text("Deep Glass")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                LiftedIconOrb(color: Color(white: 0.1), icon: "bolt.fill", size: 52)
                                Text("Lifted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConvexBubbleOrb(color: Color(white: 0.1), icon: "bolt.fill", size: 52)
                                Text("Convex")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                DarkEnhancedOrb(color: Color(white: 0.1), icon: "bolt.fill", size: 52)
                                Text("Dark Enh.")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - Real Favicon Comparison
                    Text("REAL FAVICON COMPARISON")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.green)
                        .padding(.horizontal)

                    finalComparisonSection(
                        title: "Frosted with Real Favicons",
                        subtitle: "Live favicons from actual sites",
                        ranking: 1
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                FrostedRealFaviconOrb(host: "claude.ai", name: "Claude", glowColor: Color(red: 0.85, green: 0.6, blue: 0.4), size: 64)
                                FrostedRealFaviconOrb(host: "github.com", name: "GitHub", glowColor: .purple, size: 64)
                                FrostedRealFaviconOrb(host: "youtube.com", name: "YouTube", glowColor: .red, size: 64)
                                FrostedRealFaviconOrb(host: "spotify.com", name: "Spotify", glowColor: .green, size: 64)
                                FrostedRealFaviconOrb(host: "notion.so", name: "Notion", glowColor: .gray, size: 64)
                                FrostedRealFaviconOrb(host: "slack.com", name: "Slack", glowColor: .purple, size: 64)
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Deep Glass with Real Favicons",
                        subtitle: "Live favicons from actual sites",
                        ranking: 1
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                DeepGlassRealFaviconOrb(host: "claude.ai", name: "Claude", glowColor: Color(red: 0.85, green: 0.6, blue: 0.4), size: 64)
                                DeepGlassRealFaviconOrb(host: "github.com", name: "GitHub", glowColor: .purple, size: 64)
                                DeepGlassRealFaviconOrb(host: "youtube.com", name: "YouTube", glowColor: .red, size: 64)
                                DeepGlassRealFaviconOrb(host: "spotify.com", name: "Spotify", glowColor: .green, size: 64)
                                DeepGlassRealFaviconOrb(host: "notion.so", name: "Notion", glowColor: .gray, size: 64)
                                DeepGlassRealFaviconOrb(host: "slack.com", name: "Slack", glowColor: .purple, size: 64)
                            }
                        }
                    }

                    finalComparisonSection(
                        title: "Convex with Real Favicons",
                        subtitle: "Convex bubble style with live favicons",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ConvexRealFaviconOrb(host: "claude.ai", name: "Claude", glowColor: Color(red: 0.85, green: 0.6, blue: 0.4), size: 64)
                                ConvexRealFaviconOrb(host: "github.com", name: "GitHub", glowColor: .purple, size: 64)
                                ConvexRealFaviconOrb(host: "youtube.com", name: "YouTube", glowColor: .red, size: 64)
                                ConvexRealFaviconOrb(host: "spotify.com", name: "Spotify", glowColor: .green, size: 64)
                                ConvexRealFaviconOrb(host: "notion.so", name: "Notion", glowColor: .gray, size: 64)
                                ConvexRealFaviconOrb(host: "slack.com", name: "Slack", glowColor: .purple, size: 64)
                            }
                        }
                    }

                    // Side-by-side real favicon comparison
                    catalogSection(
                        title: "Side-by-Side: Same Favicon, All Styles",
                        subtitle: "GitHub favicon across Frosted, Deep Glass, Convex",
                        ranking: nil
                    ) {
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                FrostedRealFaviconOrb(host: "github.com", name: "G", glowColor: .purple, size: 56)
                                Text("Frosted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                DeepGlassRealFaviconOrb(host: "github.com", name: "G", glowColor: .purple, size: 56)
                                Text("Deep Glass")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConvexRealFaviconOrb(host: "github.com", name: "G", glowColor: .purple, size: 56)
                                Text("Convex")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    catalogSection(
                        title: "Dark Favicon Test",
                        subtitle: "GitHub (dark icon) - tests visibility on glass",
                        ranking: nil
                    ) {
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                FrostedRealFaviconOrb(host: "notion.so", name: "N", glowColor: .gray, size: 56)
                                Text("Frosted")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                DeepGlassRealFaviconOrb(host: "notion.so", name: "N", glowColor: .gray, size: 56)
                                Text("Deep Glass")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 4) {
                                ConvexRealFaviconOrb(host: "notion.so", name: "N", glowColor: .gray, size: 56)
                                Text("Convex")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - Mixed: Icons + Favicons
                    Text("MIXED: ICONS + FAVICONS TOGETHER")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.yellow)
                        .padding(.horizontal)

                    catalogSection(
                        title: "Frosted Mixed",
                        subtitle: "Icons and favicons in same style",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FrostedOrb(color: .blue, icon: "globe", size: 52)
                                FrostedRealFaviconOrb(host: "claude.ai", name: "C", glowColor: .orange, size: 52)
                                FrostedOrb(color: .green, icon: "star.fill", size: 52)
                                FrostedRealFaviconOrb(host: "github.com", name: "G", glowColor: .purple, size: 52)
                                FrostedOrb(color: .orange, icon: "bolt.fill", size: 52)
                                FrostedRealFaviconOrb(host: "youtube.com", name: "Y", glowColor: .red, size: 52)
                            }
                        }
                    }

                    catalogSection(
                        title: "Deep Glass Mixed",
                        subtitle: "Icons and favicons in same style",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                DeepGlassOrb(color: .blue, icon: "globe", size: 52)
                                DeepGlassRealFaviconOrb(host: "claude.ai", name: "C", glowColor: .orange, size: 52)
                                DeepGlassOrb(color: .green, icon: "star.fill", size: 52)
                                DeepGlassRealFaviconOrb(host: "github.com", name: "G", glowColor: .purple, size: 52)
                                DeepGlassOrb(color: .orange, icon: "bolt.fill", size: 52)
                                DeepGlassRealFaviconOrb(host: "youtube.com", name: "Y", glowColor: .red, size: 52)
                            }
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - Original Best Designs (Ranked)
                    Text("ORIGINAL CATALOG")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    catalogSection(
                        title: "Best Designs",
                        subtitle: "Highest visual quality - use as reference",
                        ranking: 1
                    ) {
                        HStack(spacing: 20) {
                            VStack(spacing: 6) {
                                ConstellationStyleOrb(color: .blue, icon: "sparkles", size: 56)
                                Text("Constellation")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 6) {
                                QuickStartStyleOrb(color: .orange, initial: "C", size: 50)
                                Text("Quick Start")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            VStack(spacing: 6) {
                                EditConstellationStyleOrb(color: .green, icon: "bolt.fill", size: 56)
                                Text("Edit Const.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // MARK: - Constellation Orbs
                    catalogSection(
                        title: "Constellation Orbs",
                        subtitle: "Icon-only, solid gradient + glow",
                        ranking: 1
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    ConstellationStyleOrb(
                                        color: sampleColors[i],
                                        icon: ["sparkles", "bolt.fill", "heart.fill", "star.fill", "book.fill", "gamecontroller.fill"][i],
                                        size: 48
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Quick Start Orbs
                    catalogSection(
                        title: "Quick Start Orbs (AddPortalView)",
                        subtitle: "Frosty glass with favicon or initial",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    QuickStartStyleOrb(
                                        color: sampleColors[i],
                                        initial: ["Y", "X", "C", "G", "N", "S"][i],
                                        size: 44
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Pack Header Orbs
                    catalogSection(
                        title: "Pack Header Orbs (QuickStartPortalsView)",
                        subtitle: "Small icon orbs for section headers",
                        ranking: 2
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<6) { i in
                                    PackHeaderStyleOrb(
                                        color: sampleColors[i],
                                        icon: ["sparkles", "bolt.fill", "heart.fill", "star.fill", "book.fill", "gamecontroller.fill"][i],
                                        size: 28
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Current Portal Orbs (Problem Area)
                    catalogSection(
                        title: "Current Portal Orbs",
                        subtitle: "Main PortalOrbView - varies by content",
                        ranking: 3
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Light backgrounds:")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            HStack(spacing: 16) {
                                ForEach([Color.blue, .green, .orange, .cyan], id: \.self) { color in
                                    CurrentPortalStyleOrb(color: color, initial: "A", size: 48)
                                }
                            }

                            Text("Dark backgrounds (record problem):")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                            HStack(spacing: 16) {
                                ForEach([Color(white: 0.1), Color(white: 0.15), Color(white: 0.2), Color(red: 0.2, green: 0.1, blue: 0.1)], id: \.self) { color in
                                    CurrentPortalStyleOrb(color: color, initial: "X", size: 48)
                                }
                            }
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // MARK: - Experimental Depth Variations
                    Text("EXPERIMENTAL VARIATIONS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    // MARK: - Lifted Icon
                    catalogSection(
                        title: "Lifted Icon",
                        subtitle: "Icon floats above surface with shadow beneath",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    LiftedIconOrb(
                                        color: sampleColors[i],
                                        icon: ["globe", "star.fill", "heart.fill", "bolt.fill", "sparkles", "flame.fill"][i],
                                        size: 56
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Deep Glass
                    catalogSection(
                        title: "Deep Glass",
                        subtitle: "Stronger specular, more transparent layers",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    DeepGlassOrb(
                                        color: sampleColors[i],
                                        icon: ["globe", "star.fill", "heart.fill", "bolt.fill", "sparkles", "flame.fill"][i],
                                        size: 56
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Frosted Material
                    catalogSection(
                        title: "Frosted Material",
                        subtitle: "More blur, softer colors, material-first",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    FrostedOrb(
                                        color: sampleColors[i],
                                        icon: ["globe", "star.fill", "heart.fill", "bolt.fill", "sparkles", "flame.fill"][i],
                                        size: 56
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Convex Bubble
                    catalogSection(
                        title: "Convex Bubble",
                        subtitle: "Exaggerated 3D highlight for sphere effect",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    ConvexBubbleOrb(
                                        color: sampleColors[i],
                                        icon: ["globe", "star.fill", "heart.fill", "bolt.fill", "sparkles", "flame.fill"][i],
                                        size: 56
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Inner Shadow (Pressed)
                    catalogSection(
                        title: "Inner Shadow",
                        subtitle: "Concave pressed-in effect",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<6) { i in
                                    InnerShadowOrb(
                                        color: sampleColors[i],
                                        icon: ["globe", "star.fill", "heart.fill", "bolt.fill", "sparkles", "flame.fill"][i],
                                        size: 56
                                    )
                                }
                            }
                        }
                    }

                    // MARK: - Dark Color Fix
                    catalogSection(
                        title: "Dark Color Enhanced",
                        subtitle: "Boosted glow for dark colors (fixes record look)",
                        ranking: nil
                    ) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach([Color(white: 0.1), Color(white: 0.15), Color(red: 0.15, green: 0.1, blue: 0.1), Color(red: 0.1, green: 0.15, blue: 0.1)], id: \.self) { color in
                                    DarkEnhancedOrb(color: color, icon: "star.fill", size: 56)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Orb Style Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Section Builder

    @ViewBuilder
    private func catalogSection<Content: View>(
        title: String,
        subtitle: String,
        ranking: Int?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.headline)
                        if let rank = ranking {
                            Text(rank == 1 ? "Best" : rank == 2 ? "Good" : "OK")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(rank == 1 ? Color.green.opacity(0.2) : rank == 2 ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                                .foregroundStyle(rank == 1 ? .green : rank == 2 ? .blue : .orange)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            content()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func finalComparisonSection<Content: View>(
        title: String,
        subtitle: String,
        ranking: Int?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.headline)
                        if let rank = ranking {
                            Text(rank == 1 ? "Top Pick" : "Strong")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(rank == 1 ? Color.orange.opacity(0.2) : Color.cyan.opacity(0.2))
                                .foregroundStyle(rank == 1 ? .orange : .cyan)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ranking == 1 ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Constellation Style Orb (Best - from EditConstellationView)

private struct ConstellationStyleOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.5),
                            color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Main sphere with deep gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.5),
                            color.opacity(0.7),
                            color.opacity(0.85)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            // Specular highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.2),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size, height: size)

            // Rim light
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        }
        .shadow(color: color.opacity(0.4), radius: 8, y: 3)
    }
}

// MARK: - Edit Constellation Style Orb

private struct EditConstellationStyleOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Outer glow - ambient
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
                        startRadius: size * 0.3,
                        endRadius: size * 1.0
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)

            // Main sphere body
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
                        startRadius: size * 0.05,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            // Top-left specular
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            Color.white.opacity(0.25),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size, height: size)

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
                .frame(width: size, height: size)

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
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size, height: size)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: color.opacity(0.9), radius: 3)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
        }
        .shadow(color: color.opacity(0.35), radius: 10, y: 3)
    }
}

// MARK: - Quick Start Style Orb

private struct QuickStartStyleOrb: View {
    let color: Color
    let initial: String
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.25, height: size * 1.25)

            // Glass orb background
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)

            // Colored center
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.6), color.opacity(0.85)],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size * 0.65, height: size * 0.65)

            // Initial
            Text(initial)
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)

            // Specular highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.15), Color.clear],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size, height: size)

            // Rim light
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.1), Color.white.opacity(0.05), Color.white.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .frame(width: size, height: size)
        }
        .shadow(color: color.opacity(0.4), radius: 6, y: 3)
    }
}

// MARK: - Pack Header Style Orb

private struct PackHeaderStyleOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            // Main orb with gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.5), color.opacity(0.8)],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            // Glass highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.5), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size, height: size)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.43, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
        }
        .shadow(color: color.opacity(0.3), radius: 3, y: 2)
    }
}

// MARK: - Current Portal Style Orb (for reference)

private struct CurrentPortalStyleOrb: View {
    let color: Color
    let initial: String
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(color.opacity(0.15))
                .blur(radius: size * 0.15)
                .frame(width: size * 1.2, height: size * 1.2)

            // Main circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.7), color.opacity(0.9), color],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            // Highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.3
                    )
                )
                .frame(width: size, height: size)

            // Initial
            Text(initial)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: color.opacity(0.3), radius: 4, y: 2)
    }
}

// MARK: - Experimental: Lifted Icon Orb

private struct LiftedIconOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), color.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Base sphere
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.3), color.opacity(0.6), color.opacity(0.8)],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            // Specular
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.2), Color.clear],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size, height: size)

            // Rim
            Circle()
                .stroke(
                    LinearGradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)

            // Icon shadow (creates lift effect)
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(color.opacity(0.5))
                .blur(radius: 3)
                .offset(y: 3)

            // Lifted icon
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                .offset(y: -2)  // Lifted up
        }
        .shadow(color: color.opacity(0.4), radius: 8, y: 3)
    }
}

// MARK: - Experimental: Deep Glass Orb

private struct DeepGlassOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Soft outer glow - smoother gradient with more stops
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.5),
                            color.opacity(0.35),
                            color.opacity(0.2),
                            color.opacity(0.1),
                            color.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 1.0
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)

            // Glass base - more transparent
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)

            // Color tint overlay
            Circle()
                .fill(color.opacity(0.25))
                .frame(width: size, height: size)

            // Strong specular - larger and brighter
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.85),
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.2, y: 0.15),
                        startRadius: 0,
                        endRadius: size * 0.45
                    )
                )
                .frame(width: size, height: size)

            // Multiple rim lights for depth
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                .frame(width: size, height: size)

            Circle()
                .stroke(color.opacity(0.3), lineWidth: 0.5)
                .frame(width: size - 3, height: size - 3)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: color, radius: 4)
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        }
        .shadow(color: color.opacity(0.4), radius: 12, y: 4)
    }
}

// MARK: - Deep Glass with Favicon

private struct DeepGlassFaviconOrb: View {
    let faviconColor: Color
    let initial: String
    let glowColor: Color
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Soft outer glow - uses glow color (can differ from favicon)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(0.5),
                            glowColor.opacity(0.35),
                            glowColor.opacity(0.2),
                            glowColor.opacity(0.1),
                            glowColor.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 1.0
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)

            // Glass base
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)

            // Color tint overlay
            Circle()
                .fill(glowColor.opacity(0.2))
                .frame(width: size, height: size)

            // Specular highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.2, y: 0.15),
                        startRadius: 0,
                        endRadius: size * 0.45
                    )
                )
                .frame(width: size, height: size)

            // Rim light
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                .frame(width: size, height: size)

            // Favicon circle
            Circle()
                .fill(faviconColor)
                .frame(width: size * 0.6, height: size * 0.6)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)

            // Favicon initial
            Text(initial)
                .font(.system(size: size * 0.28, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: glowColor.opacity(0.4), radius: 12, y: 4)
    }
}

// MARK: - Frosted with Real Favicon (AsyncImage)

private struct FrostedRealFaviconOrb: View {
    let host: String
    let name: String
    let glowColor: Color
    var size: CGFloat = 56

    private var faviconURL: URL? {
        URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    var body: some View {
        ZStack {
            // Soft outer glow
            Circle()
                .fill(glowColor.opacity(0.2))
                .blur(radius: size * 0.25)
                .frame(width: size * 1.3, height: size * 1.3)

            // Frosted glass base
            Circle()
                .fill(.regularMaterial)
                .frame(width: size, height: size)

            // Subtle color wash
            Circle()
                .fill(
                    LinearGradient(
                        colors: [glowColor.opacity(0.12), glowColor.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Soft highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size, height: size)

            // Subtle rim
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .frame(width: size, height: size)

            // Real favicon via AsyncImage
            AsyncImage(url: faviconURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.55, height: size * 0.55)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                case .failure, .empty:
                    // Fallback to initial
                    Circle()
                        .fill(glowColor)
                        .frame(width: size * 0.55, height: size * 0.55)
                        .overlay(
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: size * 0.25, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .shadow(color: glowColor.opacity(0.2), radius: 6, y: 2)
    }
}

// MARK: - Deep Glass with Real Favicon (AsyncImage)

private struct DeepGlassRealFaviconOrb: View {
    let host: String
    let name: String
    let glowColor: Color
    var size: CGFloat = 56

    private var faviconURL: URL? {
        URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    var body: some View {
        ZStack {
            // Soft outer glow - smoother gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(0.5),
                            glowColor.opacity(0.35),
                            glowColor.opacity(0.2),
                            glowColor.opacity(0.1),
                            glowColor.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 1.0
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)

            // Glass base
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)

            // Color tint overlay
            Circle()
                .fill(glowColor.opacity(0.2))
                .frame(width: size, height: size)

            // Specular highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.2, y: 0.15),
                        startRadius: 0,
                        endRadius: size * 0.45
                    )
                )
                .frame(width: size, height: size)

            // Rim light
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                .frame(width: size, height: size)

            // Real favicon via AsyncImage
            AsyncImage(url: faviconURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.55, height: size * 0.55)
                        .clipShape(Circle())
                        .shadow(color: glowColor, radius: 4)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                case .failure, .empty:
                    Circle()
                        .fill(glowColor)
                        .frame(width: size * 0.55, height: size * 0.55)
                        .overlay(
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: size * 0.25, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: glowColor, radius: 4)
                        .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .shadow(color: glowColor.opacity(0.4), radius: 12, y: 4)
    }
}

// MARK: - Convex with Real Favicon (AsyncImage)

private struct ConvexRealFaviconOrb: View {
    let host: String
    let name: String
    let glowColor: Color
    var size: CGFloat = 56

    private var faviconURL: URL? {
        URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(0.4), glowColor.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.85
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Base color - darker at edges (convex effect)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(0.3),
                            glowColor.opacity(0.5),
                            glowColor.opacity(0.7),
                            glowColor.opacity(0.85)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            // Large bright specular (bubble effect)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size * 0.6, height: size * 0.45)
                .offset(x: -size * 0.12, y: -size * 0.15)

            // Secondary smaller highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.2, y: -size * 0.25)

            // Rim light
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.1), Color.clear, Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)

            // Real favicon via AsyncImage
            AsyncImage(url: faviconURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.5, height: size * 0.5)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                case .failure, .empty:
                    Circle()
                        .fill(.white.opacity(0.9))
                        .frame(width: size * 0.5, height: size * 0.5)
                        .overlay(
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: size * 0.22, weight: .bold))
                                .foregroundStyle(glowColor)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                @unknown default:
                    EmptyView()
                }
            }
        }
        .shadow(color: glowColor.opacity(0.45), radius: 10, y: 4)
    }
}

// MARK: - Experimental: Frosted Orb

private struct FrostedOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Soft outer glow
            Circle()
                .fill(color.opacity(0.2))
                .blur(radius: size * 0.25)
                .frame(width: size * 1.3, height: size * 1.3)

            // Frosted glass base
            Circle()
                .fill(.regularMaterial)
                .frame(width: size, height: size)

            // Subtle color wash
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.15), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Soft highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.35), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size, height: size)

            // Subtle rim
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .frame(width: size, height: size)

            // Icon - slightly muted
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .medium))
                .foregroundStyle(.primary.opacity(0.85))
        }
        .shadow(color: color.opacity(0.2), radius: 6, y: 2)
    }
}

// MARK: - Experimental: Convex Bubble Orb

private struct ConvexBubbleOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.4), color.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.85
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Base color - darker at edges (convex effect)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.6),
                            color.opacity(0.8),
                            color.opacity(0.95)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            // Large bright specular (bubble effect)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size * 0.6, height: size * 0.45)
                .offset(x: -size * 0.12, y: -size * 0.15)

            // Secondary smaller highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.08, height: size * 0.08)
                .offset(x: size * 0.2, y: -size * 0.25)

            // Rim light
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.1), Color.clear, Color.white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size, height: size)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
        }
        .shadow(color: color.opacity(0.45), radius: 10, y: 4)
    }
}

// MARK: - Experimental: Inner Shadow Orb

private struct InnerShadowOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.35), color.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)

            // Base color
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: size, height: size)

            // Inner shadow (pressed effect) - darker ring inside
            Circle()
                .stroke(
                    RadialGradient(
                        colors: [Color.black.opacity(0.4), Color.black.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: size * 0.35,
                        endRadius: size * 0.5
                    ),
                    lineWidth: size * 0.15
                )
                .frame(width: size * 0.85, height: size * 0.85)

            // Center lighter area
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.5), color.opacity(0.7)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size * 0.7, height: size * 0.7)

            // Subtle top highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size, height: size)

            // Rim
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .frame(width: size, height: size)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
        }
        .shadow(color: color.opacity(0.3), radius: 6, y: 2)
    }
}

// MARK: - Experimental: Dark Color Enhanced Orb

private struct DarkEnhancedOrb: View {
    let color: Color
    let icon: String
    var size: CGFloat = 56

    var body: some View {
        // For dark colors, boost the glow with a contrasting tint
        let glowColor = Color.white.opacity(0.3)

        ZStack {
            // Enhanced outer glow for dark colors - use white/gray instead of color
            Circle()
                .fill(
                    RadialGradient(
                        colors: [glowColor, glowColor.opacity(0.5), Color.clear],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.9
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)

            // Secondary color glow underneath
            Circle()
                .fill(color.opacity(0.3))
                .blur(radius: size * 0.15)
                .frame(width: size * 1.2, height: size * 1.2)

            // Base sphere - keep dark but add subtle gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.6),
                            color.opacity(0.8),
                            color
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            // Enhanced specular for dark backgrounds
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.7),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size, height: size)

            // Strong white rim for definition
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.white.opacity(0.2), Color.white.opacity(0.1), Color.white.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size, height: size)

            // Icon
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.3), radius: 4)
                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
        }
        .shadow(color: Color.white.opacity(0.15), radius: 8, y: 0)
        .shadow(color: color.opacity(0.3), radius: 6, y: 3)
    }
}

// MARK: - Preview

#Preview {
    OrbStyleCatalog()
}
