//
//  OrbTopBar.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct OrbTopBar: View {

    // MARK: - Properties

    let title: String
    let onBack: (() -> Void)?
    let trailing: AnyView?

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }

            Text(title)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            if let trailing {
                trailing
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    OrbTopBar(title: "Focus", onBack: {}, trailing: nil)
        .padding()
}
