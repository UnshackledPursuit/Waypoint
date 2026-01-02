//
//  QuickStartPortalsView.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI

struct QuickStartPortalsView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    
    let isFirstTime: Bool
    
    @State private var selectedPortals: Set<UUID> = []
    
    private var packs: [PortalPack] {
        isFirstTime ? PortalPack.firstTimePacks : PortalPack.allPacks
    }
    
    private var selectedCount: Int {
        selectedPortals.count
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(packs) { pack in
                            VStack(alignment: .leading, spacing: 12) {
                                // Pack header with glass orb icon
                                HStack(spacing: 10) {
                                    packIconOrb(for: pack)
                                    Text(pack.name)
                                        .font(.headline)
                                }
                                .padding(.bottom, 4)

                                // Portals in pack
                                ForEach(pack.portals) { template in
                                    Button {
                                        toggleSelection(template.id)
                                    } label: {
                                        HStack(spacing: 10) {
                                            // Checkbox on LEFT
                                            Image(systemName: selectedPortals.contains(template.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(selectedPortals.contains(template.id) ? .green : .secondary)
                                                .font(.system(size: 20))

                                            // Glassy orb with favicon
                                            glassyOrbIcon(for: template)

                                            Text(template.name)
                                                .font(.subheadline)
                                                .foregroundStyle(.primary)

                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }

                                // Select All button - subtle glass style
                                Button {
                                    selectAllInPack(pack)
                                } label: {
                                    let allSelected = Set(pack.portals.map { $0.id }).isSubset(of: selectedPortals)
                                    HStack(spacing: 6) {
                                        Image(systemName: allSelected ? "checkmark.circle.fill" : "circle.dashed")
                                            .font(.caption)
                                        Text(allSelected ? "Deselect All" : "Select All")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(.ultraThinMaterial, in: Capsule())
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
                
                // Bottom buttons bar
                HStack(spacing: 16) {
                    Button {
                        clearAll()
                    } label: {
                        Text("Clear All")
                            .foregroundStyle(.secondary)
                    }
                    .disabled(selectedCount == 0)
                    
                    Spacer()
                    
                    Button {
                        addSelectedPortals()
                    } label: {
                        Text("Add (\(selectedCount))")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedCount == 0)
                }
                .padding()
                .background(.regularMaterial)
            }
            .navigationTitle(isFirstTime ? "Quick Start Portals" : "Portal Collections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleSelection(_ id: UUID) {
        if selectedPortals.contains(id) {
            selectedPortals.remove(id)
        } else {
            selectedPortals.insert(id)
        }
    }
    
    private func selectAllInPack(_ pack: PortalPack) {
        let packIDs = Set(pack.portals.map { $0.id })
        
        // If all are selected, deselect all; otherwise select all
        if packIDs.isSubset(of: selectedPortals) {
            selectedPortals.subtract(packIDs)
        } else {
            selectedPortals.formUnion(packIDs)
        }
    }
    
    private func clearAll() {
        selectedPortals.removeAll()
    }
    
    private func addSelectedPortals() {
        // Gather all selected portal templates
        var templatesToAdd: [PortalTemplate] = []
        
        for pack in packs {
            for template in pack.portals {
                if selectedPortals.contains(template.id) {
                    templatesToAdd.append(template)
                }
            }
        }
        
        // Create Portal objects and add to manager
        for template in templatesToAdd {
            let portal = Portal(
                name: template.name,
                url: template.url
            )
            portalManager.add(portal)
        }
        
        print("✅ Added \(templatesToAdd.count) portals from Quick Start")
        dismiss()
    }
    
    // MARK: - Pack Icon Orb

    @ViewBuilder
    private func packIconOrb(for pack: PortalPack) -> some View {
        let color = packColor(for: pack.name)

        ZStack {
            // Main orb with gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.5),
                            color.opacity(0.8)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: 14
                    )
                )
                .frame(width: 28, height: 28)

            // Glass highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.5), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.25),
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 28, height: 28)

            // SF Symbol icon
            Image(systemName: pack.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
        }
        .shadow(color: color.opacity(0.3), radius: 3, y: 2)
    }

    private func packColor(for packName: String) -> Color {
        switch packName {
        case "AI": return Color(red: 0.4, green: 0.6, blue: 1.0)  // Blue
        case "Pulse": return Color(red: 1.0, green: 0.4, blue: 0.6)  // Pink
        case "Launchpad": return Color(red: 1.0, green: 0.7, blue: 0.2)  // Orange
        case "AI Artists": return Color(red: 0.8, green: 0.4, blue: 0.9)  // Purple
        case "Social": return Color(red: 0.3, green: 0.8, blue: 0.7)  // Teal
        case "Developer": return Color(red: 0.3, green: 0.7, blue: 0.4)  // Green
        case "Productivity": return Color(red: 0.9, green: 0.5, blue: 0.2)  // Deep Orange
        case "Creative": return Color(red: 0.9, green: 0.3, blue: 0.5)  // Magenta
        default: return Color.blue
        }
    }

    // MARK: - Glassy Orb Icon

    @ViewBuilder
    private func glassyOrbIcon(for template: PortalTemplate) -> some View {
        let color = colorForURL(template.url)

        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 18
                    )
                )
                .frame(width: 32, height: 32)

            // Glass orb background
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 26, height: 26)

            // Favicon or fallback
            AsyncImage(url: faviconURL(for: template.url)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(Circle())
                case .failure, .empty:
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [color.opacity(0.6), color.opacity(0.85)],
                                    center: UnitPoint(x: 0.3, y: 0.25),
                                    startRadius: 0,
                                    endRadius: 9
                                )
                            )
                            .frame(width: 18, height: 18)
                        Text(String(template.name.prefix(1)).uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    }
                @unknown default:
                    EmptyView()
                }
            }

            // Glass highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        center: UnitPoint(x: 0.25, y: 0.2),
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 26, height: 26)

            // Rim light
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .frame(width: 26, height: 26)
        }
        .shadow(color: color.opacity(0.3), radius: 4, y: 2)
    }

    // MARK: - Utilities

    private func faviconURL(for urlString: String) -> URL? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }
        return URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    private func colorForURL(_ urlString: String) -> Color {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return .blue
        }
        return Color.fromHost(host)
    }

    private func cleanURL(_ url: String) -> String {
        var cleaned = url

        // Remove common prefixes for display
        if cleaned.hasPrefix("https://") {
            cleaned = String(cleaned.dropFirst(8))
        } else if cleaned.hasPrefix("http://") {
            cleaned = String(cleaned.dropFirst(7))
        }

        // Remove www for cleaner display
        if cleaned.hasPrefix("www.") {
            cleaned = String(cleaned.dropFirst(4))
        }

        // Remove trailing slash
        if cleaned.hasSuffix("/") {
            cleaned = String(cleaned.dropLast())
        }

        return cleaned
    }
}

// MARK: - Preview

#Preview("First Time") {
    QuickStartPortalsView(isFirstTime: true)
        .environment(PortalManager())
}

#Preview("All Packs") {
    QuickStartPortalsView(isFirstTime: false)
        .environment(PortalManager())
}
