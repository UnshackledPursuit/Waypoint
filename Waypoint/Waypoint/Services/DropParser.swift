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
        var results: [URL] = []

        results += await loadURLs(ofType: UTType.url, from: providers)
        results += await loadURLs(ofType: UTType.fileURL, from: providers)
        results += await loadFileRepresentations(from: providers)

        let texts = await loadStrings(from: providers)
        results += texts.flatMap { extractURLs(from: $0) }

        return dedupePreservingOrder(results)
    }

    // MARK: - URL Loading

    private static func loadURLs(ofType type: UTType, from providers: [NSItemProvider]) async -> [URL] {
        await withTaskGroup(of: URL?.self) { group in
            for provider in providers where provider.hasItemConformingToTypeIdentifier(type.identifier) {
                group.addTask {
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
            }

            var urls: [URL] = []
            for await url in group {
                if let url {
                    urls.append(url)
                }
            }
            return urls
        }
    }

    private static func loadStrings(from providers: [NSItemProvider]) async -> [String] {
        await withTaskGroup(of: String?.self) { group in
            for provider in providers where provider.canLoadObject(ofClass: NSString.self) {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        _ = provider.loadObject(ofClass: NSString.self) { object, _ in
                            continuation.resume(returning: (object as? NSString) as String?)
                        }
                    }
                }
            }

            var strings: [String] = []
            for await string in group {
                if let string {
                    strings.append(string)
                }
            }
            return strings
        }
    }

    private static func loadFileRepresentations(from providers: [NSItemProvider]) async -> [URL] {
        await withTaskGroup(of: URL?.self) { group in
            for provider in providers {
                guard let typeIdentifier = fileRepresentationTypeIdentifier(for: provider) else { continue }
                group.addTask {
                    await withCheckedContinuation { continuation in
                        provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, _ in
                            continuation.resume(returning: url)
                        }
                    }
                }
            }

            var urls: [URL] = []
            for await url in group {
                if let url {
                    urls.append(url)
                }
            }
            return urls
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
