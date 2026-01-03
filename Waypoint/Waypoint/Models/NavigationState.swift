//
//  NavigationState.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Color Extension for Hue Sorting

extension Color {
    /// Returns the hue value (0-1) for sorting colors by spectrum position
    var hueValue: CGFloat {
        #if os(visionOS) || os(iOS)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return hue
        #else
        return 0
        #endif
    }
}

// MARK: - Filter Option

enum FilterOption: Hashable {
    case all
    case pinned
    case ungrouped
    case constellation(UUID)

    var displayName: String {
        switch self {
        case .all: return "All"
        case .pinned: return "Favorites"
        case .ungrouped: return "Ungrouped"
        case .constellation: return "Constellation"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .pinned: return "star.fill"
        case .ungrouped: return "tray"
        case .constellation: return "sparkles"
        }
    }
}

// MARK: - Sort Order

enum SortOrder: String, CaseIterable {
    case custom = "Custom"
    case dateAdded = "Added"
    case recent = "Recent"
    case name = "A-Z"
    case constellation = "Groups"
    case constellationColor = "Color"

    var icon: String {
        switch self {
        case .custom: return "hand.draw"
        case .dateAdded: return "calendar"
        case .recent: return "clock"
        case .name: return "textformat"
        case .constellation: return "folder"
        case .constellationColor: return "paintpalette"
        }
    }

    /// Short description for footer display
    var footerDescription: String {
        switch self {
        case .custom: return "Manual drag ordering"
        case .dateAdded: return "Newest first"
        case .recent: return "Recently opened first"
        case .name: return "Alphabetical"
        case .constellation: return "Grouped with section headers"
        case .constellationColor: return "By constellation color"
        }
    }
}

// MARK: - Orb Color Mode

/// Controls how orb colors are determined
enum OrbColorMode: String, CaseIterable {
    /// Use the active constellation's color for all orbs
    case constellation = "constellation"
    /// Each portal uses its default/assigned color (current behavior)
    case defaultStyle = "default"
    /// Frosted glass bubbles, but icons/favicons keep color
    case frost = "frost"
    /// Complete grayscale - everything loses color (favicons, icons, all)
    case mono = "mono"

    var icon: String {
        switch self {
        case .constellation: return "sparkles"
        case .defaultStyle: return "paintpalette"
        case .frost: return "snowflake"
        case .mono: return "circle.slash" // Clearer than circle.lefthalf.strikethrough
        }
    }

    var label: String {
        switch self {
        case .constellation: return "Group"
        case .defaultStyle: return "Default"
        case .frost: return "Frost"
        case .mono: return "Mono"
        }
    }
}

// MARK: - Navigation State

@Observable
final class NavigationState {

    // MARK: - Filter State

    var filterOption: FilterOption = .all
    var sortOrder: SortOrder = .dateAdded

    // MARK: - Constellation Selection (for Orb view)

    var selectedConstellationID: UUID?

    // MARK: - Computed

    var isFilteringByConstellation: Bool {
        if case .constellation = filterOption {
            return true
        }
        return false
    }

    var selectedConstellationIDFromFilter: UUID? {
        if case .constellation(let id) = filterOption {
            return id
        }
        return nil
    }

    // MARK: - Actions

    func selectConstellation(_ constellation: Constellation?) {
        if let constellation = constellation {
            filterOption = .constellation(constellation.id)
            selectedConstellationID = constellation.id
        } else {
            filterOption = .all
            selectedConstellationID = nil
        }
    }

    func clearFilter() {
        filterOption = .all
        selectedConstellationID = nil
    }
}
