//
//  Portal.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import Foundation

// MARK: - Portal Type

enum PortalType: String, Codable {
    case web        // https://, http://
    case file       // file:// (copied to app storage)
    case usdz       // .usdz 3D files
    case folder     // Folder references
    case icloud     // icloud.com URLs
    case app        // Custom schemes (notion://, etc.)

    static func detect(from url: URL) -> PortalType {
        // Check for USDZ files first
        if url.pathExtension.lowercased() == "usdz" { return .usdz }

        // Check for folders
        if url.hasDirectoryPath { return .folder }

        // Check scheme-based types
        if url.scheme == "file" { return .file }
        if url.host?.contains("icloud.com") == true { return .icloud }
        if url.scheme == "http" || url.scheme == "https" { return .web }
        return .app
    }

    var iconName: String {
        switch self {
        case .web: return "globe"
        case .file: return "doc.fill"
        case .usdz: return "cube.fill"
        case .folder: return "folder.fill"
        case .icloud: return "icloud.fill"
        case .app: return "app.fill"
        }
    }
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
    var useCustomThumbnail: Bool    // Use custom image instead of auto
    var useCustomStyle: Bool        // Use custom color/initials instead of auto
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
        useCustomThumbnail: Bool = false,
        useCustomStyle: Bool = false,
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
        self.useCustomThumbnail = useCustomThumbnail
        self.useCustomStyle = useCustomStyle
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
