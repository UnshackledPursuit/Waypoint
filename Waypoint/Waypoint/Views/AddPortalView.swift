//
//  AddPortalView.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI

struct AddPortalView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    
    let editingPortal: Portal?
    
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var isFavorite: Bool = false
    @State private var isPinned: Bool = false
    
    private var isEditing: Bool {
        editingPortal != nil
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Initialization
    
    init(editingPortal: Portal? = nil) {
        self.editingPortal = editingPortal
        
        // Initialize state from editing portal if provided
        if let portal = editingPortal {
            _name = State(initialValue: portal.name)
            _url = State(initialValue: portal.url)
            _isFavorite = State(initialValue: portal.isFavorite)
            _isPinned = State(initialValue: portal.isPinned)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name, prompt: Text("YouTube"))
                    
                    TextField("URL", text: $url, prompt: Text("youtube.com"))
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    Toggle("Pin to Top", isOn: $isPinned)
                    
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                Section {
                    portalPreview
                } header: {
                    Text("Preview")
                }
            }
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
            
            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Actions
    
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
            updatedPortal.isFavorite = isFavorite
            updatedPortal.isPinned = isPinned
            
            portalManager.update(updatedPortal)
            print("✏️ Updated portal: \(cleanedName)")
        } else {
            // Create new portal
            let newPortal = Portal(
                name: cleanedName,
                url: cleanedURL,
                isFavorite: isFavorite,
                isPinned: isPinned
            )
            
            portalManager.add(newPortal)
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
}

// MARK: - Preview

#Preview("Create") {
    AddPortalView()
        .environment(PortalManager())
}

#Preview("Edit") {
    AddPortalView(editingPortal: Portal.sample)
        .environment(PortalManager())
}
