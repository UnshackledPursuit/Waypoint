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
    case icloud     // icloud.com URLs
    case app        // Custom schemes (notion://, etc.)
    
    static func detect(from url: URL) -> PortalType {
        if url.scheme == "file" { return .file }
        if url.host?.contains("icloud.com") == true { return .icloud }
        if url.scheme == "http" || url.scheme == "https" { return .web }
        return .app
    }
}

// MARK: - Portal Model

struct Portal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String
    var type: PortalType
    var thumbnailData: Data?        // Auto-fetched favicon
    var customThumbnail: Data?      // User override
    var useCustomThumbnail: Bool
    var dateAdded: Date
    var lastOpened: Date?
    var isFavorite: Bool
    var isPinned: Bool              // Pin to top of list
    var tags: [String]              // For future organization
    
    // Computed property for display
    var displayThumbnail: Data? {
        useCustomThumbnail ? customThumbnail : thumbnailData
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        type: PortalType? = nil,
        thumbnailData: Data? = nil,
        customThumbnail: Data? = nil,
        useCustomThumbnail: Bool = false,
        dateAdded: Date = Date(),
        lastOpened: Date? = nil,
        isFavorite: Bool = false,
        isPinned: Bool = false,
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
        self.useCustomThumbnail = useCustomThumbnail
        self.dateAdded = dateAdded
        self.lastOpened = lastOpened
        self.isFavorite = isFavorite
        self.isPinned = isPinned
        self.tags = tags
    }
}

// MARK: - Sample Data

extension Portal {
    static var sample: Portal {
        Portal(
            name: "Claude AI",
            url: "https://claude.ai",
            type: .web,
            isFavorite: true
        )
    }
    
    static var samples: [Portal] {
        [
            Portal(name: "Claude AI", url: "https://claude.ai", type: .web, isFavorite: true),
            Portal(name: "Gmail", url: "https://mail.google.com", type: .web),
            Portal(name: "Calendar", url: "https://calendar.google.com", type: .web),
            Portal(name: "Notion", url: "https://notion.so", type: .web, isFavorite: true),
            Portal(name: "GitHub", url: "https://github.com", type: .web)
        ]
    }
}
