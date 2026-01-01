//
//  ConstellationOrbView.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import SwiftUI

struct ConstellationOrbView: View {

    // MARK: - Properties

    let constellation: Constellation
    let isSelected: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(constellation.color.opacity(isSelected ? 0.35 : 0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: constellation.icon)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text(constellation.name)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

// MARK: - Preview

#Preview {
    ConstellationOrbView(constellation: .sample, isSelected: true)
        .padding()
}
