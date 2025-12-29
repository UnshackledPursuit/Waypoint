//
//  WaypointApp.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI

@main
struct WaypointApp: App {
    
    // MARK: - Properties
    
    @State private var portalManager = PortalManager()
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            PortalListView()
                .environment(portalManager)
        }
        .defaultSize(width: 400, height: 600)
    }
}
