//
//  Constellation.swift
//  Waypoint
//
//  Created on December 29, 2024.
//

import Foundation
import SwiftUI

// MARK: - Constellation Model

struct Constellation: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var portalIDs: [UUID]           // References to portals (not ownership)
    var icon: String                // SF Symbol name
    var colorHex: String            // Stored as hex for Codable
    var dateCreated: Date
    var isActive: Bool              // Show/hide toggle
    var launchDelay: Double         // Delay between portal launches (seconds)

    // MARK: - Computed Properties

    var color: Color {
        Color(hex: colorHex)
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        portalIDs: [UUID] = [],
        icon: String = "star.fill",
        colorHex: String = "#007AFF",
        dateCreated: Date = Date(),
        isActive: Bool = true,
        launchDelay: Double = 0.3
    ) {
        self.id = id
        self.name = name
        self.portalIDs = portalIDs
        self.icon = icon
        self.colorHex = colorHex
        self.dateCreated = dateCreated
        self.isActive = isActive
        self.launchDelay = launchDelay
    }
}

// MARK: - Sample Data

extension Constellation {
    static var sample: Constellation {
        Constellation(
            name: "Morning Routine",
            portalIDs: [],
            icon: "sunrise.fill",
            colorHex: "#FF9500"
        )
    }

    static var samples: [Constellation] {
        [
            Constellation(name: "Morning Routine", icon: "sunrise.fill", colorHex: "#FF9500"),
            Constellation(name: "Work Focus", icon: "laptopcomputer", colorHex: "#007AFF"),
            Constellation(name: "Research", icon: "book.fill", colorHex: "#34C759")
        ]
    }
}
