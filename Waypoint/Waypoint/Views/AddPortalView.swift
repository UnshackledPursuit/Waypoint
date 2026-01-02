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

    // Custom styling state
    @State private var useCustomStyle: Bool = false
    @State private var customColorHex: String = "#3B82F6"  // Default blue
    @State private var customInitials: String = ""

    // Predefined colors for picker
    private let colorOptions: [(name: String, hex: String)] = [
        ("Red", "#F44336"),
        ("Pink", "#E91E63"),
        ("Purple", "#9C27B0"),
        ("Indigo", "#3F51B5"),
        ("Blue", "#2196F3"),
        ("Cyan", "#00BCD4"),
        ("Teal", "#009688"),
        ("Green", "#4CAF50"),
        ("Orange", "#FF9800"),
        ("Deep Orange", "#FF5722"),
    ]

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
            _useCustomStyle = State(initialValue: portal.useCustomStyle)
            _customColorHex = State(initialValue: portal.customColorHex ?? "#3B82F6")
            _customInitials = State(initialValue: portal.customInitials ?? "")
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

            // Custom avatar section (only in edit mode)
            if isEditing {
                Section("Custom Avatar") {
                    Toggle("Use Custom Style", isOn: $useCustomStyle)

                    if useCustomStyle {
                        // Initials field
                        HStack {
                            Text("Initials")
                            Spacer()
                            TextField("1-3 chars", text: $customInitials)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: customInitials) { _, newValue in
                                    // Limit to 3 characters
                                    if newValue.count > 3 {
                                        customInitials = String(newValue.prefix(3))
                                    }
                                }
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.subheadline)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                                ForEach(colorOptions, id: \.hex) { option in
                                    Button {
                                        customColorHex = option.hex
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: option.hex))
                                                .frame(width: 36, height: 36)

                                            if customColorHex == option.hex {
                                                Circle()
                                                    .strokeBorder(.white, lineWidth: 3)
                                                    .frame(width: 36, height: 36)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
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
            // Thumbnail or vibrant colored avatar
            ZStack {
                if !useCustomStyle,
                   let portal = editingPortal,
                   let thumbnailData = portal.displayThumbnail,
                   let uiImage = UIImage(data: thumbnailData) {
                    // Show actual favicon if not using custom style
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Vibrant colored fallback (uses custom color if enabled)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    heroDisplayColor.opacity(0.95),
                                    heroDisplayColor.opacity(0.7)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 35
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: heroDisplayColor.opacity(0.5), radius: 6, y: 3)

                    Text(heroDisplayInitials)
                        .font(.system(size: heroDisplayInitials.count > 1 ? 20 : 26, weight: .bold))
                        .foregroundStyle(.white)
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
        .padding(.vertical, 4)
    }

    /// Computed fallback color based on current URL
    private var currentFallbackColor: Color {
        guard !url.isEmpty,
              let urlObj = URL(string: url) ?? URL(string: "https://" + url),
              let host = urlObj.host else {
            return .blue
        }
        return Color.fromHost(host)
    }

    /// Display color for hero - uses custom if enabled, otherwise auto
    private var heroDisplayColor: Color {
        if useCustomStyle {
            return Color(hex: customColorHex)
        }
        return currentFallbackColor
    }

    /// Display initials for hero - uses custom if enabled, otherwise first letter of name
    private var heroDisplayInitials: String {
        if useCustomStyle && !customInitials.isEmpty {
            return String(customInitials.prefix(3)).uppercased()
        }
        return name.isEmpty ? "?" : String(name.prefix(1)).uppercased()
    }

    // MARK: - Preview

    private var portalPreview: some View {
        HStack(spacing: 12) {
            // Vibrant colored thumbnail preview
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentFallbackColor.opacity(0.95),
                                currentFallbackColor.opacity(0.7)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: currentFallbackColor.opacity(0.4), radius: 4, y: 2)

                if !name.isEmpty {
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "link.circle")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
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

            // Update custom styling
            updatedPortal.useCustomStyle = useCustomStyle
            updatedPortal.customColorHex = useCustomStyle ? customColorHex : nil
            updatedPortal.customInitials = useCustomStyle && !customInitials.isEmpty ? customInitials : nil

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
