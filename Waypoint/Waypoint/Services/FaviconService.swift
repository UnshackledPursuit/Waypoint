//
//  FaviconService.swift
//  Waypoint
//
//  Created on January 1, 2026.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Favicon Service

actor FaviconService {

    // MARK: - Singleton

    static let shared = FaviconService()

    // MARK: - Properties

    private let memoryCache: NSCache<NSString, UIImage>
    private let fileManager: FileManager
    private let session: URLSession
    private let cacheDirectoryURL: URL?

    // MARK: - Initialization

    private init() {
        // Initialize all properties in nonisolated context
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        self.session = URLSession(configuration: config)

        self.fileManager = FileManager.default
        self.cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("Favicons")

        // Configure memory cache (NSCache is thread-safe)
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        self.memoryCache = cache

        // Create cache directory if needed
        if let cacheDir = cacheDirectoryURL {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }

    private var cacheDirectory: URL? {
        cacheDirectoryURL
    }

    // MARK: - Public API

    /// Fetches favicon for a URL, using cache if available
    func fetchFavicon(for urlString: String) async -> Data? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }

        let cacheKey = host as NSString

        // Check memory cache
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage.pngData()
        }

        // Check disk cache
        if let diskData = loadFromDisk(host: host) {
            if let image = UIImage(data: diskData) {
                memoryCache.setObject(image, forKey: cacheKey)
            }
            return diskData
        }

        // Fetch from network
        return await fetchFromNetwork(host: host, originalURL: url)
    }

    /// Extracts the dominant color from favicon data
    func extractDominantColor(from imageData: Data) -> Color? {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            return nil
        }

        return dominantColor(from: cgImage)
    }

    /// Clears all cached favicons
    func clearCache() {
        memoryCache.removeAllObjects()
        if let cacheDir = cacheDirectory {
            try? fileManager.removeItem(at: cacheDir)
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }

    // MARK: - Network Fetching

    private func fetchFromNetwork(host: String, originalURL: URL) async -> Data? {
        // Try multiple favicon sources in order of reliability
        let sources = faviconSources(for: host, originalURL: originalURL)

        for source in sources {
            if let data = await fetchImage(from: source) {
                // Validate it's actually an image
                if let image = UIImage(data: data), image.size.width > 0 {
                    // Resize to standard size (64x64) for consistency
                    if let resized = resizeImage(image, to: CGSize(width: 64, height: 64)),
                       let resizedData = resized.pngData() {
                        // Cache the result
                        saveToDisk(data: resizedData, host: host)
                        memoryCache.setObject(resized, forKey: host as NSString)
                        return resizedData
                    }
                }
            }
        }

        return nil
    }

    private func faviconSources(for host: String, originalURL: URL) -> [URL] {
        var sources: [URL] = []

        // 1. DuckDuckGo Icons API (fast, reliable, no redirects)
        if let ddgURL = URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico") {
            sources.append(ddgURL)
        }

        // 2. Direct favicon.ico from site
        if let scheme = originalURL.scheme {
            if let directURL = URL(string: "\(scheme)://\(host)/favicon.ico") {
                sources.append(directURL)
            }
        }

        // 3. Apple touch icon (often higher quality)
        if let scheme = originalURL.scheme {
            if let appleURL = URL(string: "\(scheme)://\(host)/apple-touch-icon.png") {
                sources.append(appleURL)
            }
        }

        // 4. Google Favicon Service with redirect following
        if let googleURL = URL(string: "https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://\(host)&size=128") {
            sources.append(googleURL)
        }

        return sources
    }

    private func fetchImage(from url: URL) async -> Data? {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            return data
        } catch {
            return nil
        }
    }

    // MARK: - Image Processing

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func dominantColor(from cgImage: CGImage) -> Color? {
        let width = 10
        let height = 10

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else {
            return nil
        }

        let pointer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)

        var totalR: Int = 0
        var totalG: Int = 0
        var totalB: Int = 0
        var count: Int = 0

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = Int(pointer[offset])
                let g = Int(pointer[offset + 1])
                let b = Int(pointer[offset + 2])
                let a = Int(pointer[offset + 3])

                // Skip transparent and near-white/near-black pixels
                if a > 128 {
                    let brightness = (r + g + b) / 3
                    if brightness > 30 && brightness < 225 {
                        totalR += r
                        totalG += g
                        totalB += b
                        count += 1
                    }
                }
            }
        }

        guard count > 0 else {
            return Color.blue // Default fallback
        }

        let avgR = Double(totalR) / Double(count) / 255.0
        let avgG = Double(totalG) / Double(count) / 255.0
        let avgB = Double(totalB) / Double(count) / 255.0

        // Boost saturation slightly for more vibrant orb colors
        return Color(red: avgR, green: avgG, blue: avgB)
    }

    // MARK: - Disk Cache

    private func diskCachePath(for host: String) -> URL? {
        let sanitized = host.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        return cacheDirectory?.appendingPathComponent("\(sanitized).png")
    }

    private func saveToDisk(data: Data, host: String) {
        guard let path = diskCachePath(for: host) else { return }
        try? data.write(to: path)
    }

    private func loadFromDisk(host: String) -> Data? {
        guard let path = diskCachePath(for: host),
              fileManager.fileExists(atPath: path.path) else {
            return nil
        }
        return try? Data(contentsOf: path)
    }
}

// MARK: - Portal Extension

extension Portal {

    /// Fetches and returns the dominant color from this portal's favicon
    func fetchDominantColor() async -> Color? {
        guard let thumbnailData = displayThumbnail else {
            return nil
        }
        return await FaviconService.shared.extractDominantColor(from: thumbnailData)
    }

    /// Returns the display color - custom if set, otherwise auto-generated from host
    var displayColor: Color {
        // Use custom color if enabled and set
        if useCustomStyle, let hexColor = customColorHex {
            return Color(hex: hexColor)
        }
        // Otherwise auto-generate from URL host
        return fallbackColor
    }

    /// Returns a consistent color based on the portal's URL host
    var fallbackColor: Color {
        guard let url = URL(string: self.url),
              let host = url.host else {
            return .blue
        }
        return Color.fromHost(host)
    }

    /// Returns the display initials - custom if set, otherwise first letter of name
    var displayInitials: String {
        // Use custom initials if enabled and set
        if useCustomStyle, let initials = customInitials, !initials.isEmpty {
            return String(initials.prefix(3)).uppercased()
        }
        // Otherwise use first letter
        return avatarInitial
    }

    /// Returns the first letter of the name for avatar display
    var avatarInitial: String {
        String(name.prefix(1)).uppercased()
    }
}

// MARK: - Color Extension for Host-based Colors

extension Color {
    /// Generates a consistent, vibrant color from a host string
    static func fromHost(_ host: String) -> Color {
        // Use hash to generate consistent colors
        let hash = abs(host.hashValue)

        // Predefined vibrant colors for better aesthetics
        let vibrantColors: [Color] = [
            Color(red: 0.96, green: 0.26, blue: 0.21),  // Red
            Color(red: 0.91, green: 0.12, blue: 0.39),  // Pink
            Color(red: 0.61, green: 0.15, blue: 0.69),  // Purple
            Color(red: 0.40, green: 0.23, blue: 0.72),  // Deep Purple
            Color(red: 0.25, green: 0.32, blue: 0.71),  // Indigo
            Color(red: 0.13, green: 0.59, blue: 0.95),  // Blue
            Color(red: 0.01, green: 0.66, blue: 0.96),  // Light Blue
            Color(red: 0.00, green: 0.74, blue: 0.83),  // Cyan
            Color(red: 0.00, green: 0.59, blue: 0.53),  // Teal
            Color(red: 0.30, green: 0.69, blue: 0.31),  // Green
            Color(red: 0.55, green: 0.76, blue: 0.29),  // Light Green
            Color(red: 1.00, green: 0.76, blue: 0.03),  // Yellow
            Color(red: 1.00, green: 0.60, blue: 0.00),  // Orange
            Color(red: 1.00, green: 0.34, blue: 0.13),  // Deep Orange
        ]

        return vibrantColors[hash % vibrantColors.count]
    }
}
