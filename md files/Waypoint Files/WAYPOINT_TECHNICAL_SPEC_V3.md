# Waypoint - Technical Specification v3.0

**Version:** 3.0  
**Created:** December 29, 2024  
**Updated:** December 29, 2024  
**Purpose:** Detailed implementation guidance for all features

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Code Organization](#code-organization)
3. [Data Models](#data-models)
4. [Phase Implementation Details](#phase-implementation-details)
5. [API Usage Patterns](#api-usage-patterns)
6. [Performance Considerations](#performance-considerations)
7. [Testing Strategy](#testing-strategy)

---

## Tech Stack

### Core Frameworks
```swift
import SwiftUI          // UI framework
import RealityKit       // 3D graphics, spatial
import Observation      // @Observable pattern
import WebKit           // Embedded browser (Phase 3, optional)
import UniformTypeIdentifiers  // File type detection
```

### visionOS-Specific
```swift
import RealityKitContent  // 3D assets
import Spatial             // Volume windows
```

### Minimum Requirements
- **visionOS:** 2.0+
- **Swift:** 5.9+
- **Xcode:** 16.0+

---

## Code Organization

### Section Marker Pattern
**Use in EVERY file:**

```swift
// MARK: - Properties

// MARK: - Initialization

// MARK: - Public Methods

// MARK: - Private Methods

// MARK: - UI Components

// MARK: - Computed Properties

// MARK: - Event Handlers

// MARK: - Helper Functions
```

### File Naming Conventions
- **Models:** `Portal.swift`, `Constellation.swift`
- **Views:** `PortalListView.swift`, `BeaconView.swift`, `GalaxyView.swift`, `UniverseView.swift`
- **Managers:** `PortalManager.swift`, `ConstellationManager.swift`
- **Services:** `FaviconService.swift`, `USDZThumbnailService.swift`
- **Extensions:** `URL+Extensions.swift`, `Color+Extensions.swift`

### Comment Style
```swift
// MARK: - Portal Management
// Handles CRUD operations for portals including persistence,
// favicon fetching, and type detection

/// Creates a new portal from a URL with intelligent name extraction
/// - Parameter url: The URL to create a portal from
/// - Returns: A configured Portal instance with smart defaults
func createPortal(from url: URL) -> Portal {
    // Implementation
}
```

---

## Data Models

### Portal Model (Complete)

```swift
// MARK: - Portal Model
/// Represents a single portal (link) to any destination
struct Portal: Identifiable, Codable, Hashable {
    // MARK: - Core Properties
    let id: UUID
    var name: String
    var url: String
    var type: PortalType
    
    // MARK: - Visual Properties
    var thumbnailData: Data?           // Auto-fetched favicon
    var customThumbnail: Data?         // User override
    var useCustomThumbnail: Bool
    
    // MARK: - Organization
    var isPinned: Bool
    var sortIndex: Int              // For manual ordering
    var tags: [String]
    
    // MARK: - Metadata
    var dateAdded: Date
    var lastOpened: Date?
    var openCount: Int                 // For Recent section
    
    // MARK: - Window Preferences
    var preferEmbedded: Bool           // Use Waypoint window vs native
    var embedWindowSize: CGSize        // Custom window size
    
    // MARK: - Computed Properties
    var displayThumbnail: Data? {
        useCustomThumbnail ? customThumbnail : thumbnailData
    }
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        type: PortalType,
        thumbnailData: Data? = nil,
        customThumbnail: Data? = nil,
        useCustomThumbnail: Bool = false,
        isPinned: Bool = false,
        sortIndex: Int = Int.max,
        tags: [String] = [],
        dateAdded: Date = Date(),
        lastOpened: Date? = nil,
        openCount: Int = 0,
        preferEmbedded: Bool = false,
        embedWindowSize: CGSize = CGSize(width: 1200, height: 800)
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
        self.thumbnailData = thumbnailData
        self.customThumbnail = customThumbnail
        self.useCustomThumbnail = useCustomThumbnail
        self.isPinned = isPinned
        self.sortIndex = sortIndex
        self.tags = tags
        self.dateAdded = dateAdded
        self.lastOpened = lastOpened
        self.openCount = openCount
        self.preferEmbedded = preferEmbedded
        self.embedWindowSize = embedWindowSize
    }
}

// MARK: - Portal Type
enum PortalType: String, Codable, CaseIterable {
    case web
    case file
    case usdz
    case folder
    case icloud
    case app
    
    var icon: String {
        switch self {
        case .web: return "globe"
        case .file: return "doc"
        case .usdz: return "cube.transparent"
        case .folder: return "folder"
        case .icloud: return "icloud"
        case .app: return "app"
        }
    }
    
    var glowColor: Color {
        switch self {
        case .web: return .blue
        case .file: return .purple
        case .usdz: return .orange
        case .folder: return .cyan
        case .icloud: return .teal
        case .app: return .green
        }
    }
    
    // MARK: - Type Detection
    static func detect(from url: URL) -> PortalType {
        let ext = url.pathExtension.lowercased()
        
        // USDZ files (special treatment)
        if ext == "usdz" || ext == "usd" {
            return .usdz
        }
        
        // Folders
        if url.hasDirectoryPath {
            return .folder
        }
        
        // iCloud URLs
        if url.host?.contains("icloud.com") == true {
            return .icloud
        }
        
        // Files
        let fileExtensions = ["pdf", "doc", "docx", "pages", "key", "numbers",
                              "png", "jpg", "jpeg", "heic", "mp4", "mov"]
        if fileExtensions.contains(ext) {
            return .file
        }
        
        // Web URLs
        if url.scheme == "http" || url.scheme == "https" {
            return .web
        }
        
        // App schemes (notion://, figma://, etc.)
        return .app
    }
}
```

### Constellation Model (Complete)

```swift
// MARK: - Constellation Model
/// Represents a grouped collection of portals (workflow)
struct Constellation: Identifiable, Codable, Hashable {
    // MARK: - Core Properties
    let id: UUID
    var name: String
    var portalIDs: [UUID]              // REFERENCES, not ownership
    
    // MARK: - Visual Properties
    var icon: String                   // SF Symbol
    var customThumbnail: Data?
    var color: Color
    
    // MARK: - Organization
    var isActive: Bool                 // Show/hide toggle
    var sortOrder: Int                 // User-defined order
    
    // MARK: - Metadata
    var dateCreated: Date
    var lastOpened: Date?
    
    // MARK: - Universe View Properties (Phase 8.5)
    var universePosition: CGPoint?     // Position in Universe View
    
    // MARK: - Beacon Mode Settings
    var beaconMode: BeaconDisplayMode
    var manualSelection: [UUID]        // For manual mode
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        name: String,
        portalIDs: [UUID] = [],
        icon: String = "star.circle.fill",
        customThumbnail: Data? = nil,
        color: Color = .blue,
        isActive: Bool = true,
        sortOrder: Int = 0,
        dateCreated: Date = Date(),
        lastOpened: Date? = nil,
        universePosition: CGPoint? = nil,
        beaconMode: BeaconDisplayMode = .favorites,
        manualSelection: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.portalIDs = portalIDs
        self.icon = icon
        self.customThumbnail = customThumbnail
        self.color = color
        self.isActive = isActive
        self.sortOrder = sortOrder
        self.dateCreated = dateCreated
        self.lastOpened = lastOpened
        self.universePosition = universePosition
        self.beaconMode = beaconMode
        self.manualSelection = manualSelection
    }
}

// MARK: - Beacon Display Mode
enum BeaconDisplayMode: String, Codable, CaseIterable {
    case favorites  // Show favorited portals (max 8)
    case manual     // User-selected 8 portals
    case all        // All portals (paginated, 8 per page)
    
    var description: String {
        switch self {
        case .favorites: return "Favorites"
        case .manual: return "Manual Selection"
        case .all: return "All Portals"
        }
    }
}
```

### PortalManager (Complete)

```swift
// MARK: - Portal Manager
@Observable
class PortalManager {
    // MARK: - Properties
    var portals: [Portal] = []         // SOURCE OF TRUTH
    private let appGroupID = "group.Unshackled-Pursuit.Waypoint"
    private var userDefaults: UserDefaults?
    
    // MARK: - Initialization
    init() {
        userDefaults = UserDefaults(suiteName: appGroupID)
        load()
    }
    
    // MARK: - CRUD Operations
    
    func add(_ portal: Portal) {
        portals.append(portal)
        save()
    }
    
    func update(_ portal: Portal) {
        guard let index = portals.firstIndex(where: { $0.id == portal.id }) else {
            return
        }
        portals[index] = portal
        save()
    }
    
    func delete(_ portal: Portal) {
        portals.removeAll { $0.id == portal.id }
        save()
    }
    
    func getPortal(_ id: UUID) -> Portal? {
        return portals.first { $0.id == id }
    }
    
    // MARK: - Organization
    
    func movePortals(from source: IndexSet, to destination: Int) {
        portals.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func togglePin(_ portal: Portal) {
        guard let index = portals.firstIndex(where: { $0.id == portal.id }) else {
            return
        }
        portals[index].isPinned.toggle()
        save()
    }
    
    func recordOpen(_ portal: Portal) {
        guard let index = portals.firstIndex(where: { $0.id == portal.id }) else {
            return
        }
        portals[index].lastOpened = Date()
        portals[index].openCount += 1
        save()
    }
    
    // MARK: - Search & Filter
    
    func search(query: String) -> [Portal] {
        guard !query.isEmpty else { return portals }
        
        return portals.filter { portal in
            portal.name.localizedCaseInsensitiveContains(query) ||
            portal.url.localizedCaseInsensitiveContains(query) ||
            portal.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func filter(by type: PortalType) -> [Portal] {
        return portals.filter { $0.type == type }
    }
    
    // MARK: - Computed Filters

    var pinned: [Portal] {
        return portals.filter { $0.isPinned }
    }
    
    var recent: [Portal] {
        return portals
            .filter { $0.lastOpened != nil }
            .sorted { ($0.lastOpened ?? .distantPast) > ($1.lastOpened ?? .distantPast) }
            .prefix(10)
            .map { $0 }
    }
    
    func unassigned(constellationManager: ConstellationManager) -> [Portal] {
        let assignedIDs = Set(constellationManager.constellations.flatMap { $0.portalIDs })
        return portals.filter { !assignedIDs.contains($0.id) }
    }
    
    // MARK: - Persistence
    
    private func save() {
        guard let userDefaults else { return }
        
        do {
            let data = try JSONEncoder().encode(portals)
            userDefaults.set(data, forKey: "portals")
        } catch {
            print("Failed to save portals: \(error)")
        }
    }
    
    private func load() {
        guard let userDefaults,
              let data = userDefaults.data(forKey: "portals") else {
            return
        }
        
        do {
            portals = try JSONDecoder().decode([Portal].self, from: data)
        } catch {
            print("Failed to load portals: \(error)")
        }
    }
}
```

### ConstellationManager (Complete)

```swift
// MARK: - Constellation Manager
@Observable
class ConstellationManager {
    // MARK: - Properties
    var constellations: [Constellation] = []
    private let appGroupID = "group.Unshackled-Pursuit.Waypoint"
    private var userDefaults: UserDefaults?
    
    // Reference to PortalManager (injected)
    private weak var portalManager: PortalManager?
    
    // MARK: - Initialization
    init(portalManager: PortalManager? = nil) {
        self.portalManager = portalManager
        userDefaults = UserDefaults(suiteName: appGroupID)
        load()
    }
    
    // MARK: - CRUD Operations
    
    func create(name: String, portalIDs: [UUID]) {
        let constellation = Constellation(
            name: name,
            portalIDs: portalIDs,
            sortOrder: constellations.count
        )
        constellations.append(constellation)
        save()
    }
    
    func update(_ constellation: Constellation) {
        guard let index = constellations.firstIndex(where: { $0.id == constellation.id }) else {
            return
        }
        constellations[index] = constellation
        save()
    }
    
    func delete(_ constellation: Constellation) {
        // Portals are NOT deleted, just constellation reference
        constellations.removeAll { $0.id == constellation.id }
        save()
    }
    
    // MARK: - Portal References (NOT Ownership)
    
    func addPortals(_ portalIDs: [UUID], to constellation: Constellation) {
        guard let index = constellations.firstIndex(where: { $0.id == constellation.id }) else {
            return
        }
        
        // Add only new IDs (avoid duplicates)
        let newIDs = portalIDs.filter { !constellations[index].portalIDs.contains($0) }
        constellations[index].portalIDs.append(contentsOf: newIDs)
        save()
    }
    
    func removePortals(_ portalIDs: [UUID], from constellation: Constellation) {
        guard let index = constellations.firstIndex(where: { $0.id == constellation.id }) else {
            return
        }
        
        // Remove from constellation (portals still exist in PortalManager)
        constellations[index].portalIDs.removeAll { portalIDs.contains($0) }
        save()
    }
    
    // MARK: - Organization
    
    func toggleActive(_ constellation: Constellation) {
        guard let index = constellations.firstIndex(where: { $0.id == constellation.id }) else {
            return
        }
        constellations[index].isActive.toggle()
        save()
    }
    
    func reorder(from source: IndexSet, to destination: Int) {
        constellations.move(fromOffsets: source, toOffset: destination)
        
        // Update sort order
        for (index, constellation) in constellations.enumerated() {
            if let constellationIndex = constellations.firstIndex(where: { $0.id == constellation.id }) {
                constellations[constellationIndex].sortOrder = index
            }
        }
        save()
    }
    
    // MARK: - Computed Properties
    
    var activeConstellations: [Constellation] {
        constellations
            .filter { $0.isActive }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func getPortals(for constellation: Constellation) -> [Portal] {
        guard let portalManager else { return [] }
        return portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
    }
    
    func getPortalsForBeacon(constellation: Constellation) -> [Portal] {
        guard let portalManager else { return [] }
        let allPortals = portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
        
        switch constellation.beaconMode {
        case .favorites:
            let favorited = allPortals.filter { $0.isFavorite }
            // If less than 8 favorites, add most-used to fill
            if favorited.count < 8 {
                let additional = allPortals
                    .filter { !$0.isFavorite }
                    .sorted { $0.openCount > $1.openCount }
                    .prefix(8 - favorited.count)
                return favorited + additional
            }
            return Array(favorited.prefix(8))
            
        case .manual:
            return constellation.manualSelection
                .compactMap { id in allPortals.first { $0.id == id } }
                .prefix(8)
                .map { $0 }
            
        case .all:
            return allPortals
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        guard let userDefaults else { return }
        
        do {
            let data = try JSONEncoder().encode(constellations)
            userDefaults.set(data, forKey: "constellations")
        } catch {
            print("Failed to save constellations: \(error)")
        }
    }
    
    private func load() {
        guard let userDefaults,
              let data = userDefaults.data(forKey: "constellations") else {
            return
        }
        
        do {
            constellations = try JSONDecoder().decode([Constellation].self, from: data)
        } catch {
            print("Failed to load constellations: \(error)")
        }
    }
}
```

---

## Phase Implementation Details

### Phase 2: Input Magic ✅ Complete

**Note:** Safari drag & drop doesn't work reliably on visionOS. Implemented Quick Paste/Quick Add toolbar buttons instead.

#### What Was Built (Commit 0e46db9):
- Quick Paste: One-tap portal creation from clipboard
- Quick Add: Type URL/site name (auto-adds https://www/.com)
- Manual drag reordering with Custom sort option
- Constellation system (models, manager, create view)
- Context menu "Add to Constellation" submenu
- Constellation filters in filter menu
- Constellation icons on portal rows
- URL scheme (waypoint://add, open, launch)
- Paste button in AddPortalView with auto-fill
- DropService.swift for smart name extraction
- Removed Favorites (replaced by Constellations)

#### Drop Destination (Reference - visionOS limitation)

```swift
// MARK: - Drop Destination
struct WaypointMainView: View {
    @Bindable var portalManager: PortalManager
    @State private var isDropTargeted = false
    
    var body: some View {
        PortalListView()
            .dropDestination(for: URL.self) { urls, location in
                handleDrop(urls)
                return true
            } isTargeted: { isTargeted in
                isDropTargeted = isTargeted
            }
            .overlay {
                if isDropTargeted {
                    DropZoneOverlay(itemCount: 1)
                }
            }
    }
    
    // MARK: - Drop Handling
    
    func handleDrop(_ urls: [URL]) {
        Task {
            await createPortals(from: urls)
        }
    }
    
    func createPortals(from urls: [URL]) async {
        // Show batch confirmation if 6+ items
        if urls.count >= 6 {
            await showBatchCreationConfirmation(urls)
            return
        }
        
        // Create portals
        for url in urls {
            let portal = await createPortal(from: url)
            portalManager.add(portal)
        }
        
        // Show success toast
        showToast("Created \(urls.count) portal(s)")
    }
    
    func createPortal(from url: URL) async -> Portal {
        let type = PortalType.detect(from: url)
        let name = url.extractSmartName()
        
        var portal = Portal(
            name: name,
            url: url.absoluteString,
            type: type
        )
        
        // Async favicon fetch (non-blocking)
        if type == .web {
            Task {
                if let favicon = await FaviconService.fetch(for: url) {
                    portal.thumbnailData = favicon
                    portalManager.update(portal)
                }
                
                // Try to get page title
                if let title = await PageTitleService.fetchTitle(for: url) {
                    portal.name = title
                    portalManager.update(portal)
                }
            }
        }
        
        // USDZ thumbnail generation
        if type == .usdz {
            Task {
                if let thumbnail = await USDZThumbnailService.generate(for: url) {
                    portal.thumbnailData = thumbnail
                    portalManager.update(portal)
                }
            }
        }
        
        // Copy files to app storage
        if type == .file || type == .usdz {
            if let localURL = FileStorageManager.shared.store(file: url) {
                portal.url = localURL.absoluteString
            }
        }
        
        // Scan folder contents
        if type == .folder {
            // Folder handling implementation
        }
        
        return portal
    }
}
```

#### Smart Name Extraction

```swift
// MARK: - URL Extensions
extension URL {
    /// Extracts a smart name from URL using intelligent heuristics
    func extractSmartName() -> String {
        // 1. USDZ files → filename without extension
        if pathExtension.lowercased() == "usdz" {
            return deletingPathExtension().lastPathComponent
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        }
        
        // 2. iCloud URLs → Parse fragment
        // icloud.com/notes#My_Note_Title → "My Note Title"
        if host?.contains("icloud.com") == true,
           let fragment = fragment {
            return fragment
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "%20", with: " ")
                .capitalized
        }
        
        // 3. Files → filename
        if scheme == "file" {
            return lastPathComponent
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
        }
        
        // 4. Web URLs → Clean domain
        if let host = host {
            return host
                .replacingOccurrences(of: "www.", with: "")
                .components(separatedBy: ".").first?
                .capitalized ?? host
        }
        
        return "Portal"
    }
}
```

#### Favicon Service

```swift
// MARK: - Favicon Service
class FaviconService {
    static func fetch(for url: URL) async -> Data? {
        guard url.scheme == "http" || url.scheme == "https" else {
            return nil
        }
        
        // Try multiple favicon URLs
        let faviconURLs = [
            URL(string: "\(url.scheme!)://\(url.host!)/favicon.ico"),
            URL(string: "\(url.scheme!)://\(url.host!)/apple-touch-icon.png"),
            URL(string: "https://www.google.com/s2/favicons?domain=\(url.host!)&sz=64")
        ].compactMap { $0 }
        
        for faviconURL in faviconURLs {
            do {
                let (data, response) = try await URLSession.shared.data(from: faviconURL)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    continue
                }
                
                return data
            } catch {
                continue
            }
        }
        
        return nil
    }
}
```

---

### Phase 4: SwiftUI Orbs (60 min for PortalOrb)

```swift
// MARK: - Portal Orb Component
struct PortalOrb: View {
    let portal: Portal
    @AppStorage("orbGlowMode") private var glowMode: OrbGlowMode = .appType
    @State private var isPulsing = false
    
    // MARK: - Glow Color Logic
    
    var glowColor: Color {
        switch glowMode {
        case .appType:
            return portal.type.glowColor
        case .iconColor:
            return extractDominantColor(from: portal.thumbnailData) ?? .blue
        case .constellation:
            // Would get from constellation membership
            return .blue  // Placeholder
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            glowColor.opacity(0.6),
                            glowColor.opacity(0.3),
                            glowColor.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
                .blur(radius: 10)
            
            // Glass sphere
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 60)
                .overlay {
                    // Embedded icon
                    if let thumbnailData = portal.displayThumbnail,
                       let uiImage = UIImage(data: thumbnailData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay {
                                // Convex glass effect
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.4),
                                                .white.opacity(0.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .blendMode(.overlay)
                            }
                    } else {
                        // Fallback icon
                        Image(systemName: portal.type.icon)
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                }
                .overlay {
                    // Sphere rim
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.5),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                }
                .shadow(color: glowColor.opacity(0.3), radius: 8, y: 4)
            
            // Pulse ring
            Circle()
                .strokeBorder(glowColor.opacity(0.5), lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.0 : 1.0)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: false)
            ) {
                isPulsing = true
            }
        }
    }
    
    // MARK: - Color Extraction
    
    func extractDominantColor(from imageData: Data?) -> Color? {
        guard let imageData,
              let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            return nil
        }
        
        // Simple approach: Get average color
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Calculate average
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        var pixelCount = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let red = Int(pixelData[offset])
                let green = Int(pixelData[offset + 1])
                let blue = Int(pixelData[offset + 2])
                
                totalRed += red
                totalGreen += green
                totalBlue += blue
                pixelCount += 1
            }
        }
        
        let avgRed = Double(totalRed) / Double(pixelCount) / 255.0
        let avgGreen = Double(totalGreen) / Double(pixelCount) / 255.0
        let avgBlue = Double(totalBlue) / Double(pixelCount) / 255.0
        
        return Color(red: avgRed, green: avgGreen, blue: avgBlue)
    }
}

// MARK: - Orb Glow Mode
enum OrbGlowMode: String, CaseIterable, Identifiable {
    case appType = "App Type"
    case iconColor = "Icon Color"
    case constellation = "Constellation"
    
    var id: String { rawValue }
}
```

---

### Phase 5: Beacon Mode (45 min)

```swift
// MARK: - Beacon View
struct BeaconView: View {
    let constellation: Constellation
    @Bindable var portalManager: PortalManager
    @Bindable var constellationManager: ConstellationManager
    
    @State private var currentPage: Int = 0
    @State private var selectedConstellation: Constellation
    
    init(constellation: Constellation, portalManager: PortalManager, constellationManager: ConstellationManager) {
        self.constellation = constellation
        self.portalManager = portalManager
        self.constellationManager = constellationManager
        _selectedConstellation = State(initialValue: constellation)
    }
    
    // MARK: - Computed Properties
    
    var portals: [Portal] {
        constellationManager.getPortalsForBeacon(constellation: selectedConstellation)
    }
    
    var pages: [[Portal]] {
        // Split into pages of 8
        stride(from: 0, to: portals.count, by: 8).map {
            Array(portals[$0..<min($0 + 8, portals.count)])
        }
    }
    
    var currentPagePortals: [Portal] {
        guard currentPage < pages.count else { return [] }
        return pages[currentPage]
    }
    
    var showPagination: Bool {
        selectedConstellation.beaconMode == .all && pages.count > 1
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Orb stack
            VStack(spacing: 20) {
                ForEach(currentPagePortals) { portal in
                    PortalOrb(portal: portal)
                        .frame(width: 80, height: 80)
                        .onTapGesture {
                            launchPortal(portal)
                        }
                        .contextMenu {
                            PortalContextMenu(portal: portal)
                        }
                }
            }
            .frame(width: 100)
            .padding(.vertical, 20)
            
            Spacer()
            
            // Mode toggle button
            Button(action: switchToGalaxyMode) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(.bottom, 20)
        }
        .frame(width: 100)
        .gesture(
            DragGesture()
                .onEnded { value in
                    handleSwipe(value)
                }
        )
    }
    
    // MARK: - Swipe Handling
    
    func handleSwipe(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height
        
        // Horizontal swipe (change constellation)
        if abs(horizontalAmount) > abs(verticalAmount) {
            if horizontalAmount > 50 {
                // Swipe right (previous constellation)
                selectPreviousConstellation()
            } else if horizontalAmount < -50 {
                // Swipe left (next constellation)
                selectNextConstellation()
            }
        }
        // Vertical swipe (change page, only in All mode)
        else if showPagination {
            if verticalAmount > 50 {
                // Swipe down (previous page)
                currentPage = max(0, currentPage - 1)
            } else if verticalAmount < -50 {
                // Swipe up (next page)
                currentPage = min(pages.count - 1, currentPage + 1)
            }
        }
    }
    
    // MARK: - Constellation Navigation
    
    func selectNextConstellation() {
        let active = constellationManager.activeConstellations
        guard let currentIndex = active.firstIndex(where: { $0.id == selectedConstellation.id }) else {
            return
        }
        
        let nextIndex = (currentIndex + 1) % active.count
        withAnimation {
            selectedConstellation = active[nextIndex]
            currentPage = 0
        }
        
        // Show brief label
        showConstellationLabel("\(selectedConstellation.name)")
    }
    
    func selectPreviousConstellation() {
        let active = constellationManager.activeConstellations
        guard let currentIndex = active.firstIndex(where: { $0.id == selectedConstellation.id }) else {
            return
        }
        
        let previousIndex = currentIndex == 0 ? active.count - 1 : currentIndex - 1
        withAnimation {
            selectedConstellation = active[previousIndex]
            currentPage = 0
        }
        
        // Show brief label
        showConstellationLabel("\(selectedConstellation.name)")
    }
    
    // MARK: - Actions
    
    func launchPortal(_ portal: Portal) {
        portalManager.recordOpen(portal)
        
        if let url = URL(string: portal.url) {
            // Open in native app (Safari, etc.)
            // Implementation depends on environment
        }
    }
    
    func switchToGalaxyMode() {
        // Switch to Galaxy mode
        // Implementation depends on window management
    }
    
    func showConstellationLabel(_ text: String) {
        // Show temporary label overlay
        // Implementation: Toast or brief overlay
    }
}
```

---

### Phase 6: RealityKit Volume (90 min for entities)

```swift
// MARK: - Portal Orb Entity (RealityKit)
class PortalOrbEntity: Entity {
    let portal: Portal
    
    init(portal: Portal) {
        self.portal = portal
        super.init()
        
        setupOrb()
    }
    
    @MainActor required init() {
        fatalError("Use init(portal:)")
    }
    
    private func setupOrb() {
        // MARK: - Glass Sphere
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        var glassMaterial = PhysicallyBasedMaterial()
        glassMaterial.baseColor = .init(tint: .white.withAlphaComponent(0.3))
        glassMaterial.roughness = 0.1
        glassMaterial.metallic = 0.0
        glassMaterial.clearcoat = 1.0
        glassMaterial.clearcoatRoughness = 0.0
        
        let sphereModel = ModelComponent(
            mesh: sphereMesh,
            materials: [glassMaterial]
        )
        components.set(sphereModel)
        
        // MARK: - Glow Sphere
        let glowSphere = Entity()
        let glowMesh = MeshResource.generateSphere(radius: 0.06)
        var glowMaterial = UnlitMaterial()
        glowMaterial.color = .init(tint: portal.type.glowColor.withAlphaComponent(0.5))
        
        glowSphere.components.set(ModelComponent(
            mesh: glowMesh,
            materials: [glowMaterial]
        ))
        addChild(glowSphere)
        
        // MARK: - Icon Texture
        if let thumbnailData = portal.displayThumbnail,
           let uiImage = UIImage(data: thumbnailData),
           let cgImage = uiImage.cgImage {
            
            let iconPlane = Entity()
            let planeMesh = MeshResource.generatePlane(width: 0.04, height: 0.04)
            
            var iconMaterial = UnlitMaterial()
            if let textureResource = try? TextureResource.generate(
                from: cgImage,
                options: .init(semantic: .color)
            ) {
                iconMaterial.color.texture = .init(textureResource)
            }
            
            iconPlane.components.set(ModelComponent(
                mesh: planeMesh,
                materials: [iconMaterial]
            ))
            iconPlane.position = SIMD3(0, 0, 0.026)  // In front of sphere
            addChild(iconPlane)
        }
        
        // MARK: - Rotation Animation
        components.set(RotationComponent(
            speed: 0.1,
            axis: SIMD3(0, 1, 0)
        ))
        
        // MARK: - Input & Collision
        components.set(InputTargetComponent())
        components.set(CollisionComponent(
            shapes: [.generateSphere(radius: 0.05)]
        ))
    }
}

// MARK: - Rotation Component
struct RotationComponent: Component {
    var speed: Float
    var axis: SIMD3<Float>
}

// MARK: - Rotation System
class RotationSystem: System {
    static let query = EntityQuery(where: .has(RotationComponent.self))
    
    init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var rotation = entity.components[RotationComponent.self] else {
                continue
            }
            
            let deltaTime = Float(context.deltaTime)
            let angle = rotation.speed * deltaTime
            
            entity.transform.rotation *= simd_quatf(
                angle: angle,
                axis: rotation.axis
            )
        }
    }
}
```

---

### Phase 8.5: Universe View (4 hours)

#### Universe View Main Component

```swift
// MARK: - Universe View
struct UniverseView: View {
    @Bindable var portalManager: PortalManager
    @Bindable var constellationManager: ConstellationManager
    
    @State private var libraryPosition: CGPoint = CGPoint(x: 800, y: 300)
    @State private var libraryMinimized: Bool = false
    @State private var selectedTab: LibraryTab = .favorites
    @State private var searchQuery: String = ""
    
    var body: some View {
        ZStack {
            // Constellation web (background)
            ConstellationWebView(
                constellations: constellationManager.activeConstellations,
                onTapNode: { constellation in
                    openDetailWindow(for: constellation)
                }
            )
            
            // Library overlay (movable)
            if !libraryMinimized {
                LibraryOverlay(
                    portalManager: portalManager,
                    constellationManager: constellationManager,
                    selectedTab: $selectedTab,
                    searchQuery: $searchQuery,
                    onPortalDrop: { portal, constellation in
                        handlePortalAssignment(portal, to: constellation)
                    },
                    onMinimize: {
                        withAnimation {
                            libraryMinimized = true
                        }
                    }
                )
                .position(libraryPosition)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            libraryPosition = value.location
                        }
                        .onEnded { value in
                            // Check if dragged to edge
                            if value.location.x > 1200 {
                                withAnimation {
                                    libraryMinimized = true
                                }
                            }
                        }
                )
            } else {
                // Minimized tab
                LibraryTab()
                    .position(x: 1250, y: 300)
                    .onTapGesture {
                        withAnimation {
                            libraryMinimized = false
                            libraryPosition = CGPoint(x: 800, y: 300)
                        }
                    }
            }
        }
        .frame(width: 1300, height: 1000, depth: 500)
    }
    
    // MARK: - Portal Assignment
    
    func handlePortalAssignment(_ portal: Portal, to constellation: Constellation) {
        constellationManager.addPortals([portal.id], to: constellation)
        
        // Visual feedback
        showAssignmentAnimation(portal: portal, constellation: constellation)
    }
    
    func showAssignmentAnimation(portal: Portal, constellation: Constellation) {
        // Absorption animation
        // Portal scales down and flies to constellation node
        // Sound + haptic feedback
    }
    
    // MARK: - Two-Tier Navigation
    
    func openDetailWindow(for constellation: Constellation) {
        // Open Galaxy or Beacon mode in separate window
        // Pass constellation ID as parameter
    }
}
```

#### Constellation Node Component

```swift
// MARK: - Constellation Node (Simplified)
struct ConstellationNode: View {
    let constellation: Constellation
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Simplified orb (not full detail)
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                constellation.color.opacity(0.6),
                                constellation.color.opacity(0.3),
                                constellation.color.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 8)
                
                // Sphere
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: constellation.icon)
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(
                                constellation.color.opacity(0.5),
                                lineWidth: 2
                            )
                    }
            }
            
            // Label
            Text(constellation.name)
                .font(.caption)
                .foregroundStyle(.white)
        }
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button("Launch All") {
                launchConstellation(constellation)
            }
            Button("Edit") {
                // Edit constellation
            }
            Divider()
            Button("Delete", role: .destructive) {
                // Delete constellation
            }
        }
    }
    
    func launchConstellation(_ constellation: Constellation) {
        // Launch all portals in constellation
    }
}
```

#### Library Overlay Component

```swift
// MARK: - Library Overlay
struct LibraryOverlay: View {
    @Bindable var portalManager: PortalManager
    @Bindable var constellationManager: ConstellationManager
    
    @Binding var selectedTab: LibraryTab
    @Binding var searchQuery: String
    
    let onPortalDrop: (Portal, Constellation) -> Void
    let onMinimize: () -> Void
    
    var portals: [Portal] {
        let filtered: [Portal]
        
        switch selectedTab {
        case .favorites:
            filtered = portalManager.favorites
        case .pinned:
            filtered = portalManager.pinned
        case .all:
            filtered = portalManager.portals
        }
        
        if searchQuery.isEmpty {
            return filtered
        } else {
            return portalManager.search(query: searchQuery)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Library")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onMinimize) {
                    Image(systemName: "minus.circle")
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            // Tabs
            Picker("Library Tab", selection: $selectedTab) {
                Label("Favorites", systemImage: "star.fill")
                    .tag(LibraryTab.favorites)
                Label("Pinned", systemImage: "pin.fill")
                    .tag(LibraryTab.pinned)
                Label("All", systemImage: "square.grid.2x2")
                    .tag(LibraryTab.all)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Search bar
            TextField("Search portals...", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            // Portal grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.fixed(80)),
                    GridItem(.fixed(80)),
                    GridItem(.fixed(80))
                ], spacing: 20) {
                    ForEach(portals) { portal in
                        PortalOrb(portal: portal)
                            .frame(width: 60, height: 60)
                            .draggable(portal.id.uuidString)
                    }
                }
                .padding()
            }
        }
        .frame(width: 300, height: 500)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

enum LibraryTab: String, CaseIterable, Identifiable {
    case favorites
    case pinned
    case all
    
    var id: String { rawValue }
}
```

#### Connection Lines Component

```swift
// MARK: - Constellation Web View
struct ConstellationWebView: View {
    let constellations: [Constellation]
    let onTapNode: (Constellation) -> Void
    
    var body: some View {
        ZStack {
            // Connection lines
            ForEach(constellations.indices, id: \.self) { index in
                if index < constellations.count - 1 {
                    ConnectionLine(
                        from: positionFor(constellation: constellations[index]),
                        to: positionFor(constellation: constellations[index + 1]),
                        color: constellations[index].color
                    )
                }
            }
            
            // Constellation nodes
            ForEach(constellations) { constellation in
                ConstellationNode(
                    constellation: constellation,
                    onTap: {
                        onTapNode(constellation)
                    }
                )
                .position(positionFor(constellation: constellation))
            }
        }
    }
    
    func positionFor(constellation: Constellation) -> CGPoint {
        // Use saved position or calculate default
        if let saved = constellation.universePosition {
            return saved
        }
        
        // Default spiral layout
        let index = constellations.firstIndex(where: { $0.id == constellation.id }) ?? 0
        let angle = Double(index) * 0.618 * 2 * .pi  // Golden angle
        let radius = 200.0 + Double(index) * 50
        
        return CGPoint(
            x: 650 + cos(angle) * radius,
            y: 500 + sin(angle) * radius
        )
    }
}

// MARK: - Connection Line
struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    let color: Color
    
    var body: some View {
        Path { path in
            path.move(to: from)
            
            // Bezier curve for aesthetic
            let controlPoint1 = CGPoint(
                x: from.x + (to.x - from.x) * 0.33,
                y: from.y
            )
            let controlPoint2 = CGPoint(
                x: from.x + (to.x - from.x) * 0.66,
                y: to.y
            )
            
            path.addCurve(
                to: to,
                control1: controlPoint1,
                control2: controlPoint2
            )
        }
        .stroke(
            color.opacity(0.3),
            style: StrokeStyle(
                lineWidth: 2,
                lineCap: .round
            )
        )
    }
}
```

---

## API Usage Patterns

### Opening URLs (Native Apps)

```swift
// MARK: - URL Opening
@Environment(\.openURL) private var openURL

func openPortal(_ portal: Portal) {
    // Record usage
    portalManager.recordOpen(portal)
    
    // Open in native app
    if let url = URL(string: portal.url) {
        openURL(url)
    }
}
```

### Opening Windows (Two-Tier Navigation)

```swift
// MARK: - Window Management
@Environment(\.openWindow) private var openWindow
@Environment(\.dismissWindow) private var dismissWindow

func openDetailWindow(for constellation: Constellation) {
    // Open Galaxy or Beacon mode in separate window
    openWindow(id: "constellationDetail", value: constellation.id)
}

func closeDetailWindow(constellationID: UUID) {
    dismissWindow(id: "constellationDetail", value: constellationID)
}
```

### Staggered Launch Pattern

```swift
// MARK: - Constellation Launch
func launchConstellation(_ constellation: Constellation) async {
    let portals = constellationManager.getPortals(for: constellation)
    
    for (index, portal) in portals.enumerated() {
        // Delay between launches
        if index > 0 {
            let delayNS = UInt64(settings.staggerDelay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delayNS)
        }
        
        // Record and open
        portalManager.recordOpen(portal)
        
        if portal.preferEmbedded || settings.preferEmbeddedForConstellation {
            openWindow(id: "embeddedPortal", value: portal.id)
        } else {
            if let url = URL(string: portal.url) {
                openURL(url)
            }
        }
    }
}
```

---

## Performance Considerations

### Favicon Fetching (Non-Blocking)

```swift
// ❌ BAD: Blocks UI
func addPortal(url: URL) {
    let favicon = fetchFavicon(url)  // Blocks!
    let portal = Portal(name: name, url: url, thumbnailData: favicon)
    portalManager.add(portal)
}

// ✅ GOOD: Non-blocking
func addPortal(url: URL) {
    // Create immediately with placeholder
    let portal = Portal(name: url.extractSmartName(), url: url.absoluteString)
    portalManager.add(portal)
    
    // Fetch asynchronously
    Task {
        if let favicon = await FaviconService.fetch(for: url) {
            portal.thumbnailData = favicon
            portalManager.update(portal)
        }
    }
}
```

### Large Lists (LazyVStack/LazyVGrid)

```swift
// Use lazy loading for performance
ScrollView {
    LazyVStack {
        ForEach(portals) { portal in
            PortalCard(portal: portal)
        }
    }
}
```

### RealityKit Entity Limits

```swift
// Limit orbs per view for performance
let maxOrbsPerConstellation = 20

// Use lower poly meshes if needed
if orbCount > 50 {
    let lowResSphere = MeshResource.generateSphere(
        radius: 0.05,
        segments: 8  // Lower segment count
    )
}
```

### Universe View Optimization

```swift
// Simplified nodes (not full orb detail)
// Only render visible constellations
// Use culling for off-screen nodes

var visibleConstellations: [Constellation] {
    constellations.filter { constellation in
        isInViewport(position: positionFor(constellation: constellation))
    }
}
```

---

## Testing Strategy

### Unit Tests

```swift
// Portal creation
func testPortalCreation() {
    let portal = Portal(
        name: "Test",
        url: "https://example.com",
        type: .web
    )
    XCTAssertEqual(portal.name, "Test")
}

// Type detection
func testTypeDetection() {
    let webURL = URL(string: "https://example.com")!
    XCTAssertEqual(PortalType.detect(from: webURL), .web)
    
    let usdzURL = URL(fileURLWithPath: "/path/to/model.usdz")
    XCTAssertEqual(PortalType.detect(from: usdzURL), .usdz)
}

// Portal references
func testConstellationReferences() {
    let portal1 = Portal(name: "Test1", url: "https://test1.com", type: .web)
    let portal2 = Portal(name: "Test2", url: "https://test2.com", type: .web)
    
    portalManager.add(portal1)
    portalManager.add(portal2)
    
    var constellation = Constellation(name: "Test", portalIDs: [portal1.id])
    
    // Add portal2
    constellationManager.addPortals([portal2.id], to: constellation)
    
    // Both portals should be referenced
    XCTAssertEqual(constellation.portalIDs.count, 2)
    
    // Delete constellation (portals should remain)
    constellationManager.delete(constellation)
    XCTAssertEqual(portalManager.portals.count, 2)
}
```

### Integration Tests

```swift
// Universe View portal assignment
func testPortalAssignment() {
    let portal = Portal(name: "Test", url: "https://test.com", type: .web)
    portalManager.add(portal)
    
    let constellation = Constellation(name: "Test Constellation")
    constellationManager.create(name: constellation.name, portalIDs: [])
    
    // Assign portal to constellation
    constellationManager.addPortals([portal.id], to: constellation)
    
    // Portal should be in constellation
    let portals = constellationManager.getPortals(for: constellation)
    XCTAssertEqual(portals.count, 1)
    XCTAssertEqual(portals.first?.id, portal.id)
}

// Beacon mode portal selection
func testBeaconModeSelection() {
    // Create 10 portals (5 favorited)
    for i in 0..<10 {
        var portal = Portal(name: "Portal \(i)", url: "https://test\(i).com", type: .web)
        portal.isFavorite = i < 5
        portalManager.add(portal)
    }
    
    var constellation = Constellation(name: "Test")
    constellation.portalIDs = portalManager.portals.map { $0.id }
    constellation.beaconMode = .favorites
    
    let beaconPortals = constellationManager.getPortalsForBeacon(constellation: constellation)
    
    // Should return max 8 favorited portals
    XCTAssertEqual(beaconPortals.count, 8)
    XCTAssertTrue(beaconPortals.allSatisfy { $0.isFavorite })
}
```

### Manual Testing Checklist

**Phase 2 (Input Magic) ✅ Complete:**
- [x] Quick Paste creates portal from clipboard
- [x] Quick Add works with bare names ("youtube" → youtube.com)
- [x] Drag portal to reorder → Persists (Custom sort)
- [x] Constellation system complete
- [x] Add to Constellation context menu works
- [x] Filter by constellation works
- [x] waypoint://add?url=... URL scheme works

**Phase 5 (Beacon Mode):**
- [ ] Beacon shows 8 orbs vertically
- [ ] Swipe left/right changes constellation
- [ ] Swipe up/down changes page (All mode only)
- [ ] Favorites mode shows favorited portals
- [ ] Manual mode shows user-selected portals
- [ ] All mode shows all portals paginated

**Phase 6 (Galaxy Mode):**
- [ ] Orbs arranged in 3D sphere
- [ ] Look + pinch launches portal
- [ ] Look at center + pinch launches all
- [ ] Scatter animation dramatic
- [ ] Gather animation smooth
- [ ] 60fps performance

**Phase 8.5 (Universe View):**
- [ ] Universe View opens
- [ ] All active constellations visible
- [ ] Library overlay appears
- [ ] Can move library anywhere
- [ ] Can minimize library to tab
- [ ] Can restore from tab
- [ ] Drag portal onto node → Assigns
- [ ] Tap constellation node → Detail window opens
- [ ] Detail window shows correct constellation
- [ ] Connection lines visible
- [ ] Can rearrange nodes

---

## Error Handling

### Graceful Degradation

```swift
// Favicon fetch fails → Use placeholder
if let favicon = await FaviconService.fetch(for: url) {
    portal.thumbnailData = favicon
} else {
    // Use first letter of domain as fallback
    portal.thumbnailData = generateLetterIcon(url.host?.first ?? "P")
}

// USDZ thumbnail fails → Use icon
if let thumbnail = await USDZThumbnailService.generate(for: url) {
    portal.thumbnailData = thumbnail
} else {
    // Use cube icon
    portal.thumbnailData = nil  // Will show SF Symbol
}

// File copy fails → Keep original URL
if let localURL = FileStorageManager.shared.store(file: url) {
    portal.url = localURL.absoluteString
} else {
    print("Warning: Could not copy file, using original URL")
    portal.url = url.absoluteString
}
```

### User-Facing Errors

```swift
// Show toast for failures
func showError(_ message: String) {
    toast = Toast(
        message: message,
        type: .error,
        duration: 3.0
    )
}

// Example usage
if portals.isEmpty {
    showError("No portals found")
}

if !url.isValid {
    showError("Invalid URL")
}
```

---

## Accessibility

### VoiceOver Support

```swift
// Portal cards
PortalCard(portal: portal)
    .accessibilityLabel("\(portal.name) portal")
    .accessibilityHint("Double tap to open \(portal.url)")
    .accessibilityAddTraits(.isButton)

// Constellation nodes
ConstellationNode(constellation: constellation, onTap: {})
    .accessibilityLabel("\(constellation.name) constellation with \(constellation.portalIDs.count) portals")
    .accessibilityHint("Double tap to open detail view")

// Orbs
PortalOrb(portal: portal)
    .accessibilityLabel("\(portal.name)")
    .accessibilityHint("Tap to open")
    .accessibilityAddTraits(.isButton)
```

### Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var body: some View {
    PortalOrb(portal: portal)
        .animation(
            reduceMotion ? .none : .spring(response: 0.5),
            value: isExpanded
        )
}
```

---

## Conclusion

This technical specification v3.0 provides complete implementation guidance for Waypoint, including:

- **Updated data models** with portal reference architecture
- **Universe View implementation** (Phase 8.5)
- **Beacon mode details** with 3 selection modes
- **Two-tier navigation** pattern
- **Portal assignment** via drag & drop
- **Complete code examples** for all major features

**Key Architectural Principles:**
- Portal references, not ownership
- Non-blocking async operations
- Simplified nodes for overview
- Two-tier navigation for detail work
- Performance-conscious implementations

**Current Status:**
- Phase 2 complete (commit 0e46db9)
- visionOS drag & drop limitation discovered - solved with Quick Paste/Quick Add
- Favorites removed, replaced by Constellations

**Next Steps:**
1. Phase 3 (Embedded Windows - optional) or skip to Phase 4
2. Test thoroughly at each phase
3. Commit working code frequently
4. Document deviations or improvements

---

**End of Technical Specification v3.0**

*This document supersedes WAYPOINT_TECHNICAL_SPEC.md v2.0*  
*Last updated: December 29, 2024*
