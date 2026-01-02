//
//  NavigationState.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Filter Option

enum FilterOption: Hashable {
    case all
    case pinned
    case constellation(UUID)

    var displayName: String {
        switch self {
        case .all: return "All"
        case .pinned: return "Pinned"
        case .constellation: return "Constellation"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .pinned: return "pin.fill"
        case .constellation: return "star.fill"
        }
    }
}

// MARK: - Sort Order

enum SortOrder: String, CaseIterable {
    case custom = "Custom"
    case dateAdded = "Date Added"
    case recent = "Recently Used"
    case name = "Name"

    var icon: String {
        switch self {
        case .custom: return "hand.draw"
        case .dateAdded: return "calendar"
        case .recent: return "clock"
        case .name: return "textformat"
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
