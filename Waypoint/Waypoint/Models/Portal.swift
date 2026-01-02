//
//  Portal.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import Foundation
import SwiftUI

// MARK: - Portal Type

enum PortalType: String, Codable {
    case web        // https://, http://
    case file       // file:// (general files)
    case pdf        // PDF documents
    case note       // Apple Notes
    case freeform   // Apple Freeform boards
    case usdz       // .usdz 3D files
    case folder     // Folder references
    case icloud     // icloud.com URLs (generic)
    case icloudDrive // iCloud Drive files
    case numbers    // Apple Numbers
    case pages      // Apple Pages
    case keynote    // Apple Keynote
    case app        // Custom schemes (notion://, etc.)

    static func detect(from url: URL) -> PortalType {
        let ext = url.pathExtension.lowercased()
        let urlString = url.absoluteString.lowercased()
        let path = url.path.lowercased()

        // Check file extensions first
        if ext == "usdz" { return .usdz }
        if ext == "pdf" { return .pdf }
        if ext == "numbers" { return .numbers }
        if ext == "pages" { return .pages }
        if ext == "key" || ext == "keynote" { return .keynote }

        // Check for Apple app URLs and iCloud links
        // Freeform detection
        if urlString.contains("freeform") || url.scheme == "freeform" ||
           urlString.contains("com.apple.freeform") { return .freeform }

        // Notes detection - various URL patterns
        if urlString.contains("applenotes") || urlString.contains("notes.app") ||
           url.scheme == "applenotes" || url.scheme == "mobilenotes" ||
           urlString.contains("com.apple.notes") ||
           (url.host?.contains("icloud.com") == true && urlString.contains("/notes/")) { return .note }

        // iCloud.com URL pattern detection
        if url.host?.contains("icloud.com") == true {
            // Check path components for app-specific patterns
            if urlString.contains("/numbers/") || path.contains("numbers") { return .numbers }
            if urlString.contains("/pages/") || path.contains("pages") { return .pages }
            if urlString.contains("/keynote/") || path.contains("keynote") { return .keynote }
            if urlString.contains("/freeform/") || path.contains("freeform") { return .freeform }
            if urlString.contains("/notes/") || path.contains("notes") { return .note }
            if urlString.contains("/iclouddrive/") || urlString.contains("/drive/") { return .icloudDrive }
            return .icloud
        }

        // Check for folders
        if url.hasDirectoryPath { return .folder }

        // Check scheme-based types
        if url.scheme == "file" { return .file }
        if url.scheme == "http" || url.scheme == "https" { return .web }
        return .app
    }

    var iconName: String {
        switch self {
        case .web: return "globe"
        case .file: return "doc.fill"
        case .pdf: return "doc.text.fill"
        case .note: return "note.text"
        case .freeform: return "pencil.and.scribble"
        case .usdz: return "cube.fill"
        case .folder: return "folder.fill"
        case .icloud: return "icloud.fill"
        case .icloudDrive: return "externaldrive.fill.badge.icloud"
        case .numbers: return "tablecells.fill"
        case .pages: return "doc.richtext.fill"
        case .keynote: return "play.rectangle.fill"
        case .app: return "app.fill"
        }
    }

    /// App-specific default color (matching Apple's app colors)
    var defaultColor: Color {
        switch self {
        case .web: return Color(red: 0.2, green: 0.2, blue: 0.25)       // Dark gray/black for Safari
        case .file: return Color(red: 0.0, green: 0.48, blue: 1.0)     // Blue (generic file)
        case .pdf: return Color(red: 0.96, green: 0.26, blue: 0.21)    // Red for PDF
        case .note: return Color(red: 0.98, green: 0.80, blue: 0.18)   // Yellow for Notes
        case .freeform: return Color(red: 0.4, green: 0.7, blue: 0.95) // Soft blue for Freeform
        case .usdz: return Color(red: 0.35, green: 0.35, blue: 0.40)   // Gray for 3D
        case .folder: return Color(red: 0.30, green: 0.69, blue: 0.31) // Green for Folders/Files
        case .icloud: return Color(red: 0.35, green: 0.60, blue: 0.95) // iCloud blue
        case .icloudDrive: return Color(red: 0.30, green: 0.69, blue: 0.31) // Green for iCloud Drive (Files app)
        case .numbers: return Color(red: 0.20, green: 0.78, blue: 0.35) // Numbers green
        case .pages: return Color(red: 1.0, green: 0.58, blue: 0.0)    // Pages orange
        case .keynote: return Color(red: 0.0, green: 0.60, blue: 0.98) // Keynote blue
        case .app: return Color(red: 0.50, green: 0.50, blue: 0.55)    // Gray for unknown apps
        }
    }

    /// Display name for the type
    var displayName: String {
        switch self {
        case .web: return "Website"
        case .file: return "File"
        case .pdf: return "PDF"
        case .note: return "Note"
        case .freeform: return "Freeform"
        case .usdz: return "3D Model"
        case .folder: return "Folder"
        case .icloud: return "iCloud"
        case .icloudDrive: return "iCloud Drive"
        case .numbers: return "Numbers"
        case .pages: return "Pages"
        case .keynote: return "Keynote"
        case .app: return "App"
        }
    }

    /// Whether this type should show a source badge
    var showSourceBadge: Bool {
        switch self {
        case .web: return false
        case .file, .pdf, .note, .freeform, .usdz, .folder, .icloud, .icloudDrive, .numbers, .pages, .keynote, .app: return true
        }
    }

    /// All available icons for custom selection
    static let availableIcons: [String] = [
        "globe", "doc.fill", "doc.text.fill", "note.text", "pencil.and.scribble",
        "cube.fill", "folder.fill", "icloud.fill", "externaldrive.fill.badge.icloud",
        "tablecells.fill", "doc.richtext.fill", "play.rectangle.fill", "app.fill",
        "link", "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "bookmark.fill", "tag.fill", "photo.fill", "video.fill",
        "music.note", "gamecontroller.fill", "briefcase.fill", "cart.fill",
        "creditcard.fill", "house.fill", "building.2.fill", "mappin.circle.fill"
    ]
}

// MARK: - Portal Model

struct Portal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String
    var type: PortalType
    var thumbnailData: Data?        // Auto-fetched favicon
    var customThumbnail: Data?      // User override image
    var customColorHex: String?     // Custom fallback color (hex)
    var customInitials: String?     // Custom initials (1-3 chars)
    var customIcon: String?         // Custom SF Symbol icon name
    var useCustomThumbnail: Bool    // Use custom image instead of auto
    var useCustomStyle: Bool        // Use custom color/initials/icon instead of auto
    var useIconInsteadOfInitials: Bool  // Toggle: true = show icon, false = show initials
    var keepFaviconWithCustomStyle: Bool  // Keep favicon but use custom color for glow
    var dateAdded: Date
    var lastOpened: Date?
    var isFavorite: Bool
    var isPinned: Bool              // Pin to top of list
    var sortIndex: Int              // For manual ordering
    var tags: [String]              // For future organization

    // Computed property for display
    var displayThumbnail: Data? {
        useCustomThumbnail ? customThumbnail : thumbnailData
    }

    /// Returns true if this portal has any custom styling (image, color, or initials)
    var hasCustomStyling: Bool {
        useCustomThumbnail || useCustomStyle
    }

    /// Returns the icon to display - custom if set, otherwise type default
    var displayIcon: String {
        if useCustomStyle, let icon = customIcon, !icon.isEmpty {
            return icon
        }
        return type.iconName
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        type: PortalType? = nil,
        thumbnailData: Data? = nil,
        customThumbnail: Data? = nil,
        customColorHex: String? = nil,
        customInitials: String? = nil,
        customIcon: String? = nil,
        useCustomThumbnail: Bool = false,
        useCustomStyle: Bool = false,
        useIconInsteadOfInitials: Bool = true,  // Default to icon
        keepFaviconWithCustomStyle: Bool = false,  // Keep favicon with custom glow
        dateAdded: Date = Date(),
        lastOpened: Date? = nil,
        isFavorite: Bool = false,
        isPinned: Bool = false,
        sortIndex: Int = Int.max,  // New portals go to end
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.url = url

        // Auto-detect type if not provided
        if let type = type {
            self.type = type
        } else if let urlObject = URL(string: url) {
            self.type = PortalType.detect(from: urlObject)
        } else {
            self.type = .web // Fallback
        }

        self.thumbnailData = thumbnailData
        self.customThumbnail = customThumbnail
        self.customColorHex = customColorHex
        self.customInitials = customInitials
        self.customIcon = customIcon
        self.useCustomThumbnail = useCustomThumbnail
        self.useCustomStyle = useCustomStyle
        self.useIconInsteadOfInitials = useIconInsteadOfInitials
        self.keepFaviconWithCustomStyle = keepFaviconWithCustomStyle
        self.dateAdded = dateAdded
        self.lastOpened = lastOpened
        self.isFavorite = isFavorite
        self.isPinned = isPinned
        self.sortIndex = sortIndex
        self.tags = tags
    }
}

// MARK: - Sample Data

extension Portal {
    // Fixed UUIDs for sample data (so constellations can reference them)
    static let sampleIDs = (
        youtube: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        claude: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        chatgpt: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        gemini: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        grok: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        xcom: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
        gmail: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        googleDocs: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
        github: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
        notion: UUID(uuidString: "00000000-0000-0000-0000-00000000000A")!
    )

    static var sample: Portal {
        Portal(
            id: sampleIDs.claude,
            name: "Claude",
            url: "https://claude.ai",
            type: .web,
            isFavorite: true
        )
    }

    static var samples: [Portal] {
        [
            Portal(id: sampleIDs.youtube, name: "YouTube", url: "https://www.youtube.com", type: .web, isPinned: true),
            Portal(id: sampleIDs.claude, name: "Claude", url: "https://claude.ai", type: .web, isFavorite: true),
            Portal(id: sampleIDs.chatgpt, name: "ChatGPT", url: "https://chat.openai.com", type: .web),
            Portal(id: sampleIDs.gemini, name: "Gemini", url: "https://gemini.google.com", type: .web),
            Portal(id: sampleIDs.grok, name: "Grok", url: "https://grok.x.ai", type: .web),
            Portal(id: sampleIDs.xcom, name: "X", url: "https://x.com", type: .web),
            Portal(id: sampleIDs.gmail, name: "Gmail", url: "https://mail.google.com", type: .web),
            Portal(id: sampleIDs.googleDocs, name: "Google Docs", url: "https://docs.google.com", type: .web),
            Portal(id: sampleIDs.github, name: "GitHub", url: "https://github.com", type: .web),
            Portal(id: sampleIDs.notion, name: "Notion", url: "https://notion.so", type: .web)
        ]
    }
}
