//
//  OrbSceneState.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import Foundation
import Combine

// MARK: - Orb Scene State

final class OrbSceneState: ObservableObject {

    // MARK: - Published State

    @Published var isExpanded = false
    @Published var selectedConstellationID: UUID?
    @Published var layoutMode: OrbLayoutEngine.Layout = .auto
    @Published var focusedPortalID: UUID?
}
