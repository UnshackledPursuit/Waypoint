//
//  OnboardingHintView.swift
//  Waypoint
//
//  Created on January 2, 2026.
//

import SwiftUI

// MARK: - Onboarding Toast View

/// A celebratory toast shown after first portal creation
struct OnboardingToastView: View {
    let message: String
    let submessage: String
    var onDismiss: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.green)

                Text(message)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.secondary.opacity(0.2)))
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text(submessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        #if os(visionOS)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 16))
        #else
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        #endif
        .shadow(color: Color.green.opacity(0.2), radius: 10, y: 4)
        .frame(maxWidth: 320)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
            // Auto-dismiss after 6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss?()
        }
    }
}

// MARK: - Constellation Hint View

/// A hint shown after first constellation creation
struct ConstellationHintView: View {
    let constellationName: String
    var onDismiss: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.green)

                Text("\"\(constellationName)\" created!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.secondary.opacity(0.2)))
                }
                .buttonStyle(.plain)
            }

            HStack {
                Text("Long press a portal to add it")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        #if os(visionOS)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 16))
        #else
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        #endif
        .shadow(color: Color.black.opacity(0.15), radius: 10, y: 4)
        .frame(maxWidth: 320)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
            // Auto-dismiss after 6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(reduceMotion ? .none : .easeOut(duration: 0.2)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss?()
        }
    }
}

// MARK: - Onboarding State

/// Simple onboarding state using AppStorage
struct OnboardingState {
    @AppStorage("onboarding_portalCount") static var portalCount: Int = 0
    @AppStorage("onboarding_constellationCount") static var constellationCount: Int = 0
    @AppStorage("onboarding_hasShownFirstPortalHint") static var hasShownFirstPortalHint: Bool = false
    @AppStorage("onboarding_hasShownFirstConstellationHint") static var hasShownFirstConstellationHint: Bool = false
    @AppStorage("onboarding_hasShownDragHint") static var hasShownDragHint: Bool = false

    static func reset() {
        portalCount = 0
        constellationCount = 0
        hasShownFirstPortalHint = false
        hasShownFirstConstellationHint = false
        hasShownDragHint = false
        print("🔄 Onboarding state reset")
    }
}

// MARK: - Preview

#Preview("First Portal Toast") {
    OnboardingToastView(
        message: "Portal created!",
        submessage: "Tap to open • Drag more links to add"
    )
    .padding()
}

#Preview("Constellation Hint") {
    ConstellationHintView(constellationName: "Work")
        .padding()
}
