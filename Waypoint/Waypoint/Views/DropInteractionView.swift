//
//  DropInteractionView.swift
//  Waypoint
//
//  Created on December 29, 2024.
//

import SwiftUI
import UIKit

// MARK: - Drop Interaction View

/// UIKit-backed drop target to improve visionOS drag/drop reliability.
struct DropInteractionView: UIViewRepresentable {
    let allowedTypeIdentifiers: [String]
    let onTargetedChange: (Bool) -> Void
    let onDrop: ([NSItemProvider]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(allowedTypeIdentifiers: allowedTypeIdentifiers, onTargetedChange: onTargetedChange, onDrop: onDrop)
    }

    func makeUIView(context: Context) -> UIView {
        let view = PassthroughDropView(frame: .zero)
        view.backgroundColor = .clear
        view.addInteraction(UIDropInteraction(delegate: context.coordinator))
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIDropInteractionDelegate {
        private let allowedTypeIdentifiers: [String]
        private let onTargetedChange: (Bool) -> Void
        private let onDrop: ([NSItemProvider]) -> Void

        init(allowedTypeIdentifiers: [String], onTargetedChange: @escaping (Bool) -> Void, onDrop: @escaping ([NSItemProvider]) -> Void) {
            self.allowedTypeIdentifiers = allowedTypeIdentifiers
            self.onTargetedChange = onTargetedChange
            self.onDrop = onDrop
        }

        func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
            session.hasItemsConforming(toTypeIdentifiers: allowedTypeIdentifiers)
        }

        func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
            onTargetedChange(true)
        }

        func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
            onTargetedChange(false)
        }

        func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
            onTargetedChange(false)
        }

        func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
            UIDropProposal(operation: .copy)
        }

        func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
            let providers = session.items.map { $0.itemProvider }
            onDrop(providers)
        }
    }
}

// MARK: - Passthrough Drop View

private final class PassthroughDropView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == .touches {
            return nil
        }
        return self
    }
}
