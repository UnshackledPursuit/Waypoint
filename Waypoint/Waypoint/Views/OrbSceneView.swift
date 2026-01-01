//
//  OrbSceneView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbSceneView: View {

    // MARK: - Properties

    @ObservedObject var sceneState: OrbSceneState

    // MARK: - Body

    var body: some View {
        NavigationStack {
            OrbContainerView(sceneState: sceneState)
        }
    }
}

// MARK: - Preview

#Preview {
    OrbSceneView(sceneState: OrbSceneState())
        .environment(PortalManager())
        .environment(ConstellationManager())
}
