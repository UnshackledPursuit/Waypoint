//
//  PortalManager.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import Foundation
import Observation
import SwiftUI

@Observable
class PortalManager {
    
    // MARK: - Properties
    
    var portals: [Portal] = []
    
    private let appGroupID = "group.Unshackled-Pursuit.Waypoint"
    private let storageKey = "waypoint_portals"
    
    // MARK: - Initialization
    
    init() {
        load()
    }
    
    // MARK: - CRUD Operations
    
    func add(_ portal: Portal) {
        portals.append(portal)
        save()
    }

    func addMultiple(_ newPortals: [Portal]) {
        portals.append(contentsOf: newPortals)
        save()
        print("✅ Added \(newPortals.count) portals")
    }
    
    func update(_ portal: Portal) {
        if let index = portals.firstIndex(where: { $0.id == portal.id }) {
            portals[index] = portal
            save()
        }
    }
    
    func delete(_ portal: Portal) {
        portals.removeAll { $0.id == portal.id }
        save()
    }
    
    func toggleFavorite(_ portal: Portal) {
        if let index = portals.firstIndex(where: { $0.id == portal.id }) {
            portals[index].isFavorite.toggle()
            save()
        }
    }
    
    func togglePin(_ portal: Portal) {
        if let index = portals.firstIndex(where: { $0.id == portal.id }) {
            portals[index].isPinned.toggle()
            save()
        }
    }
    
    func updateLastOpened(_ portal: Portal) {
        if let index = portals.firstIndex(where: { $0.id == portal.id }) {
            portals[index].lastOpened = Date()
            save()
        }
    }

    func movePortals(from source: IndexSet, to destination: Int, in sortedPortals: [Portal]) {
        // Get the IDs being moved
        var reorderedIDs = sortedPortals.map { $0.id }
        reorderedIDs.move(fromOffsets: source, toOffset: destination)

        // Update sortIndex for all portals based on new order
        for (index, id) in reorderedIDs.enumerated() {
            if let portalIndex = portals.firstIndex(where: { $0.id == id }) {
                portals[portalIndex].sortIndex = index
            }
        }

        save()
        print("📦 Reordered portals")
    }
    
    // MARK: - Persistence
    
    private func save() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Failed to access App Group UserDefaults")
            return
        }
        
        do {
            let encoded = try JSONEncoder().encode(portals)
            sharedDefaults.set(encoded, forKey: storageKey)
            print("✅ Saved \(portals.count) portals to shared storage")
        } catch {
            print("❌ Failed to save portals: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Failed to access App Group UserDefaults")
            return
        }
        
        guard let data = sharedDefaults.data(forKey: storageKey) else {
            print("ℹ️ No saved portals found")
            return
        }
        
        do {
            portals = try JSONDecoder().decode([Portal].self, from: data)
            print("✅ Loaded \(portals.count) portals from shared storage")
        } catch {
            print("❌ Failed to load portals: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Utility
    
    func portal(withID id: UUID) -> Portal? {
        portals.first { $0.id == id }
    }
    
    var favoritePortals: [Portal] {
        portals.filter { $0.isFavorite }
    }
    
    var pinnedPortals: [Portal] {
        portals.filter { $0.isPinned }
    }
    
    // Default sort: Pinned first, then by date added (newest first)
    var sortedByDefault: [Portal] {
        portals.sorted { portal1, portal2 in
            // Pinned portals always come first
            if portal1.isPinned != portal2.isPinned {
                return portal1.isPinned
            }
            // Then sort by date added (newest first)
            return portal1.dateAdded > portal2.dateAdded
        }
    }
    
    var sortedByRecent: [Portal] {
        portals.sorted { portal1, portal2 in
            // Pinned portals always come first
            if portal1.isPinned != portal2.isPinned {
                return portal1.isPinned
            }
            // Then sort by last opened/added
            let date1 = portal1.lastOpened ?? portal1.dateAdded
            let date2 = portal2.lastOpened ?? portal2.dateAdded
            return date1 > date2
        }
    }
    
    var sortedByName: [Portal] {
        portals.sorted { portal1, portal2 in
            // Pinned portals always come first
            if portal1.isPinned != portal2.isPinned {
                return portal1.isPinned
            }
            // Then alphabetical
            return portal1.name.localizedCaseInsensitiveCompare(portal2.name) == .orderedAscending
        }
    }
    
    // MARK: - Debug Helpers
    
    func clearAll() {
        portals.removeAll()
        save()
        print("🗑️ Cleared all portals")
    }
    
    func loadSampleData() {
        portals = Portal.samples
        save()
        print("📝 Loaded sample data: \(portals.count) portals")
    }
}
