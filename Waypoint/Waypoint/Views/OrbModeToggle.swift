//
//  OrbModeToggle.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbModeToggle: View {

    // MARK: - Properties

    @Binding var selection: OrbLayoutEngine.Layout

    // MARK: - Body

    var body: some View {
        Menu {
            ForEach(OrbLayoutEngine.Layout.allCases, id: \.self) { layout in
                Button {
                    selection = layout
                } label: {
                    Label(layout.rawValue, systemImage: selection == layout ? "checkmark" : "circle")
                }
            }
        } label: {
            Label("Layout", systemImage: "square.grid.2x2")
        }
        .buttonStyle(.bordered)
    }
}

// MARK: - Preview

#Preview {
    OrbModeToggle(selection: .constant(.auto))
        .padding()
}
