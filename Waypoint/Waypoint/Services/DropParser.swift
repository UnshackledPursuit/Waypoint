//
//  DropParser.swift
//  Waypoint
//
//  Created on December 29, 2024.
//

import Foundation
import UniformTypeIdentifiers

// MARK: - Drop Parser

/// Extracts URLs from NSItemProvider payloads.
enum DropParser {

    // MARK: - Public

    static func extractURLs(from providers: [NSItemProvider]) async -> [URL] {
        var webURLs: [URL] = []
        var fileURLs: [URL] = []

        // First pass: get web URLs from url type AND text (Safari provides URLs as text)
        for provider in providers {
            var gotWebURL = false

            // Try URL type first
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                if let url = await loadSingleURL(ofType: UTType.url, from: provider) {
                    if !url.isFileURL {
                        webURLs.append(url)
                        gotWebURL = true
                    }
                }
            }

            // Also try text extraction for web URLs (Safari uses this)
            if !gotWebURL && provider.canLoadObject(ofClass: NSString.self) {
                if let string = await loadSingleString(from: provider) {
                    let urls = extractURLs(from: string).filter { !$0.isFileURL }
                    if !urls.isEmpty {
                        webURLs += urls
                        gotWebURL = true
                    }
                }
            }
        }

        // If we got ANY web URLs, return only those (skip file processing)
        // This prevents RTFD duplicates when dropping Notes links
        if !webURLs.isEmpty {
            return dedupePreservingOrder(webURLs)
        }

        // No web URLs found - this is a pure file drop, process files
        for provider in providers {
            // Try fileURL type
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                if let url = await loadSingleURL(ofType: UTType.fileURL, from: provider) {
                    // Skip RTFD files
                    if url.pathExtension.lowercased() == "rtfd" { continue }
                    fileURLs.append(url)
                    continue
                }
            }

            // Try file representation
            if let typeIdentifier = fileRepresentationTypeIdentifier(for: provider) {
                if let url = await loadSingleFileRepresentation(from: provider, typeIdentifier: typeIdentifier) {
                    // Skip RTFD files
                    if url.pathExtension.lowercased() == "rtfd" { continue }
                    fileURLs.append(url)
                }
            }
        }

        return dedupePreservingOrder(fileURLs)
    }

    private static func loadSingleString(from provider: NSItemProvider) async -> String? {
        await withCheckedContinuation { continuation in
            _ = provider.loadObject(ofClass: NSString.self) { object, _ in
                continuation.resume(returning: (object as? NSString) as String?)
            }
        }
    }

    // MARK: - Single Item Loading

    private static func loadSingleURL(ofType type: UTType, from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: type.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    continuation.resume(returning: url)
                    return
                }

                if let data = item as? Data,
                   let string = String(data: data, encoding: .utf8),
                   let url = URL(string: string) {
                    continuation.resume(returning: url)
                    return
                }

                continuation.resume(returning: nil)
            }
        }
    }

    private static func loadSingleFileRepresentation(from provider: NSItemProvider, typeIdentifier: String) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, _ in
                continuation.resume(returning: url)
            }
        }
    }

    // MARK: - Helpers

    private static func extractURLs(from string: String) -> [URL] {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let detected = detectURLs(in: trimmed)
        if !detected.isEmpty {
            return detected
        }

        if let url = stringToURL(trimmed) {
            return [url]
        }

        return []
    }

    private static func detectURLs(in string: String) -> [URL] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }

        let range = NSRange(string.startIndex..., in: string)
        let matches = detector.matches(in: string, options: [], range: range)
        return matches.compactMap { $0.url }
    }

    private static func stringToURL(_ string: String) -> URL? {
        if let url = URL(string: string), url.scheme != nil {
            return url
        }

        if string.contains(".") && !string.contains(" ") {
            return URL(string: "https://" + string)
        }

        return nil
    }

    private static func dedupePreservingOrder(_ urls: [URL]) -> [URL] {
        var seen = Set<String>()
        return urls.filter { url in
            let key = normalize(url)
            return seen.insert(key).inserted
        }
    }

    private static func normalize(_ url: URL) -> String {
        var s = url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasSuffix("/") { s.removeLast() }
        return s.lowercased()
    }

    private static func fileRepresentationTypeIdentifier(for provider: NSItemProvider) -> String? {
        let candidates = [
            UTType.fileURL.identifier,
            UTType.pdf.identifier,
            UTType.item.identifier,
            UTType.data.identifier
        ]

        for candidate in candidates where provider.hasItemConformingToTypeIdentifier(candidate) {
            return candidate
        }

        return nil
    }
}
