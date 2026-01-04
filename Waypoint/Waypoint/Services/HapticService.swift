//
//  HapticService.swift
//  Waypoint
//
//  Simple haptic feedback utility for iOS.
//  Note: UIFeedbackGenerator is not available on visionOS.
//  On visionOS these functions are no-ops.
//
//  Created on January 3, 2026.
//

#if canImport(UIKit)
import UIKit
#endif

/// Lightweight haptic feedback service for user interactions
/// Note: Haptic feedback is only available on iOS devices with Taptic Engine.
/// On visionOS, these functions are no-ops (haptics are handled differently via RealityKit).
enum HapticService {

    // MARK: - Impact Feedback

    /// Light tap - used for subtle confirmations (portal open, long-press trigger)
    static func lightImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    /// Medium tap - used for more significant actions (delete)
    static func mediumImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    /// Heavy tap - used for major confirmations
    static func heavyImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }

    // MARK: - Notification Feedback

    /// Success - used for positive outcomes (favorite, drop accepted, constellation assigned)
    static func success() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Warning - used for attention needed (duplicate detected)
    static func warning() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    /// Error - used for failures
    static func error() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    // MARK: - Selection Feedback

    /// Selection tick - used for picker/selection changes
    static func selection() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}
