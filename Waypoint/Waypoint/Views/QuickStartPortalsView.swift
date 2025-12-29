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
                                // Pack header
                                HStack {
                                    Text(pack.icon)
                                        .font(.title2)
                                    Text(pack.name)
                                        .font(.headline)
                                }
                                .padding(.bottom, 4)
                                
                                // Portals in pack
                                ForEach(pack.portals) { template in
                                    Button {
                                        toggleSelection(template.id)
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: selectedPortals.contains(template.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(selectedPortals.contains(template.id) ? .blue : .secondary)
                                                .font(.system(size: 20))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(template.name)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.primary)
                                            }
                                            
                                            Spacer()
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // Select All button
                                Button {
                                    selectAllInPack(pack)
                                } label: {
                                    HStack {
                                        Image(systemName: "checklist")
                                            .foregroundStyle(.blue)
                                            .font(.caption)
                                        Text("Select All")
                                            .foregroundStyle(.blue)
                                            .font(.caption)
                                    }
                                }
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
    
    // MARK: - Utilities
    
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
