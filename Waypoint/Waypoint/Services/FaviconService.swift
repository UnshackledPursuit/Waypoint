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

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let session: URLSession

    private var cacheDirectory: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("Favicons")
    }

    // MARK: - Initialization

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        self.session = URLSession(configuration: config)

        // Create cache directory if needed
        if let cacheDir = cacheDirectory {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }

        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
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

        // 1. Google Favicon Service (most reliable)
        if let googleURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=128") {
            sources.append(googleURL)
        }

        // 2. DuckDuckGo Icons API
        if let ddgURL = URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico") {
            sources.append(ddgURL)
        }

        // 3. Direct favicon.ico
        if let scheme = originalURL.scheme {
            if let directURL = URL(string: "\(scheme)://\(host)/favicon.ico") {
                sources.append(directURL)
            }
        }

        // 4. Apple touch icon (often higher quality)
        if let scheme = originalURL.scheme {
            if let appleURL = URL(string: "\(scheme)://\(host)/apple-touch-icon.png") {
                sources.append(appleURL)
            }
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
}
