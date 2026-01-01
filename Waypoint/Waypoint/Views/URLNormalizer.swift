//
//  URLNormalizer.swift
//  Waypoint
//
//  Created on December 31, 2025.
//

import Foundation

// MARK: - URL Normalizer

enum URLNormalizer {

    struct Normalized: Hashable {
        let scheme: String?
        let host: String?
        let path: String
        let query: String?
        let fragment: String?
        let filePath: String?
    }

    static func normalized(_ url: URL) -> Normalized? {
        normalized(url.absoluteString)
    }

    static func normalized(_ raw: String) -> Normalized? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.isFileURL {
            return Normalized(
                scheme: "file",
                host: nil,
                path: "",
                query: nil,
                fragment: nil,
                filePath: url.standardizedFileURL.path.lowercased()
            )
        }

        let prepared = ensureScheme(for: trimmed)
        guard var components = URLComponents(string: prepared) else {
            return Normalized(
                scheme: nil,
                host: nil,
                path: trimmed,
                query: nil,
                fragment: nil,
                filePath: nil
            )
        }

        if let scheme = components.scheme {
            components.scheme = scheme.lowercased()
        }

        if let host = components.host {
            components.host = normalizeHost(host)
        }

        if components.path.isEmpty {
            components.path = "/"
        }

        if components.path.hasSuffix("/") && components.path.count > 1 {
            components.path.removeLast()
        }

        return Normalized(
            scheme: components.scheme,
            host: components.host,
            path: components.path,
            query: components.query,
            fragment: components.fragment,
            filePath: nil
        )
    }

    static func matches(_ lhs: String, _ rhs: String) -> Bool {
        normalized(lhs) == normalized(rhs)
    }

    private static func ensureScheme(for raw: String) -> String {
        if raw.contains("://") {
            return raw
        }

        if raw.contains(".") && !raw.contains(" ") {
            return "https://" + raw
        }

        return raw
    }

    private static func normalizeHost(_ host: String) -> String {
        var normalized = host.lowercased()
        let prefixes = ["www.", "m.", "mobile."]
        for prefix in prefixes where normalized.hasPrefix(prefix) {
            normalized = String(normalized.dropFirst(prefix.count))
            break
        }
        return normalized
    }
}
