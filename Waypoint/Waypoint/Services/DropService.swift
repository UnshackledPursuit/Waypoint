//
//  DropService.swift
//  Waypoint
//
//  Created on December 29, 2024.
//

import Foundation
import UniformTypeIdentifiers

// MARK: - Drop Service

/// Handles drag & drop operations for portal creation
enum DropService {

    // MARK: - Portal Creation from URLs

    /// Creates portals from dropped URLs
    static func createPortals(from urls: [URL]) -> [Portal] {
        urls.map { createPortal(from: $0) }
    }

    /// Creates a single portal from a URL
    static func createPortal(from url: URL) -> Portal {
        let name = extractSmartName(from: url)
        let type = PortalType.detect(from: url)

        return Portal(
            name: name,
            url: url.absoluteString,
            type: type
        )
    }

    // MARK: - Smart Name Extraction

    /// Extracts an intelligent name from a URL
    static func extractSmartName(from url: URL) -> String {
        // 1. Check for iCloud URLs with fragments (Notes, Freeform)
        if let host = url.host, host.contains("icloud.com") {
            if let fragment = url.fragment {
                // Clean fragment: replace underscores, decode percent encoding
                let cleaned = fragment
                    .replacingOccurrences(of: "_", with: " ")
                    .removingPercentEncoding ?? fragment
                return cleaned
            }
        }

        // 2. Check for file URLs - use filename
        if url.scheme == "file" {
            let filename = url.deletingPathExtension().lastPathComponent
            if !filename.isEmpty {
                return filename.replacingOccurrences(of: "_", with: " ")
            }
        }

        // 3. Check for common sites with known patterns
        if let host = url.host {
            // YouTube - distinguish homepage from videos
            if host.contains("youtube.com") {
                let path = url.path
                // Homepage or empty path
                if path.isEmpty || path == "/" {
                    return "YouTube"
                }
                // Video pages
                if path.contains("watch") || url.absoluteString.contains("v=") {
                    return "YouTube Video"
                }
                // Other YouTube pages (channels, playlists, etc.)
                return "YouTube"
            }
            if host.contains("youtu.be") {
                return "YouTube Video"
            }

            // GitHub repos
            if host.contains("github.com") {
                let pathComponents = url.pathComponents.filter { $0 != "/" }
                if pathComponents.count >= 2 {
                    return "\(pathComponents[0])/\(pathComponents[1])"
                }
            }

            // Notion pages
            if host.contains("notion.") {
                return "Notion Page"
            }

            // Figma files
            if host.contains("figma.com") {
                return "Figma Design"
            }
        }

        // 4. Fallback: Clean domain name
        if let host = url.host {
            return cleanDomainName(host)
        }

        // 5. Ultimate fallback
        return "New Portal"
    }

    /// Cleans a domain name for display
    private static func cleanDomainName(_ host: String) -> String {
        var name = host

        // Remove common prefixes
        let prefixes = ["www.", "m.", "mobile.", "app."]
        for prefix in prefixes {
            if name.hasPrefix(prefix) {
                name = String(name.dropFirst(prefix.count))
            }
        }

        // Remove TLD for cleaner display
        let tlds = [".com", ".org", ".net", ".io", ".co", ".ai", ".app", ".dev"]
        for tld in tlds {
            if name.hasSuffix(tld) {
                name = String(name.dropLast(tld.count))
                break
            }
        }

        // Capitalize first letter
        return name.prefix(1).uppercased() + name.dropFirst()
    }

    // MARK: - Batch Processing

    /// Determines if batch confirmation should be shown
    static func shouldShowBatchConfirmation(itemCount: Int) -> Bool {
        itemCount >= 6
    }

    /// Summary text for batch operations
    static func batchSummaryText(for urls: [URL]) -> String {
        let webCount = urls.filter { PortalType.detect(from: $0) == .web }.count
        let fileCount = urls.filter { PortalType.detect(from: $0) == .file }.count
        let usdzCount = urls.filter { PortalType.detect(from: $0) == .usdz }.count
        let folderCount = urls.filter { PortalType.detect(from: $0) == .folder }.count

        var parts: [String] = []
        if webCount > 0 { parts.append("\(webCount) link\(webCount == 1 ? "" : "s")") }
        if fileCount > 0 { parts.append("\(fileCount) file\(fileCount == 1 ? "" : "s")") }
        if usdzCount > 0 { parts.append("\(usdzCount) 3D model\(usdzCount == 1 ? "" : "s")") }
        if folderCount > 0 { parts.append("\(folderCount) folder\(folderCount == 1 ? "" : "s")") }

        return parts.joined(separator: ", ")
    }
}
