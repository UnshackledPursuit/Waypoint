//
//  ConstellationManager.swift
//  Waypoint
//
//  Created on December 29, 2024.
//

import Foundation
import Observation

@Observable
class ConstellationManager {

    // MARK: - Properties

    var constellations: [Constellation] = []

    private let appGroupID = "group.Unshackled-Pursuit.Waypoint"
    private let storageKey = "waypoint_constellations"

    // MARK: - Initialization

    init() {
        load()
    }

    // MARK: - CRUD Operations

    func add(_ constellation: Constellation) {
        constellations.append(constellation)
        save()
    }

    func update(_ constellation: Constellation) {
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            constellations[index] = constellation
            save()
        }
    }

    func delete(_ constellation: Constellation) {
        constellations.removeAll { $0.id == constellation.id }
        save()
    }

    // MARK: - Portal Assignment

    func addPortal(_ portalID: UUID, to constellation: Constellation) {
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            if !constellations[index].portalIDs.contains(portalID) {
                constellations[index].portalIDs.append(portalID)
                save()
                print("✅ Added portal to constellation: \(constellation.name)")
            }
        }
    }

    func removePortal(_ portalID: UUID, from constellation: Constellation) {
        if let index = constellations.firstIndex(where: { $0.id == constellation.id }) {
            constellations[index].portalIDs.removeAll { $0 == portalID }
            save()
        }
    }

    func constellationsContaining(portalID: UUID) -> [Constellation] {
        constellations.filter { $0.portalIDs.contains(portalID) }
    }

    // MARK: - Persistence

    private func save() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Failed to access App Group UserDefaults")
            return
        }

        do {
            let encoded = try JSONEncoder().encode(constellations)
            sharedDefaults.set(encoded, forKey: storageKey)
            print("✅ Saved \(constellations.count) constellations")
        } catch {
            print("❌ Failed to save constellations: \(error.localizedDescription)")
        }
    }

    private func load() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Failed to access App Group UserDefaults")
            return
        }

        guard let data = sharedDefaults.data(forKey: storageKey) else {
            print("ℹ️ No saved constellations found")
            return
        }

        do {
            constellations = try JSONDecoder().decode([Constellation].self, from: data)
            print("✅ Loaded \(constellations.count) constellations")
        } catch {
            print("❌ Failed to load constellations: \(error.localizedDescription)")
        }
    }

    // MARK: - Reordering

    func moveConstellation(_ sourceID: UUID, before targetID: UUID) {
        guard let sourceIndex = constellations.firstIndex(where: { $0.id == sourceID }),
              let targetIndex = constellations.firstIndex(where: { $0.id == targetID }),
              sourceIndex != targetIndex else {
            return
        }

        let constellation = constellations.remove(at: sourceIndex)
        let newTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        constellations.insert(constellation, at: newTargetIndex)
        save()
        print("📦 Reordered constellations")
    }

    // MARK: - Utility

    var activeConstellations: [Constellation] {
        constellations.filter { $0.isActive }
    }

    func constellation(withID id: UUID) -> Constellation? {
        constellations.first { $0.id == id }
    }

    // MARK: - Debug Helpers

    func clearAll() {
        constellations.removeAll()
        save()
    }

    func loadSampleData() {
        constellations = Constellation.samples
        save()
    }
}
