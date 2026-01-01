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
            name: "AI Tools",
            portalIDs: [Portal.sampleIDs.youtube, Portal.sampleIDs.claude],
            icon: "sparkles",
            colorHex: "#AF52DE"
        )
    }

    static var samples: [Constellation] {
        [
            // AI Tools - YouTube + all AI assistants
            Constellation(
                name: "AI Tools",
                portalIDs: [
                    Portal.sampleIDs.youtube,
                    Portal.sampleIDs.claude,
                    Portal.sampleIDs.chatgpt,
                    Portal.sampleIDs.gemini,
                    Portal.sampleIDs.grok
                ],
                icon: "sparkles",
                colorHex: "#AF52DE"  // Purple
            ),
            // Social - YouTube + X
            Constellation(
                name: "Social",
                portalIDs: [
                    Portal.sampleIDs.youtube,
                    Portal.sampleIDs.xcom
                ],
                icon: "person.2.fill",
                colorHex: "#FF2D55"  // Pink
            ),
            // Productivity - YouTube + work tools
            Constellation(
                name: "Productivity",
                portalIDs: [
                    Portal.sampleIDs.youtube,
                    Portal.sampleIDs.gmail,
                    Portal.sampleIDs.googleDocs,
                    Portal.sampleIDs.notion
                ],
                icon: "briefcase.fill",
                colorHex: "#007AFF"  // Blue
            ),
            // Dev - YouTube + GitHub
            Constellation(
                name: "Dev",
                portalIDs: [
                    Portal.sampleIDs.youtube,
                    Portal.sampleIDs.github
                ],
                icon: "chevron.left.forwardslash.chevron.right",
                colorHex: "#34C759"  // Green
            )
        ]
    }
}
