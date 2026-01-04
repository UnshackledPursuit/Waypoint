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
        icon: String = "sparkles",
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
            name: "Dev",
            portalIDs: [Portal.sampleIDs.claude, Portal.sampleIDs.github],
            icon: "chevron.left.forwardslash.chevron.right",
            colorHex: "#0A84FF"
        )
    }

    static var samples: [Constellation] {
        [
            // Dev - Claude, GitHub, Figma, Linear, Notion
            Constellation(
                name: "Dev",
                portalIDs: [
                    Portal.sampleIDs.claude,
                    Portal.sampleIDs.github,
                    Portal.sampleIDs.figma,
                    Portal.sampleIDs.linear,
                    Portal.sampleIDs.notion
                ],
                icon: "chevron.left.forwardslash.chevron.right",
                colorHex: "#0A84FF"  // Deep blue
            ),
            // Comms - Slack, Gmail, Calendar
            Constellation(
                name: "Comms",
                portalIDs: [
                    Portal.sampleIDs.slack,
                    Portal.sampleIDs.gmail,
                    Portal.sampleIDs.calendar
                ],
                icon: "bubble.left.and.bubble.right.fill",
                colorHex: "#FF9500"  // Orange
            ),
            // Research - arXiv, Hacker News
            Constellation(
                name: "Research",
                portalIDs: [
                    Portal.sampleIDs.arxiv,
                    Portal.sampleIDs.hackernews
                ],
                icon: "book.fill",
                colorHex: "#30D5C8"  // Aqua/Teal
            ),
            // Media - YouTube, Spotify
            Constellation(
                name: "Media",
                portalIDs: [
                    Portal.sampleIDs.youtube,
                    Portal.sampleIDs.spotify
                ],
                icon: "play.circle.fill",
                colorHex: "#FFD60A"  // Yellow
            ),
            // Finance - Bloomberg, Coinbase
            Constellation(
                name: "Finance",
                portalIDs: [
                    Portal.sampleIDs.bloomberg,
                    Portal.sampleIDs.coinbase
                ],
                icon: "chart.line.uptrend.xyaxis",
                colorHex: "#1C1C1E"  // Near-black
            )
        ]
    }
}
