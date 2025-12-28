# Waypoint - Core Foundation Document

**Created:** December 27, 2024  
**Purpose:** Core decisions and architecture for Waypoint visionOS app  
**Status:** Ready to build Phase 1

---

## Table of Contents
1. [Locked Decisions](#locked-decisions)
2. [Data Architecture](#data-architecture)
3. [Core Features (MVP)](#core-features-mvp)
4. [UI/UX Principles](#uiux-principles)
5. [Build Phases](#build-phases)
6. [Open for Future Iteration](#open-for-future-iteration)
7. [Quick Start Guide](#quick-start-guide)

---

## Locked Decisions ✅

### Terminology
- **App Name:** Waypoint
- **Individual Link:** Portal
- **Grouped Links:** Constellation
- **Tagline:** "Navigate your digital universe"

### Core Promise
**"2 seconds to anywhere"** - Instant access to your digital life

### User Flows

**Basic Flow:**
1. User shares link from Safari/Notes/Messages
2. Waypoint auto-fills name and fetches favicon
3. User taps Save
4. Portal appears in list
5. Click portal → Opens instantly in native app

**Power Flow:**
1. User creates Morning Constellation with 5 portals
2. Hover over constellation → Portals expand/fan out
3. Click constellation → All 5 launch simultaneously
4. Entire workflow ready in 2 seconds

### File Types Supported
- Web URLs (https://, http://)
- iCloud URLs (Notes, Freeform, Pages, etc.)
- File URLs (PDFs, USDZ, documents)
- App deep links (notion://, figma://, etc.)

---

## Data Architecture

### Portal (Individual Link)

```swift
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
    var tags: [String]              // For future organization
    
    var displayThumbnail: Data? {
        useCustomThumbnail ? customThumbnail : thumbnailData
    }
}
```

### Constellation (Grouped Links)

```swift
struct Constellation: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String                // SF Symbol name
    var customThumbnail: Data?      // User image override
    var portalIDs: [UUID]           // References to portals
    var color: String               // Hex color for visual distinction
    var dateCreated: Date
    var lastOpened: Date?
}
```

### Link Type Detection

```swift
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
```

### Managers

```swift
@Observable
class PortalManager {
    var portals: [Portal] = []
    
    // CRUD operations
    func add(_ portal: Portal)
    func update(_ portal: Portal)
    func delete(_ portal: Portal)
    func toggleFavorite(_ portal: Portal)
    func updateLastOpened(_ portal: Portal)
    
    // Persistence (App Group for widget sharing)
    private let appGroupID = "group.Unshackled-Pursuit.Waypoint"
}

@Observable
class ConstellationManager {
    var constellations: [Constellation] = []
    
    // CRUD operations
    func create(name: String, portalIDs: [UUID])
    func update(_ constellation: Constellation)
    func delete(_ constellation: Constellation)
    func addPortals(_ portalIDs: [UUID], to constellation: Constellation)
    func removePortals(_ portalIDs: [UUID], from constellation: Constellation)
}
```

---

## Core Features (MVP)

### Phase 1: Core Portals (1 hour)
**Deliverable:** Working bookmark manager

- ✅ Portal data model + PortalManager
- ✅ Simple list view
- ✅ Manual add/edit/delete portals
- ✅ Open any URL type correctly
- ✅ Persistence via App Group UserDefaults
- ✅ Basic UI (list, cards, empty state)

**Key Files:**
- `Portal.swift` - Data model
- `PortalManager.swift` - CRUD + persistence
- `PortalListView.swift` - Main list
- `AddPortalView.swift` - Add/edit form
- `WaypointApp.swift` - App entry point

### Phase 2: Share Extension (30 min)
**Deliverable:** Share from Safari/Notes works

- ✅ Share Extension target
- ✅ Accept URLs from any app
- ✅ Pass to main app via URL scheme (`waypoint://add-portal?url=...`)
- ✅ Simple ShareViewController (no complexity)
- ✅ App Group sharing enabled

**Key Files:**
- `ShareViewController.swift` - Extract URL, open main app
- `Info.plist` - Configure accepted types
- `WaypointApp.swift` - Handle incoming URLs

**URL Scheme:**
```
waypoint://add-portal?url=<encoded-url>
```

### Phase 3: Constellations (45 min)
**Deliverable:** Batch launch multiple portals

- ✅ Constellation data model + ConstellationManager
- ✅ Create constellation from selected portals
- ✅ "Launch Constellation" → Opens all portals
- ✅ Constellation cards in list view
- ✅ Expand/collapse interaction

**Key Features:**
- Select multiple portals → Create constellation
- Hover to expand (show portals inside)
- Click to launch all
- Edit constellation (add/remove portals)

### Phase 4: Drag & Drop (30 min)
**Deliverable:** Natural visionOS interaction

- ✅ Drop destination on main view
- ✅ Auto-detect portal type
- ✅ Smart name extraction
- ✅ File copying for `file://` URLs
- ✅ Visual feedback (drop zone highlight)

**Implementation:**
```swift
.dropDestination(for: URL.self) { urls, location in
    handleDroppedContent(urls)
    return true
}
```

**File Handling:**
- `file://` URLs → Copy to app's Documents directory
- Store local path instead of original file URL
- Ensures persistence even if original file moves/deletes

### Phase 5: Intelligence/Auto-fill (45 min)
**Deliverable:** Zero manual work

- ✅ Favicon auto-fetch (async, non-blocking)
- ✅ Smart name extraction
- ✅ Page title extraction (for web URLs)
- ✅ iCloud URL fragment parsing
- ✅ Fallback to domain cleaning

**Smart Name Extraction Priority:**
1. iCloud URLs: Extract from fragment (`#Note_Title` → "Note Title")
2. Web URLs: Fetch `<title>` tag
3. Files: Use filename
4. Fallback: Clean domain name

**Services:**
- `FaviconService.swift` - Async favicon fetching
- `NameExtractor.swift` - Smart name extraction
- `LinkDetector.swift` - Type detection

### Phase 6: Widgets (1 hour)
**Deliverable:** Home screen access

**Widget Types:**
- **Small:** Single portal (tap to launch)
- **Medium:** Constellation launcher OR 3 favorite portals
- **Large:** 6-portal grid OR 3 constellations OR custom mix

**Widget Configuration:**
- User customizes in app settings
- Syncs via App Group
- Supports both portals and constellations

**Key Files:**
- `WaypointWidget.swift` - Widget implementation
- `WaypointWidgetBundle.swift` - Widget bundle
- Widget intents for configuration

### Phase 7: Polish (flexible)
**Deliverable:** Native visionOS experience

- ✅ Default narrow window size
- ✅ Responsive layout (narrow → wide → grid)
- ✅ List/Grid view toggle
- ✅ Context menu interactions
- ✅ Animations (open for creative freedom)
- ✅ Haptics
- ✅ Error handling

**Animation Ideas (flexible):**
- Constellation expansion (shooting stars, orbits, fan-out)
- Portal launch effects (particles, glow)
- Stardust particle system
- Hover effects (scale, glow, parallax)

---

## UI/UX Principles

### Window Behavior
- **Default size:** 400x600 (narrow, vertical)
- **Fully resizable:** User can adjust as needed
- **Responsive layout:**
  - Width < 500px: Single column list
  - Width 500-800px: Wider cards, more info
  - Width > 800px: Auto-switch to 2-column grid
- **Remembers:** Last window size persists

### Constellation Interaction
**Primary: Hover to Expand**
- Hover for 0.3s → Portals fan out
- Shows what's inside before clicking
- Leave hover → Collapses back

**Fallback Options:**
- Long-press (0.5s) → Toggle expand/collapse
- Context menu → "Expand" / "Collapse"
- Click constellation → Launch all (doesn't require expand)

**Visual:**
```
[Collapsed]          [Expanded on Hover]
┌─────────┐              Portal 1
│ ⭐      │         Portal 2  Portal 3
│ Morning │    →       Portal 4
│ 5 items │         Portal 5
└─────────┘
```

### Context Menu Pattern
**Portal Context Menu:**
- Open
- Edit
- Toggle Favorite
- Delete (destructive)

**Constellation Context Menu:**
- Launch All
- Expand/Collapse
- Edit
- Delete (destructive)

### List vs Grid Toggle
**Toolbar button:**
```swift
Button {
    viewMode = viewMode == .list ? .grid : .list
} label: {
    Image(systemName: viewMode == .list ? "square.grid.2x2" : "list.bullet")
}
```

**Grid Layout:**
- 2-3 columns depending on width
- Larger cards with prominent thumbnails
- Better for visual browsing

---

## Build Phases

### Estimated Timeline
- **Phase 1 (Core):** 60 minutes
- **Phase 2 (Share Extension):** 30 minutes
- **Phase 3 (Constellations):** 45 minutes
- **Phase 4 (Drag & Drop):** 30 minutes
- **Phase 5 (Intelligence):** 45 minutes
- **Phase 6 (Widgets):** 60 minutes
- **Phase 7 (Polish):** Flexible

**Total Core MVP:** ~4.5 hours  
**With Polish:** 5-6 hours

### Development Order
Build in sequence - each phase builds on the previous:
1. Core → Proven foundation
2. Share Extension → Killer feature unlocked
3. Constellations → Power user feature
4. Drag & Drop → Natural interaction
5. Intelligence → Magical experience
6. Widgets → Extended reach
7. Polish → Delight and wonder

---

## Open for Future Iteration 🎨

### Animation/Polish (Phase 7+)
- Constellation expansion style (shooting stars, orbit patterns, etc.)
- Portal launch effects (particle systems, light trails)
- Sound design (cosmic audio, portal whoosh, etc.)
- Ambient backgrounds (slow-moving star field, nebula clouds)
- Themed animation packs (Solar, Nebula, Deep Space)

### Visual Design Details
- Final color palette (cosmic theme suggested, but flexible)
- Glass morphism parameters (blur, opacity, saturation)
- Typography choices (SF Pro family recommended)
- Icon library (SF Symbols + custom constellation icons)

### Marketing/Branding
- Extended tagline variations
- App Store description copy
- Screenshot composition strategy
- Promotional video scripts
- Launch strategy

### Advanced Features (Post-MVP)
- **App Launcher:** Generic app quick-launch section
- **Constellation Marketplace:** Share pre-built constellation templates
- **Spatial Shortcuts:** Hand gestures, voice commands
- **Ornament View:** Always-visible quick access bar
- **Multiple Themes:** User-customizable visual styles
- **Collaboration:** Share constellations with team

### Future Considerations
- iCloud sync across devices
- Export/import constellation libraries
- Analytics (most-used portals, patterns)
- Smart suggestions (based on time, context)
- Siri integration

---

## Quick Start Guide

### For Next Development Session

**What to share with Claude:**
1. This WAYPOINT_FOUNDATION.md file
2. WAYPOINT_DESIGN_VISION.md (if design details needed)
3. Current project status / code files

**What to say:**
"I'm building Waypoint, a universal link manager for visionOS. The foundation is defined in WAYPOINT_FOUNDATION.md. I want to start with Phase [X]. Let's build it."

**What NOT to do:**
- Don't overthink animations early (save for Phase 7)
- Don't add features outside the defined phases
- Don't complicate the Share Extension (keep it simple)
- Don't block UI with favicon fetching (async only)

**What TO do:**
- Follow the phase order
- Test each phase before moving forward
- Keep code clean with section markers
- Complete one phase fully before next
- Commit working code frequently

### Starting Phase 1: Create New Xcode Project

**Steps:**
1. Xcode → File → New → Project
2. Choose: visionOS → App
3. Product Name: **Waypoint**
4. Organization Identifier: **Unshackled-Pursuit**
5. Interface: SwiftUI
6. Save in preferred location

**Initial Setup:**
- Enable App Groups capability: `group.Unshackled-Pursuit.Waypoint`
- Set deployment target: visionOS 2.0+
- Configure bundle ID: `Unshackled-Pursuit.Waypoint`

Then start building Phase 1 components.

---

## Key Technical Decisions

### File Storage Strategy
**For `file://` URLs:**
- Copy files to app's Documents directory
- Store local path instead of `file://` URL
- Ensures persistence if original file moves/deletes
- Trade-off: Uses more storage, but guarantees reliability

### Async Favicon Fetching
**Never block UI:**
```swift
Task {
    let favicon = await FaviconService.fetch(for: url)
    await MainActor.run {
        portal.thumbnailData = favicon
    }
}
```
- Show placeholder immediately
- Update when favicon loads
- Timeout after 3 seconds
- Cache in memory during session

### Smart Name Extraction
**Hierarchy:**
1. Check iCloud URL fragment first
2. Attempt page title fetch (web only)
3. Use filename (files)
4. Clean domain name (fallback)

**Examples:**
- `icloud.com/notes#Python_Notes` → "Python Notes"
- `claude.ai` → Fetch `<title>` → "Claude | Anthropic"
- `file:///document.pdf` → "document"
- `example.com` → "Example"

### URL Scheme Handling
**Format:**
```
waypoint://add-portal?url=<percent-encoded-url>
```

**Handler in WaypointApp.swift:**
```swift
.onOpenURL { url in
    guard url.scheme == "waypoint",
          url.host == "add-portal",
          let urlParam = URLComponents(url: url, resolvingAgainstBaseURL: false)?
              .queryItems?.first(where: { $0.name == "url" })?.value,
          let decodedURL = urlParam.removingPercentEncoding else {
        return
    }
    
    pendingURL = decodedURL
    showAddPortal = true
}
```

---

## Success Criteria

### Phase 1 Complete When:
- [ ] Can manually add portals
- [ ] Portals display in list
- [ ] Can edit portal details
- [ ] Can delete portals
- [ ] Clicking portal opens URL correctly
- [ ] Data persists after app restart

### Phase 2 Complete When:
- [ ] Can share from Safari to Waypoint
- [ ] Can share from Notes to Waypoint
- [ ] URL auto-populates in add form
- [ ] Share Extension closes smoothly
- [ ] Portal saves and appears in main app

### Phase 3 Complete When:
- [ ] Can create constellation from selected portals
- [ ] Constellation appears in list
- [ ] Clicking constellation launches all portals
- [ ] Can edit constellation (add/remove portals)
- [ ] Can delete constellation

### Phase 4 Complete When:
- [ ] Can drag URL from Safari → Waypoint
- [ ] Can drag file from Files → Waypoint
- [ ] Portal auto-creates with correct name
- [ ] File URLs persist correctly
- [ ] Drop zone shows visual feedback

### Phase 5 Complete When:
- [ ] Favicons auto-fetch for web URLs
- [ ] Names auto-extract from URLs
- [ ] iCloud URLs parse correctly
- [ ] Fetching doesn't block UI
- [ ] Fallbacks work when fetch fails

### Phase 6 Complete When:
- [ ] Small widget displays portal
- [ ] Medium widget displays constellation
- [ ] Large widget displays grid
- [ ] Tapping widget opens portal/constellation
- [ ] Widget updates when data changes

### MVP Complete When:
- [ ] All 6 phases working
- [ ] No critical bugs
- [ ] Smooth user experience
- [ ] Data persists reliably
- [ ] Share Extension reliable

---

## Project File Structure

```
Waypoint/
├── Models/
│   ├── Portal.swift
│   ├── Constellation.swift
│   ├── PortalType.swift
│   ├── PortalManager.swift
│   └── ConstellationManager.swift
├── Views/
│   ├── PortalListView.swift
│   ├── AddPortalView.swift
│   ├── ConstellationCard.swift
│   └── PortalCard.swift
├── Services/
│   ├── FaviconService.swift
│   ├── NameExtractor.swift
│   ├── LinkDetector.swift
│   └── FileManager+Extensions.swift
├── WaypointApp.swift
└── Assets.xcassets

WaypointShareExtension/
├── ShareViewController.swift
├── Info.plist
└── Entitlements

WaypointWidget/
├── WaypointWidget.swift
├── WaypointWidgetBundle.swift
└── Assets.xcassets
```

---

## Common Pitfalls to Avoid

### 1. Favicon Blocking UI
**Wrong:**
```swift
.onAppear {
    let favicon = fetchFavicon(url)  // Blocks UI!
    thumbnailData = favicon
}
```

**Right:**
```swift
.onAppear {
    Task {
        let favicon = await fetchFavicon(url)
        await MainActor.run {
            thumbnailData = favicon
        }
    }
}
```

### 2. File URL Persistence
**Wrong:**
```swift
// Just store file:// URL
portal.url = fileURL.absoluteString
```

**Right:**
```swift
// Copy file to app storage
let localURL = copyToDocuments(fileURL)
portal.url = localURL.absoluteString
```

### 3. Share Extension Complexity
**Wrong:**
- Trying to fix first-share freeze with workarounds
- Adding phantom URLs
- Complex state management

**Right:**
- Simple pass-through to main app
- Let main app handle everything
- Accept minor visionOS quirks

### 4. Over-Engineering Early
**Wrong:**
- Building animations in Phase 1
- Adding features not in scope
- Optimizing before it works

**Right:**
- Build functionality first
- Polish in Phase 7
- Ship working > ship perfect

---

## Notes for Future Sessions

### When Picking Up Development
1. Read this foundation doc first
2. Check which phase you're on
3. Review success criteria for that phase
4. Build incrementally
5. Test before moving forward

### When Adding Features
1. Does it fit the core promise ("2 seconds to anywhere")?
2. Is it in the defined phases?
3. Will it complicate the MVP?
4. Can it wait for post-launch?

### When Facing Bugs
1. Is it a visionOS quirk or real bug?
2. Does a workaround make it worse?
3. Can we accept it and document it?
4. Is it blocking core functionality?

### Communication with Claude
**Good prompts:**
- "Let's build Phase 3 (Constellations)"
- "The Share Extension isn't passing URLs correctly"
- "How should we handle file URL persistence?"

**Avoid:**
- "Make it better" (too vague)
- "Add everything from the design doc" (too much at once)
- "Fix all bugs" (be specific)

---

**End of Foundation Document**

*This document defines the core of Waypoint. Everything else is refinement.*

**The foundation is locked. The magic is yours to add.** ✨
