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
    var icon: String? = nil
    var color: Color = .secondary
    let onBack: (() -> Void)?
    let trailing: AnyView?

    /// Use capsule style (like section headers) instead of chevron style
    var useCapsuleStyle: Bool = true

    /// When true, hide the title and only show the icon (for narrow views)
    var isCompact: Bool = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            if useCapsuleStyle {
                // Clean capsule label style (matches section headers)
                capsuleLabel
            } else {
                // Legacy chevron style
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
            }

            Spacer()

            if let trailing {
                trailing
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Capsule Label

    @ViewBuilder
    private var capsuleLabel: some View {
        Button(action: { onBack?() }) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(color)
                }

                // Hide title in compact mode (narrow views)
                if !isCompact {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, isCompact ? 8 : 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Capsule Style") {
    OrbTopBar(title: "Quick Access", icon: "bolt.fill", color: .green, onBack: {}, trailing: nil)
        .padding()
}

#Preview("Legacy Style") {
    OrbTopBar(title: "Focus", onBack: {}, trailing: nil, useCapsuleStyle: false)
        .padding()
}
