//
//  AddPortalView.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI
import UIKit

struct AddPortalView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager
    let editingPortal: Portal?
    let focusRequestPortalID: Binding<UUID?>?
    let dismissMicroActionsPortalID: Binding<UUID?>?

    @State private var name: String = ""
    @State private var url: String = ""
    @State private var isPinned: Bool = false
    
    private var isEditing: Bool {
        editingPortal != nil
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Initialization
    
    init(
        editingPortal: Portal? = nil,
        focusRequestPortalID: Binding<UUID?>? = nil,
        dismissMicroActionsPortalID: Binding<UUID?>? = nil
    ) {
        self.editingPortal = editingPortal
        self.focusRequestPortalID = focusRequestPortalID
        self.dismissMicroActionsPortalID = dismissMicroActionsPortalID
        
        // Initialize state from editing portal if provided
        if let portal = editingPortal {
            _name = State(initialValue: portal.name)
            _url = State(initialValue: portal.url)
            _isPinned = State(initialValue: portal.isPinned)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle(isEditing ? "Edit Portal" : "Create Portal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button(isEditing ? "Save" : "Create") {
                            savePortal()
                        }
                        .disabled(!isValid)
                    }
                }
        }
    }

    private var formContent: some View {
        Form {
            // Compact hero preview for edit mode
            if isEditing {
                portalHeroPreview
                    .listRowBackground(Color.clear)
            }

            Section {
                TextField("Name", text: $name, prompt: Text("YouTube"))

                HStack {
                    TextField("URL", text: $url, prompt: Text("youtube.com"))
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    Button {
                        pasteFromClipboard()
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .buttonStyle(.bordered)
                }

                Toggle("Pin to Top", isOn: $isPinned)
            }

            // Constellation toggles (only show when editing existing portal)
            if let portal = editingPortal, !constellationManager.constellations.isEmpty {
                Section("Constellations") {
                    constellationToggles(for: portal)
                }
            }

            // Only show preview for new portals (edit mode has hero)
            if !isEditing {
                Section("Preview") {
                    portalPreview
                }
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    private func constellationToggles(for portal: Portal) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(constellationManager.constellations) { constellation in
                    let isAssigned = constellation.portalIDs.contains(portal.id)
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            if isAssigned {
                                constellationManager.removePortal(portal.id, from: constellation)
                            } else {
                                constellationManager.addPortal(portal.id, to: constellation)
                            }
                        }
                    } label: {
                        ZStack {
                            // Use constellation orb view
                            ConstellationOrbView(
                                constellation: constellation,
                                isSelected: isAssigned,
                                size: 40,
                                showLabel: true
                            )

                            // Checkmark overlay when assigned
                            if isAssigned {
                                Circle()
                                    .fill(Color.green.opacity(0.9))
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                    .offset(x: 18, y: -20)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Hero Preview (Edit Mode)

    private var portalHeroPreview: some View {
        VStack(spacing: 8) {
            // Thumbnail or letter avatar
            ZStack {
                if let portal = editingPortal,
                   let thumbnailData = portal.displayThumbnail,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)

                    if !name.isEmpty {
                        Text(name.prefix(1).uppercased())
                            .font(.title)
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: "link.circle")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Text(name.isEmpty ? "Portal Name" : name)
                .font(.headline)
                .foregroundStyle(name.isEmpty ? .secondary : .primary)

            Text(url.isEmpty ? "portal-url.com" : cleanURL(url))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Preview

    private var portalPreview: some View {
        HStack(spacing: 12) {
            // Placeholder thumbnail
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                
                if !name.isEmpty {
                    Text(name.prefix(1).uppercased())
                        .font(.title3)
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: "link.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "Portal Name" : name)
                    .font(.headline)
                    .foregroundStyle(name.isEmpty ? .secondary : .primary)
                
                Text(url.isEmpty ? "portal-url.com" : cleanURL(url))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isPinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Actions

    private func pasteFromClipboard() {
        #if os(visionOS) || os(iOS)
        if let clipboardString = UIPasteboard.general.string {
            let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
            url = trimmed

            // Auto-fill name if empty
            if name.isEmpty {
                if let urlObj = URL(string: trimmed) ?? URL(string: "https://" + trimmed) {
                    name = DropService.extractSmartName(from: urlObj)
                }
            }
        }
        #endif
    }

    private func savePortal() {
        let cleanedName = name.trimmingCharacters(in: .whitespaces)
        var cleanedURL = url.trimmingCharacters(in: .whitespaces)
        
        // Auto-add https:// if missing and it looks like a domain
        if !cleanedURL.contains("://") {
            // Check if it looks like a domain (contains a dot and no spaces)
            if cleanedURL.contains(".") && !cleanedURL.contains(" ") {
                cleanedURL = "https://" + cleanedURL
                print("✨ Auto-added https:// to URL: \(cleanedURL)")
            }
        }
        
        // Auto-add www for common sites that need it
        if cleanedURL.hasPrefix("https://") || cleanedURL.hasPrefix("http://") {
            let commonSitesNeedingWWW = [
                "youtube.com": "www.youtube.com",
                "instagram.com": "www.instagram.com",
                "reddit.com": "www.reddit.com",
                "wikipedia.org": "www.wikipedia.org"
            ]
            
            for (bare, full) in commonSitesNeedingWWW {
                if cleanedURL.contains("://\(bare)") {
                    cleanedURL = cleanedURL.replacingOccurrences(of: "://\(bare)", with: "://\(full)")
                    print("✨ Auto-added www: \(cleanedURL)")
                    break
                }
            }
        }
        
        if let editingPortal = editingPortal {
            // Update existing portal
            var updatedPortal = editingPortal
            updatedPortal.name = cleanedName
            updatedPortal.url = cleanedURL
            updatedPortal.isPinned = isPinned
            
            portalManager.update(updatedPortal)
            dismissMicroActionsPortalID?.wrappedValue = updatedPortal.id
            print("✏️ Updated portal: \(cleanedName)")
        } else {
            if let existingPortal = portalManager.portals.first(where: { URLNormalizer.matches($0.url, cleanedURL) }) {
                focusRequestPortalID?.wrappedValue = existingPortal.id
                print("🔁 Portal already exists for this URL")

                // Trigger favicon fetch if existing portal doesn't have one
                if existingPortal.thumbnailData == nil {
                    Task {
                        await portalManager.fetchFavicon(for: existingPortal.id)
                    }
                }

                dismiss()
                return
            }

            // Create new portal
            let newPortal = Portal(
                name: cleanedName,
                url: cleanedURL,
                isPinned: isPinned
            )
            
            portalManager.add(newPortal)
            focusRequestPortalID?.wrappedValue = newPortal.id
            print("➕ Created portal: \(cleanedName)")
        }
        
        dismiss()
    }
    
    // MARK: - Utilities
    
    private func cleanURL(_ url: String) -> String {
        var cleaned = url
        
        // Remove common prefixes for display
        if cleaned.hasPrefix("https://") {
            cleaned = String(cleaned.dropFirst(8))
        } else if cleaned.hasPrefix("http://") {
            cleaned = String(cleaned.dropFirst(7))
        }
        
        // Remove trailing slash
        if cleaned.hasSuffix("/") {
            cleaned = String(cleaned.dropLast())
        }
        
        return cleaned
    }

}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String? {
        #if os(visionOS) || os(iOS)
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
        #endif
    }
}

// MARK: - Preview

#Preview("Create") {
    AddPortalView()
        .environment(PortalManager())
        .environment(ConstellationManager())
}

#Preview("Edit") {
    AddPortalView(editingPortal: Portal.sample)
        .environment(PortalManager())
        .environment(ConstellationManager())
}
