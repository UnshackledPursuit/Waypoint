# Waypoint - Complete Foundation Document v3.0

**Created:** December 29, 2024  
**Status:** Production Ready - Universe View Architecture  
**Philosophy:** "2 seconds to anywhere" - Spatial computing meets instant access

---

## Table of Contents

1. [Core Vision](#core-vision)
2. [Locked Decisions](#locked-decisions)
3. [Data Architecture](#data-architecture)
4. [Interface Modes](#interface-modes)
5. [Feature Set](#feature-set)
6. [Technical Feasibility](#technical-feasibility)
7. [What We're NOT Building](#what-were-not-building)
8. [Build Phases](#build-phases)
9. [Success Metrics](#success-metrics)

---

## Core Vision

### The Promise
**"2 seconds to anywhere"** - Instant access to your digital universe through spatial computing.

### The Differentiator
Waypoint is the first universal link manager built **for** visionOS spatial computing, not retrofitted from iOS.

**Key Differentiators:**
- **Orb-based spatial visualization** - 3D interactive spheres, not flat lists
- **Multiple interface modes** - Beacon (stack), Galaxy (sphere), Universe (overview)
- **Constellation workflows** - Batch launch entire workspaces
- **Native visionOS interactions** - Gaze + pinch, drag & drop, spatial memory
- **USDZ-first** - 3D files are first-class citizens
- **Universe management** - Strategic overview of entire digital cosmos

### Design Philosophy

**Simplicity & Consistency:**
- Core interactions instantly understandable
- Progressive disclosure (simple → powerful)
- One great way > three mediocre alternatives

**Respect Native Apps:**
- Safari is excellent on visionOS - use it as default
- Don't force users into inferior embedded browsers
- Native app integration > replacement

**Spatial First:**
- Leverage visionOS unique capabilities
- Orb visualizations feel naturally spatial
- Volume interactions are intuitive
- Universe view provides god-mode overview

---

## Locked Decisions

### Terminology
- **Portal** = Individual link (web, file, USDZ, app)
- **Constellation** = Grouped portals (workflows)
- **Orb** = Spatial visualization of portal (glowing sphere)
- **Beacon Mode** = Vertical stack for quick access (productivity)
- **Galaxy Mode** = 3D sphere formation for exploration
- **Universe View** = Strategic overview of all constellations
- **Immersive** = Unbounded management space (Phase 9, future)

### Core Promise
**"2 seconds to anywhere"** through:
1. Zero-friction input (drag & drop with auto-fill)
2. Batch launching (constellations)
3. Spatial quick access (orbs)
4. Native app integration (Safari, etc.)
5. Universe-level organization

### Supported Link Types
```swift
enum PortalType: String, Codable {
    case web        // https://, http://
    case file       // PDF, docs, images
    case usdz       // 3D models (special treatment)
    case folder     // Directories with nested contents
    case icloud     // iCloud URLs (Notes, Freeform, etc.)
    case app        // Deep links (notion://, figma://, etc.)
}
```

### Default Behaviors
- **Portal open:** Native app (Safari for web)
- **Constellation launch:** Staggered 0.05-0.5s delays (user configurable, default 0.3s)
- **Drop behavior:** Auto-create portal with intelligent name/favicon
- **Interface mode:** User choice (Beacon, Galaxy, or Universe)
- **Glow mode:** User choice (App Type, Icon Color, or Constellation Color)
- **Portal removal:** Returns to "All Portals" library (not deleted)
- **Portal deletion:** Permanent (requires explicit confirmation)

---

## Data Architecture

### Portal Model

```swift
struct Portal: Identifiable, Codable, Hashable {
    // MARK: - Core Properties
    let id: UUID
    var name: String
    var url: String
    var type: PortalType
    
    // MARK: - Visual Properties
    var thumbnailData: Data?           // Auto-fetched favicon
    var customThumbnail: Data?         // User override
    var useCustomThumbnail: Bool = false
    
    // MARK: - Organization
    var isPinned: Bool = false         // Pinned filter
    var sortIndex: Int = Int.max       // For manual ordering
    var tags: [String] = []
    
    // MARK: - Metadata
    var dateAdded: Date = Date()
    var lastOpened: Date?
    var openCount: Int = 0             // For Recent section
    
    // MARK: - Preferences
    var preferEmbedded: Bool = false   // Open in Waypoint window vs native
    var embedWindowSize: CGSize = CGSize(width: 1200, height: 800)
    
    // MARK: - Computed Properties
    var displayThumbnail: Data? {
        useCustomThumbnail ? customThumbnail : thumbnailData
    }
}
```

**Key Principle:** Each portal has a unique URL. Different YouTube playlist URLs = different portals.

### Constellation Model

```swift
struct Constellation: Identifiable, Codable, Hashable {
    // MARK: - Core Properties
    let id: UUID
    var name: String
    var portalIDs: [UUID]              // References to portals (NOT ownership)
    
    // MARK: - Visual Properties
    var icon: String = "star.fill"     // SF Symbol name
    var customThumbnail: Data?         // User override
    var color: Color = .blue           // For orb glow and organization
    
    // MARK: - Organization
    var isActive: Bool = true          // Show/hide toggle
    var sortOrder: Int = 0             // User-defined order
    
    // MARK: - Metadata
    var dateCreated: Date = Date()
    var lastOpened: Date?
    
    // MARK: - Spatial Properties
    var universePosition: CGPoint?     // Position in Universe View
    
    // MARK: - Beacon Mode Settings
    var beaconMode: BeaconDisplayMode = .favorites
    var manualSelection: [UUID] = []   // For manual mode
}

enum BeaconDisplayMode: String, Codable {
    case favorites  // Show favorited portals (max 8)
    case manual     // User-selected 8 portals
    case all        // All portals (paginated)
}
```

**Critical Principle: Portal References, Not Ownership**

- Portals exist independently in `PortalManager`
- Constellations **reference** portals by UUID (like database foreign keys)
- Same portal can be referenced by multiple constellations
- Deleting constellation does NOT delete portals
- Removing portal from constellation returns it to "All Portals"
- Deleting portal requires explicit "Delete Portal" action (with confirmation)

**Example:**
```
Portal: youtube.com/playlist/WorkMusic (UUID: abc-123)

Morning Constellation:
  portalIDs: [abc-123, def-456, ghi-789]
  
Creative Constellation:
  portalIDs: [abc-123, jkl-012, mno-345]

Both constellations reference the same YouTube portal.
```

### Managers

```swift
@Observable
class PortalManager {
    // MARK: - Properties
    var portals: [Portal] = []         // SOURCE OF TRUTH for all portals
    private let appGroupID = "group.Unshackled-Pursuit.Waypoint"
    
    // MARK: - CRUD Operations
    func add(_ portal: Portal)
    func update(_ portal: Portal)
    func delete(_ portal: Portal)      // Removes from ALL constellations
    func movePortals(from: IndexSet, to: Int)
    
    // MARK: - Organization
    func togglePin(_ portal: Portal)
    func updateLastOpened(_ portal: Portal)
    func search(query: String) -> [Portal]

    // MARK: - Computed Filters
    var pinned: [Portal] {
        portals.filter { $0.isPinned }
    }
    
    var recent: [Portal] {
        portals
            .filter { $0.lastOpened != nil }
            .sorted { ($0.lastOpened ?? .distantPast) > ($1.lastOpened ?? .distantPast) }
            .prefix(10)
            .map { $0 }
    }
    
    var unassigned: [Portal] {
        let assignedIDs = Set(constellationManager.constellations.flatMap { $0.portalIDs })
        return portals.filter { !assignedIDs.contains($0.id) }
    }
    
    // MARK: - Persistence
    private func save()
    private func load()
}

@Observable
class ConstellationManager {
    // MARK: - Properties
    var constellations: [Constellation] = []
    
    // MARK: - CRUD Operations
    func create(name: String, portalIDs: [UUID])
    func update(_ constellation: Constellation)
    func delete(_ constellation: Constellation)  // Doesn't delete portals
    
    // MARK: - Portal References (Not Ownership)
    func addPortals(_ portalIDs: [UUID], to constellation: Constellation)
    func removePortals(_ portalIDs: [UUID], from constellation: Constellation)
    
    // MARK: - Organization
    func toggleActive(_ constellation: Constellation)
    func reorder(from: IndexSet, to: Int)
    
    // MARK: - Computed Properties
    var activeConstellations: [Constellation] {
        constellations
            .filter { $0.isActive }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func getPortals(for constellation: Constellation) -> [Portal] {
        portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
    }
    
    // MARK: - Persistence
    private func save()
    private func load()
}
```

### Pinned & Constellations: Organization System

**Important:** Favorites have been removed. Use Constellations for organization.

- **Pinned:** Portal.isPinned == true (quick filter)
- **Constellations:** Primary organization method
- Portals show constellation icons they belong to
- Filter menu includes constellation filters

**Why this change:**
- Constellations are more powerful than favorites
- Reduces redundant organization concepts
- One clear way to group portals
- Constellation icons visible on portal rows

---

## Interface Modes

Waypoint offers three primary interface modes with distinct use cases.

### Level 1: Beacon Mode (Productivity Stack)

**Description:** Vertical stack of portals for quick access

**When to use:**
- Working alongside other apps
- Quick portal launching
- Minimal space footprint
- Task-focused work

**Visual:**
```
┌─────┐
│  📧 │  ← Orb 1 (Gmail)
├─────┤
│  📅 │  ← Orb 2 (Calendar)
├─────┤
│  🤖 │  ← Orb 3 (Claude)
├─────┤
│  📝 │  ← Orb 4 (Notion)
├─────┤
│  🎨 │  ← Orb 5 (Figma)
├─────┤
│  🎵 │  ← Orb 6 (Spotify)
├─────┤
│  💬 │  ← Orb 7 (Slack)
├─────┤
│  📊 │  ← Orb 8 (Sheets)
└─────┘
┌─────┐
│ ⚡↔ │  ← Mode toggle button
└─────┘
```

**Dimensions:**
- Width: 100px (minimal, sits next to work windows)
- Height: Dynamic (8 orbs × 100px spacing = ~800px)
- Depth: 50px (shallow, doesn't intrude)

**Portal Selection (3 Modes):**

**1. Favorites Mode (Default)**
- Shows favorited portals from constellation
- Max 8 orbs per page
- Auto-selected based on portal.isFavorite
- Falls back to most-used if < 8 favorites

**2. Manual Selection**
- User explicitly picks 8 portals
- Saved per constellation
- Full control over what appears

**3. All Mode (Paginated)**
- Shows all portals in constellation
- 8 portals per page
- Swipe UP/DOWN to change pages
- Max 3 pages (24 portals total)
- Rare use case

**Constellation Switching:**
- **Swipe LEFT/RIGHT:** Change constellation
- Brief label appears: "Morning → Work"
- Smooth animation (orbs fly out left, new ones fly in right)

**Interactions:**
- **Look + pinch orb:** Launch that portal
- **Look + long pinch:** Context menu (Open, Edit, Add to Constellation, Delete)
- **Tap toggle button:** Switch to Galaxy mode
- **Swipe up/down (All mode only):** Change page

**Use Case:**
User working on project in Mail, Notion, Figma. Beacon visible off to the right with 8 most-used portals. Quick pinch to launch without disrupting workspace.

---

### Level 2: Galaxy Mode (3D Exploration)

**Description:** Portals arranged in 3D sphere formation around constellation center

**When to use:**
- Exploring constellation contents
- Organizing portals spatially
- Visual browsing
- Rearranging workflows

**Visual:**
```
        ·
       · · ·
      ·  🌌  ·     ← Constellation center orb
       · · ·
        ·
        
(Portals orbit in 3D sphere)
(Fibonacci distribution for even spacing)
```

**Layout:**
- Fibonacci sphere distribution (mathematically even spacing)
- All portals visible (no cap)
- Radius: ~0.3 meters from center
- Depth creates spatial feeling

**Interactions:**
- **Look at center orb + pinch:** Launch entire constellation (all portals)
- **Look at individual orb + pinch:** Launch that portal only
- **Look at orb + long pinch:** Context menu
- **Tap toggle button:** Switch to Beacon mode

**Animations:**
- **Scatter:** Portals expand from center in radial pattern
- **Gather:** Portals contract back to center
- **Rotation:** Subtle orbital motion (slow, gentle)
- **Glow:** Based on selected mode (App Type, Icon Color, or Constellation)

**Use Case:**
User wants to see all 15 portals in "Creative" constellation. Opens Galaxy mode, visually browses the sphere, pinches specific portal to launch. Feels spatial and magical.

---

### Level 3: Universe View (Strategic Overview)

**Description:** All constellations visible with movable portal library for organization

**When to use:**
- High-level organization
- Creating new constellations
- Assigning portals to constellations
- Seeing entire digital universe
- Managing constellation relationships
- Strategic planning

**Visual:**

**Main View: Constellation Web**
```
       🌌 Morning
      /    \
 🌟 Work    💫 Personal
      \    /
   ⭐ Creative
   
(All constellation nodes visible)
(Lines connect them aesthetically)
```

**Library Overlay (Movable):**
```
┌────────────┐
│  Library   │
│ ☆📁🔍      │  ← Tabs: Favorites | Pinned | All | Search
├────────────┤
│  📧  🤖   │
│  📅  📝   │
│  🎨  🎵   │
│  💬  📊   │  ← Portal grid (scrollable)
│            │
└────────────┘
```

**Features:**

**1. Constellation Nodes**
- Simplified representation (not full orb detail)
- User-assigned color glow
- Name label below node
- **Tap node:** Opens detail window (Galaxy or Beacon mode for that constellation)

**2. Visual Web**
- Lines connect constellation nodes
- **Aesthetic only** (no functional meaning beyond showing your universe structure)
- User can rearrange nodes spatially
- Lines adjust automatically

**3. Library Overlay (Movable)**
- **Default position:** Right side of window
- **Drag anywhere:** Move panel to any position in window
- **Minimize to tab:** Drag to window edge → Collapses to small "📚" tab
- **Restore from tab:** Drag tab back into window → Expands to full panel
- **Close entirely:** Button or swipe off edge

**Library Contents:**
- **Favorites tab:** Shows portal.isFavorite == true
- **Pinned tab:** Shows portal.isPinned == true
- **All tab:** Shows all portals (scrollable)
- **Search:** Real-time filter across all portals

**4. Portal Assignment**
- **Drag portal from library** onto constellation node
- Portal "absorbed" with animation (node glows, portal shrinks and flies in)
- Sound + haptic feedback
- Portal now referenced by that constellation

**5. Constellation Management**
- **Create new:** "+" button → Empty node appears → Name it → Drag portals onto it
- **Toggle active/hidden:** Settings (hidden constellations don't appear in Beacon/Galaxy selectors)
- **Reorder:** Settings menu with drag-to-reorder list
- **Delete:** Right-click constellation → Delete (confirmation required, portals not deleted)

**6. Two-Tier Navigation System**

**Key Innovation:** Universe View is strategic overview. Detail work happens in separate window.

**Flow:**
```
1. User opens Universe View (volumetric window)
   → Sees all constellation nodes
   → Library overlay available
   
2. User taps "Morning" constellation node
   → Universe View stays open (can minimize if desired)
   → New window opens: Morning constellation in Galaxy OR Beacon mode
   → Full orb detail, all Phase 6 interactions
   
3. User finishes managing Morning constellation
   → Closes detail window
   → Returns focus to Universe View
   
4. User taps "Work" constellation node
   → Opens another detail window for Work
```

**Why This Works:**
- Universe View stays simple (overview only, simplified nodes)
- Constellation detail gets full window space (no cramming)
- Two focused tools instead of one complex tool
- Natural hierarchy: Strategic (Universe) → Tactical (Galaxy/Beacon)

**Window Types:**
- **Universe View:** Volumetric window (~1.3m × 1.0m × 0.5m)
- **Constellation Detail:** Volumetric window (~1.0m × 1.0m × 1.0m, Phase 6)
- Can exist simultaneously (alt-tab between them)

**Interactions:**
- **Tap constellation node:** Opens detail window
- **Drag constellation node:** Repositions in space (lines adjust)
- **Right-click constellation:** Context menu (Edit, Delete, Launch All)
- **Drag portal from library onto node:** Assigns portal to constellation
- **Search library:** Type to filter in real-time

**Portal Lifecycle in Universe View:**
```
1. Create portal (drag & drop, manual, etc.)
   → Portal appears in "All Portals" tab (unassigned)
   
2. Drag portal from library onto "Morning" constellation node
   → Portal absorbed, now referenced by Morning
   
3. Remove portal from Morning (in detail window)
   → Portal goes back to "All Portals" in library
   
4. Delete portal (explicit action with confirmation)
   → Removed from ALL constellations + deleted permanently
```

**Accessing Universe View:**
- From Window mode: Menu item or toolbar button
- From Beacon mode: "Universe" button in toolbar
- From Galaxy mode: "Universe" button in toolbar

**Window Type:**
- Volumetric window (bounded, ~1.3m × 1.0m)
- Can exist alongside other apps
- Does NOT require full immersion
- Available in Phase 8.5 (before Phase 9)

---

## Interface Mode Summary

| Mode | Use Case | Window Type | Portal Cap | Constellation Count |
|------|----------|-------------|------------|---------------------|
| **Beacon** | Quick access | Volume | 8 per page | 1 at a time |
| **Galaxy** | Exploration | Volume | No cap | 1 at a time |
| **Universe** | Organization | Volume | Library (scrollable) | All visible (simplified) |
| **Immersive** (Phase 9) | God mode | ImmersiveSpace | No cap | All visible (full detail) |

**User Flow:**
- **Daily work:** Beacon mode (quick access, productivity)
- **Weekly organizing:** Galaxy mode (manage one constellation)
- **Monthly planning:** Universe View (strategic overview)
- **Power users (future):** Immersive mode (full control, Phase 9)

---

## Feature Set

### Core Features (Essential MVP - Phases 2-8.5)

#### Phase 2: Input Magic (3 hours)

**Universal Drag & Drop:**
- URLs from Safari/browsers
- Files from Files app (PDF, docs, images)
- USDZ 3D models
- Folders (creates folder portal)
- Multi-item batch support (6+ shows confirmation UI)
- Visual feedback during drag (drop zone highlight)
- Auto-fill integration (name + favicon)
- Success notifications

**Auto-Fill Intelligence:**
- Smart name extraction (domain, filename, iCloud fragment)
- Async favicon fetching (non-blocking)
- HTML title extraction for web URLs
- Fallback hierarchy (title → domain → filename → "Portal")

**Clipboard Detection:**
- Auto-detect copied URLs when app becomes active
- Smart prompt: "Add this link?"
- Settings toggle to enable/disable
- "Don't ask again" option

**URL Scheme:**
- `waypoint://add?url=...` for deep linking
- Shortcuts integration
- Power user automation

**Manual Creation:**
- Form with validation
- Auto-https completion (if user types "claude.ai" → "https://claude.ai")
- Portal preview
- Custom icon upload option

**Drag Reordering:**
- Within constellations
- Within All Portals library
- Visual feedback (space opens, items shift)
- Persisted order

#### Phase 4: SwiftUI Orbs (4 hours)

**Portal Orbs:**
- Glass sphere with embedded icon/favicon
- Convex gradient effect (feels 3D)
- Outer glow (RadialGradient based on color mode)
- Rim highlights (subtle edge lighting)
- Shadow effects (depth)
- Subtle pulse animation (breathing effect)

**Constellation Orbs:**
- Larger sphere (1.2x size of portal orbs)
- Shows constellation icon
- Stronger glow (more intense)
- Pulsing animation (attention-grabbing)
- Tap to expand/collapse

**Glow System (3 Modes):**
- **App Type:** Blue (web), Purple (file), Orange (USDZ), Cyan (folder), Teal (iCloud), Green (app)
- **Icon Color:** Extract dominant color from favicon (algorithm in Phase 4)
- **Constellation Color:** User-assigned color from constellation settings
- User selects preference in settings (applies globally)

**Expand/Collapse Animation:**
- Calculate radial positions (Fibonacci sphere for even distribution)
- Spring animation on expand (orbs fly out from center)
- Orbs fan out in perfect circle formation
- Collapse back to center (reverse animation)
- Tap center to toggle

#### Phase 5: Beacon + Galaxy Modes (2 hours)

**Beacon Mode Implementation:**
- Vertical stack layout (VStack with spacing)
- Portal selection system (3 modes: Favorites, Manual, All)
- Pagination logic (8 per page, max 3 pages)
- Constellation swipe switching (horizontal DragGesture)
- Page swipe (vertical DragGesture, only in All mode)
- Mode toggle button (switches to Galaxy)

**Galaxy Mode Implementation:**
- Volumetric window setup
- Sphere layout (Fibonacci distribution algorithm)
- Look + pinch interactions (gaze targeting + SpatialTapGesture)
- Mode toggle button (switches to Beacon)

#### Phase 6: RealityKit Volume (4 hours)

**3D Orb Entities:**
- PortalOrbEntity (RealityKit Entity subclass)
- Sphere mesh with glass material (PhysicallyBasedMaterial)
- Glow sphere child entity (UnlitMaterial with transparency)
- Icon texture plane (mapped from portal.displayThumbnail)
- Rotation component (slow spin on Y axis)
- InputTargetComponent (for gaze + pinch)
- CollisionComponent (for gesture detection)

**Scatter/Gather Animation:**
- Calculate scatter positions (radial from center)
- Animate orb movement (RealityKit .move() with spring timing)
- Particle trail effects (follow orbs during scatter)
- Energy burst on gather (particle system at center)
- Center orb flash (brief intensity increase)
- Spring physics timing (feels natural)

**Look + Pinch Launch:**
- Gaze targeting (ray cast from eye position)
- Highlight orb on gaze (increase glow intensity)
- SpatialTapGesture detection (pinch in 3D space)
- Launch portal when gaze + pinch combined
- Launch all when looking at center + pinch

**Context Menu:**
- Look + long pinch detection (LongPressGesture 0.5s)
- Radial context menu (circular layout)
- Options: Open, Edit, Add to Constellation, Delete
- Smooth menu appearance animation

#### Phase 7: Constellations (2 hours)

**Constellation Creation:**
- Multi-select portals (checkbox on each card)
- Select all/none buttons
- "Create Constellation" action button
- Preview before creation (show selected count)
- Name, icon, color picker in creation sheet

**Staggered Launch:**
- Launch all portals with delays (default 0.3s between each)
- User-configurable timing (0.05s - 0.5s in settings)
- Progress indicator (shows which portal is launching)
- Cancel option (stop mid-launch)
- Success feedback (all portals opened notification)

**Constellation Management:**
- Edit constellation (add/remove portals)
- Delete with confirmation ("This will not delete the portals")
- Toggle active/hidden (show/hide in selectors)
- Reorder in settings (drag to reorder list)
- Icon picker (SF Symbols browser)
- Color picker (system ColorPicker)

#### Phase 8: visionOS Polish (2 hours)

**USDZ Support:**
- Detect .usdz files on drop
- RealityKit thumbnail generation (render 3D preview)
- Quick Look preview on tap (native visionOS Quick Look)
- 3D inline preview (optional, small rotating view)
- File metadata display (polygon count, file size)

**Folder Portals:**
- Detect folders on drop (hasDirectoryPath check)
- Scan folder contents (FileManager enumeration)
- Nested portal display (expandable list)
- Expandable UI (disclosure group)
- Refresh button (re-scan folder)
- Item count badge (shows number of items)

**Recent Section:**
- Track portal opens (update lastOpened date)
- Recent section at top of portal list
- Last 5-10 portals (sorted by lastOpened desc)
- Clear recent action (reset all lastOpened dates)

**Search & Filters:**
- Search bar component (TextField with magnifying glass icon)
- Real-time filtering (as user types)
- Filter by type (web, file, USDZ, folder, iCloud, app)
- Filter by favorites/pinned (toggle buttons)
- Clear filters button

#### Phase 8.5: Universe View (4 hours) 🆕

**Universe Window Setup:**
- Create universeView WindowGroup
- Volumetric window (~1.3m × 1.0m × 0.5m)
- Initialize with all active constellations
- Basic layout (constellation nodes in spatial arrangement)

**Constellation Nodes:**
- Simplified representation (sphere with glow, not full orb detail)
- User-assigned color glow (from constellation.color)
- Name label below node (Text component)
- Icon display (constellation.icon)
- **Tap to open detail window** (opens Galaxy or Beacon mode)

**Visual Web:**
- Lines connecting constellation nodes (Path/Shape drawing)
- Aesthetic visualization (Bezier curves)
- Animated glow on lines (subtle pulsing)
- Can be rearranged (drag nodes, lines adjust automatically)

**Library Overlay:**
- Floating panel with portal grid (LazyVGrid)
- Tabs: Favorites | Pinned | All (Picker)
- Search bar (TextField with filtering)
- Scroll support (ScrollView)
- Drag gesture detection (DragGesture for moving panel)

**Movable Library:**
- Drag overlay anywhere in window (@State position property)
- Edge detection (if x > windowWidth - 50, minimize to tab)
- Tab state (collapsed icon showing "📚")
- Restore from tab (drag tab back in, expand with animation)
- Smooth animations (withAnimation spring)

**Portal Assignment:**
- Drag from library → constellation node (DragGesture + drop destination)
- Drop detection (collision checking)
- Absorption animation (scale down + move to node center)
- Sound + haptic feedback (UINotificationFeedbackGenerator)
- Update data model (constellation.portalIDs.append(portal.id))

**Two-Tier Navigation:**
- Tap constellation node → Opens detail window (openWindow API)
- Detail window = Galaxy or Beacon mode (existing Phase 6 window)
- WindowGroup coordination (pass constellation ID as parameter)
- Back navigation (close detail window, return focus to universe)
- State persistence (remember which window was open)

---

## Technical Feasibility

### ✅ Fully Feasible (100% Confidence)

**SwiftUI-Based Features:**
- Universal drag & drop (all file types)
- Drag reordering (.onMove, DragGesture)
- Auto-fill intelligence (async/await Task)
- Context menus (native .contextMenu)
- Search & filtering (real-time with @State)
- Portal/Constellation CRUD (Observable pattern)
- Settings & preferences (UserDefaults/AppStorage)
- Orb visualization (SwiftUI effects)
- Glow system (RadialGradient, materials)
- Animations (spring physics, .withAnimation)

**RealityKit-Based Features:**
- USDZ thumbnail generation (RealityKit rendering)
- Volume mode (volumetric WindowGroup)
- 3D orb entities (ModelEntity with materials)
- Scatter/gather animations (Entity.move API)
- Gesture recognition (SpatialTapGesture)
- Particle effects (ParticleEmitterComponent)
- Physics simulation (PhysicsBodyComponent)

**Window Management:**
- Multiple WindowGroups (standard visionOS)
- Volumetric windows (.windowStyle(.volumetric))
- Window sizing hints (.defaultSize)
- openWindow/dismissWindow (SwiftUI Environment)

**Data Persistence:**
- App Groups (shared storage between app/extensions)
- UserDefaults (simple key-value data)
- FileManager (file copying for file:// URLs)
- Codable models (JSON serialization)

### ⚠️ Partially Feasible (Workarounds Available)

**Spatial Anchoring:**
- ❌ Cannot set exact window coordinates (visionOS limitation)
- ✅ Can provide placement hints (.defaultPosition)
- ✅ Can save user preferences (last position)
- ✅ Approximate positioning works (good enough)

**Window Control:**
- ❌ Cannot force Safari to open new windows (Safari controls this)
- ✅ Can stagger timing (increases likelihood of separate windows)
- ✅ Can use embedded windows (full control, optional Phase 3)

### ❌ Not Feasible (System Limitations)

**Security/Sandboxing:**
- Safari tab extraction/manipulation (sandboxing prevents)
- Forcing native app window behaviors (apps control themselves)
- Cross-app window positioning (privacy/security)

**Why These Don't Matter:**
- visionOS window management is excellent
- Native apps should control their own behavior
- Workarounds exist (embedded windows, staggered launch)
- User experience not compromised

---

## What We're NOT Building

### Share Extension ❌

**Reason:** iOS paradigm, causes cascading technical issues on visionOS

**Issues encountered (4 failed attempts):**
- XML parsing errors
- Bundle ID hierarchy conflicts
- Missing environment objects
- RealityKit incompatibility (breaks USDZ support)
- Forced removal of essential features

**Why it's not needed:**
- Drag & drop is faster (2s vs 5s)
- Clipboard detection covers "copied link" use case
- URL scheme enables automation
- More visionOS-native than share sheet

**Decision:** Skip entirely, build superior alternatives

### Context-Aware Auto-Launch ❌

**Reason:** Premature optimization

**What we're skipping:**
- Time-based triggers ("Launch Morning at 7am")
- Location-based suggestions ("You're at Starbucks, open Work constellation")
- Pattern detection ("You always open these together")
- Automatic launching without user action

**Why:**
- Needs significant usage data first
- Risk of being annoying vs helpful
- Better to nail manual control first
- Can revisit post-launch if users request

### Portal Sharing & Marketplace ❌ (For Now)

**Reason:** Network effects require user base

**What we're skipping:**
- Share codes for portals/constellations
- QR code generation/scanning
- Import from code
- Community marketplace
- Curated library from others

**Why:**
- Need users before creating sharing features
- Quick Start collections cover initial need (15 curated portals)
- Can add post-launch if requested
- Focus on individual experience first

### Multi-Device Sync (iCloud) ❌ (For Now)

**Reason:** visionOS-first focus

**What we're skipping:**
- iCloud CloudKit sync
- Cross-device constellation sharing
- Mac/iPad companion apps
- Universal handoff

**Why:**
- visionOS is target platform
- Local persistence is simpler
- Can add when expanding platforms
- Avoid complexity tax early

---

## Build Phases

### Total Core Development: 22 hours
### With Immersive Management: 33 hours

---

### Phase 1: Complete ✅ (Phase 1.2)

**Status:** Stable at commit 52b792a

---

### Phase 2: Complete ✅

**Status:** Stable at commit 0e46db9

**Features:**
- ✅ Portal CRUD (Create, Read, Update, Delete)
- ✅ Pin/Favorite system
- ✅ Sorting & filtering
- ✅ Quick Start collections (15 portals, 3 groups: AI, Pulse, Launchpad)
- ✅ Auto-https URL completion
- ✅ Context menus
- ✅ 3-column onboarding layout
- ✅ Section markers in code
- ✅ Clean architecture

**Foundation is solid - continue building from here.**

---

**What Was Built:**
- ✅ Quick Paste: One-tap portal creation from clipboard
- ✅ Quick Add: Type URL/site name (auto-adds https://www/.com)
- ✅ Manual drag reordering with Custom sort option
- ✅ Constellation system (models, manager, create view)
- ✅ Context menu "Add to Constellation" submenu
- ✅ Constellation filters in filter menu
- ✅ Constellation icons on portal rows
- ✅ URL scheme (waypoint://add, open, launch)
- ✅ Paste button in form with auto-fill
- ✅ Removed Favorites (replaced by Constellations)

**visionOS Limitation Discovered:** Safari drag & drop doesn't work reliably on visionOS. Solved with Quick Paste/Quick Add toolbar buttons instead.

**Testing Results:**
- [x] Quick Paste creates portal instantly
- [x] Quick Add works with bare names ("youtube" → youtube.com)
- [x] Drag to reorder works with Custom sort
- [x] Constellation creation works
- [x] Add to Constellation context menu works
- [x] Filter by constellation works
- [x] waypoint://add?url=... works

---

### Phase 3: Embedded Windows Experiment (2 hours) ⏸️

**Goal:** Test controlled window creation for constellations

**Status:** Experiment - build, test, decide to keep or remove

#### Features:
- WindowGroup for embedded browser
- WKWebView integration
- "Open in Safari" button
- Per-portal preference
- Constellation launch integration

#### Decision Point:
- [ ] Test with 5-portal constellation
- [ ] Compare: Embedded vs Safari experience
- [ ] User feedback (if available)
- [ ] **Decide:** Keep, refine, or remove

**If removed:** Revert code, update Phase 7 to use native-only launching

---

### Phase 4: SwiftUI Orbs (4 hours)

**Goal:** Beautiful spatial orb visualization

#### 4A: PortalOrb Component (60 min)
- Glass sphere effect (materials)
- Convex gradient overlay
- Embedded icon/favicon
- Outer glow (RadialGradient)
- Rim highlights
- Shadow effects
- Pulse animation

#### 4B: ConstellationOrb Component (45 min)
- Larger sphere (scale 1.2x)
- Constellation icon
- Stronger glow
- Pulsing animation
- Tap handler

#### 4C: Color Extraction & Glow System (30 min)
- Extract dominant color from favicon
- App type → color mapping
- Constellation color assignment
- Glow mode enum (3 options)
- Settings picker

#### 4D: Expand/Collapse Animation (45 min)
- Calculate radial positions (Fibonacci sphere)
- Spring animation on expand
- Orbs fan out in circle
- Collapse back to center
- Tap to toggle

#### 4E: Settings & Toggles (30 min)
- Glow mode picker (App Type, Icon Color, Constellation)
- Preview of each mode
- Launch delay slider (0.05s - 0.5s)
- Persist preferences

**Testing Criteria:**
- [ ] Single orb renders beautifully
- [ ] All 3 glow modes work
- [ ] Expand animation smooth
- [ ] Collapse brings orbs back
- [ ] Tap orb opens portal
- [ ] Animations are smooth (60fps)

---

### Phase 5: Beacon + Galaxy Modes (2 hours)

**Goal:** Two primary interface modes

#### 5A: Window Mode (30 min)
- List view (existing from Phase 1.2)
- Grid view toggle
- Search bar
- Clean toolbar

#### 5B: Beacon Mode (45 min)
- Vertical stack layout (VStack)
- Portal selection system (3 modes: Favorites, Manual, All)
- Pagination logic (8 per page, max 3 pages)
- Constellation swipe switching (horizontal DragGesture)
- Page swipe (vertical DragGesture, only for All mode)

#### 5C: Galaxy Mode (30 min)
- Volumetric window setup
- Sphere layout (Fibonacci distribution)
- Look + pinch interactions
- Mode toggle button

#### 5D: Mode Toggle (15 min)
- Button UI (icon changes based on mode)
- Smooth transition animation
- Persist mode preference
- Launch in preferred mode

**Testing Criteria:**
- [ ] Beacon shows 8 orbs vertically
- [ ] Swipe left/right changes constellation
- [ ] Swipe up/down changes page (All mode only)
- [ ] Galaxy shows all orbs in sphere
- [ ] Mode toggle works smoothly
- [ ] Preference persists after restart

---

### Phase 6: RealityKit Volume (4 hours)

**Goal:** 3D interactive orb space

#### 6A: Volumetric Window Setup (30 min)
- Create volume WindowGroup
- .windowStyle(.volumetric)
- Set default size (1m × 1m × 1m)
- Configure camera

#### 6B: RealityKit Orb Entities (90 min)
- PortalOrbEntity class
- Sphere mesh generation
- Glass material (PhysicallyBasedMaterial)
- Glow sphere (child entity with UnlitMaterial)
- Icon texture plane (from portal.displayThumbnail)
- Rotation component (slow Y-axis spin)
- InputTarget & Collision components

#### 6C: Scatter/Gather Animations (60 min)
- Calculate scatter positions (radial from center)
- Animate orb movement (Entity.move with spring)
- Particle trail effects
- Energy burst on gather
- Center orb flash
- Spring physics timing

#### 6D: Look + Pinch Launch (45 min)
- Gaze targeting (InputTargetComponent + ray cast)
- SpatialTapGesture integration
- Look at orb → Highlight (increase glow)
- Pinch → Launch portal
- Look at center + pinch → Launch all

#### 6E: Context Menu (15 min)
- Look + long pinch detection (LongPressGesture 0.5s)
- Radial context menu (circular layout)
- Options: Open, Edit, Add to Constellation, Delete
- Smooth menu appearance

**Testing Criteria:**
- [ ] Volume window appears correctly
- [ ] Orbs render as 3D spheres
- [ ] Scatter animation dramatic
- [ ] Gather animation smooth
- [ ] Look + pinch launches portal
- [ ] Look at center + pinch launches all
- [ ] Context menu works
- [ ] 60fps performance

---

### Phase 7: Constellations (2 hours)

**Goal:** Complete constellation functionality

#### 7A: Data Model & CRUD (40 min)
- ConstellationManager implementation
- Create constellation
- Edit (add/remove portals via references)
- Delete with confirmation
- Persistence

#### 7B: Multi-Select UI (30 min)
- Selection mode toggle
- Checkbox on portal cards
- Select all/none buttons
- "Create Constellation" action
- Preview before creation

#### 7C: Staggered Launch (30 min)
- Launch all with delays (default 0.3s)
- User-configurable timing slider
- Progress indicator
- Cancel option
- Success feedback

#### 7D: Management (20 min)
- Icon picker (SF Symbols browser)
- Color picker (system ColorPicker)
- Edit constellation sheet
- Drag portals into/out of constellation

**Testing Criteria:**
- [ ] Create constellation from 5 portals
- [ ] Edit: Add 2 more portals
- [ ] Edit: Remove 1 portal
- [ ] Change icon and color
- [ ] Launch constellation → All open with delays
- [ ] Delete constellation (portals remain)
- [ ] Portals persist independently

---

### Phase 8: visionOS Polish (2 hours)

**Goal:** Native visionOS features and feel

#### 8A: USDZ Support (40 min)
- Detect .usdz files on drop
- RealityKit thumbnail generation
- Quick Look preview on tap
- File metadata (polygon count, size)
- Special icon treatment

#### 8B: Folder Portals (35 min)
- Detect folders on drop
- Scan folder contents
- Nested portal display
- Expandable UI (DisclosureGroup)
- Refresh button
- Item count badge

#### 8C: Recent Section (20 min)
- Track portal opens (lastOpened date)
- Recent section at top
- Last 5-10 portals (sorted)
- Clear recent action

#### 8D: Search & Filters (25 min)
- Search bar component
- Real-time filtering (as user types)
- Filter by type (buttons)
- Filter by favorites/pinned (toggles)
- Clear filters button

**Testing Criteria:**
- [ ] Drop USDZ → 3D thumbnail generates
- [ ] Tap USDZ → Quick Look preview
- [ ] Drop folder → Shows contents
- [ ] Expand folder → See nested files
- [ ] Recent section updates on open
- [ ] Search filters portals instantly
- [ ] Type filters work (web, file, USDZ, etc.)

---

### Phase 8.5: Universe View (4 hours) 🆕

**Goal:** Strategic overview and high-level organization

#### 8.5A: Universe Window Setup (45 min)
- Create universeView WindowGroup
- Volumetric window (~1.3m × 1.0m × 0.5m)
- Initialize with all active constellations
- Basic spatial layout (nodes arranged)

#### 8.5B: Constellation Node Component (30 min)
- Simplified node (sphere with glow, no full orb detail)
- User-assigned color glow (from constellation.color)
- Name label below node
- Icon display (constellation.icon)
- Tap handler (opens detail window)

#### 8.5C: Visual Web (30 min)
- Lines connecting constellation nodes
- Bezier curves (Path drawing)
- Animated glow on lines (subtle pulse)
- Can be rearranged (drag nodes, lines adjust)

#### 8.5D: Library Overlay (60 min)
- Floating panel with portal grid (LazyVGrid)
- Tabs: Favorites | Pinned | All (Picker)
- Search bar (TextField with filtering)
- Scroll support (ScrollView)
- Drag gesture detection (for moving panel)

#### 8.5E: Movable Library (30 min)
- Drag overlay anywhere in window (@State position)
- Edge detection (minimize to tab when dragged to edge)
- Tab state (collapsed, shows "📚" icon)
- Restore from tab (drag back in, expand with animation)
- Smooth spring animations

#### 8.5F: Portal Assignment (30 min)
- Drag from library → constellation node
- Drop detection (collision checking)
- Absorption animation (scale + move to center)
- Sound + haptic feedback
- Update data model (constellation.portalIDs.append)

#### 8.5G: Two-Tier Navigation (30 min)
- Tap constellation node → Opens detail window (openWindow API)
- Detail window = Galaxy or Beacon mode (Phase 6 window)
- Pass constellation ID as parameter
- Back navigation (close detail, return to universe)
- State persistence (remember open windows)

**Testing Criteria:**
- [ ] Universe View opens
- [ ] All active constellations visible as nodes
- [ ] Library overlay appears
- [ ] Can move library panel anywhere
- [ ] Can minimize to tab at edge
- [ ] Can restore from tab
- [ ] Drag portal onto node → Assigns
- [ ] Tap constellation node → Detail window opens
- [ ] Detail window shows correct constellation
- [ ] Close detail → Returns to universe
- [ ] Visual web lines connect nodes
- [ ] Can rearrange nodes spatially

---

### Phase 9: Immersive Universe (11 hours) 🔮

**Goal:** Full immersive god-mode experience

**Status:** Future roadmap, build after Phases 2-8.5 complete and validated

**Features:**
- ImmersiveSpace (unbounded canvas, infinite)
- All constellations with full orb detail (not simplified)
- Hand tracking gestures (pinch, grab, pull)
- Spatial audio (positional for each orb)
- Particle effects (dramatic, high quality)
- Connection line creation with hands (draw in air)
- Two-hand gestures (optional, experimental)
- Reality Composer Pro integration (polished scenes)

**Why Separate:**
- High complexity (11 hours)
- Requires extensive device testing (can't fully simulate)
- May not be needed if Volume modes are sufficient
- Better as separate release/update after core validation
- Allows time for user feedback on Phases 2-8.5

**See:** PHASE_9_IMMERSIVE_VISION.md for full details

---

## Phase Summary Table

| Phase | Feature | Duration | Status | Deliverable |
|-------|---------|----------|--------|-------------|
| 1.2 | Foundation | - | ✅ Complete | Portal CRUD, Quick Start |
| 2 | Input Magic | 3h | ✅ Complete | Quick Paste/Add, Constellations, URL scheme |
| 3 | Embedded Windows | 2h | ⏸️ Experiment | Optional controlled windows |
| 4 | SwiftUI Orbs | 4h | 📋 Planned | Beautiful orb visualization |
| 5 | Beacon + Galaxy | 2h | 📋 Planned | Two primary modes |
| 6 | RealityKit Volume | 4h | 📋 Planned | 3D orb space |
| 7 | Constellations | 2h | 📋 Planned | Full constellation functionality |
| 8 | visionOS Polish | 2h | 📋 Planned | USDZ, folders, recent, search |
| 8.5 | Universe View | 4h | 📋 Planned | Strategic overview, library |
| 9 | Immersive | 11h | 🔮 Future | God-mode immersive experience |

**Core MVP:** 22 hours (Phases 2-8.5)  
**With Immersive:** 33 hours (includes Phase 9)

---

## Success Metrics

### MVP Complete (Phases 2-8.5)

- [ ] Drop any URL → Instant portal creation
- [ ] Constellation launches 5 portals in 2 seconds
- [ ] Orb mode feels spatial and magical
- [ ] Beacon, Galaxy, and Universe modes work seamlessly
- [ ] USDZ files have 3D previews
- [ ] Universe View provides strategic overview
- [ ] Library overlay is movable and functional
- [ ] Two-tier navigation (overview → detail) works smoothly
- [ ] No critical bugs
- [ ] Smooth 60fps performance
- [ ] Intuitive for new users

### Post-Launch Success Indicators

- Daily active usage (retention)
- Constellation usage rate (batch vs individual launches)
- Mode preference distribution (Beacon vs Galaxy vs Universe usage)
- Feature discovery rate (how many users find Universe View)
- Performance metrics (battery life, memory usage)
- User feedback sentiment (reviews, support requests)
- Portal count per user (adoption depth)
- Constellation count per user (power user indicator)

---

## File Structure

```
Waypoint/
├── Models/
│   ├── Portal.swift
│   ├── Constellation.swift
│   ├── PortalType.swift
│   ├── PortalManager.swift
│   └── ConstellationManager.swift
│
├── Views/
│   ├── Window/
│   │   ├── WaypointWindowView.swift
│   │   ├── PortalListView.swift
│   │   ├── PortalGridView.swift
│   │   └── SearchBar.swift
│   │
│   ├── Orbs/
│   │   ├── PortalOrb.swift
│   │   ├── ConstellationOrb.swift
│   │   ├── BeaconView.swift (vertical stack)
│   │   └── GalaxyView.swift (sphere formation)
│   │
│   ├── Universe/
│   │   ├── UniverseView.swift
│   │   ├── ConstellationNode.swift
│   │   ├── LibraryOverlay.swift
│   │   ├── PortalLibraryGrid.swift
│   │   └── ConnectionLines.swift
│   │
│   ├── Portals/
│   │   ├── PortalCard.swift
│   │   ├── AddPortalView.swift
│   │   ├── EditPortalView.swift
│   │   └── PortalContextMenu.swift
│   │
│   ├── Constellations/
│   │   ├── ConstellationCard.swift
│   │   ├── CreateConstellationView.swift
│   │   ├── EditConstellationView.swift
│   │   └── ConstellationExpandedView.swift
│   │
│   └── Settings/
│       └── WaypointSettings.swift
│
├── Services/
│   ├── FaviconService.swift
│   ├── NameExtractor.swift
│   ├── ColorExtractor.swift
│   ├── USDZThumbnailService.swift
│   └── FileStorageManager.swift
│
├── Components/
│   ├── DropZone.swift
│   ├── QuickStartView.swift
│   ├── EmptyStateView.swift
│   └── ToastNotification.swift
│
├── Entities/ (RealityKit)
│   ├── PortalOrbEntity.swift
│   ├── ConstellationNodeEntity.swift
│   └── ParticleEffects.swift
│
├── Extensions/
│   ├── URL+Extensions.swift
│   ├── Color+Extensions.swift
│   └── View+Extensions.swift
│
├── WaypointApp.swift
└── Assets.xcassets
```

---

## Key Technical Decisions

### Portal References vs Ownership

**Decision:** Portals exist independently, constellations reference them

**Why:**
- Same portal can be in multiple constellations
- Deleting constellation doesn't delete portals
- Simpler mental model (like database foreign keys)
- Standard software architecture pattern

**Implementation:**
```swift
// PortalManager is source of truth
@Observable
class PortalManager {
    var portals: [Portal] = []  // ALL portals live here
}

// Constellations only hold references
struct Constellation {
    var portalIDs: [UUID]  // References, not copies
}

// To get portals for a constellation:
func getPortals(for constellation: Constellation) -> [Portal] {
    portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
}
```

### Beacon Mode Cap at 8 Orbs

**Decision:** Max 8 orbs per page in Beacon mode

**Why:**
- Working memory limit (Miller's Law: 5-9 items optimal)
- Visual clarity (not overwhelming to scan)
- Forces intentionality (which portals truly matter?)
- Better performance (fewer entities to render)
- Feels focused (productivity mode should be lean)

**Alternatives:**
- Favorites mode: Auto-select favorited portals (max 8)
- Manual mode: User picks exactly 8
- All mode: Paginated (8 per page, swipe to see more)

### Universe View in Volume, Not Immersive

**Decision:** Build Universe View as volumetric window (Phase 8.5), save immersive for Phase 9

**Why:**
- Available sooner (before full Immersive Space work)
- User doesn't need to leave workspace
- Can reference other windows while organizing
- Less dramatic context switch
- Immersive saved for future enhancement (optional upgrade)
- Volume is "good enough" for strategic overview

### Two-Tier Navigation System

**Decision:** Universe View opens separate detail windows (Galaxy/Beacon)

**Why:**
- Universe stays simple (overview only, simplified nodes)
- Detail windows get full space (no cramming everything into one view)
- Two focused tools > one complex tool
- Natural hierarchy: Strategic (Universe) → Tactical (Galaxy/Beacon)
- Can work with multiple constellations (open multiple detail windows)
- Familiar pattern (file browser → file viewer)

### Favorites & Pinned as Filters

**Decision:** Favorites and Pinned are NOT constellations, just filtered views

**Why:**
- Conceptually simpler (filters vs additional collections)
- Can be toggled on/off in settings (hide if not used)
- Don't clutter constellation list
- Standard UI pattern (Gmail, Apple Mail, file browsers)
- Prevents confusion ("Is Favorites a constellation or not?")

### Remove vs Delete

**Decision:** Remove = back to library (safe), Delete = permanent (requires confirmation)

**Why:**
- Safe default (remove doesn't lose data, just un-assigns)
- Delete requires explicit confirmation ("Delete this portal permanently?")
- Clear distinction in UI (different context menu positions, colors)
- Matches user expectation (remove = un-link, delete = destroy)
- Prevents accidental data loss

**Implementation:**
```swift
// Remove portal from constellation
func removePortals(_ portalIDs: [UUID], from constellation: Constellation) {
    constellation.portalIDs.removeAll { portalIDs.contains($0) }
    // Portal still exists in PortalManager.portals
}

// Delete portal permanently
func delete(_ portal: Portal) {
    // Remove from ALL constellations first
    for constellation in constellations {
        constellation.portalIDs.removeAll { $0 == portal.id }
    }
    // Then delete from source of truth
    portals.removeAll { $0.id == portal.id }
}
```

---

## Risk Mitigation

### Technical Risks

**Risk:** RealityKit performance with many orbs  
**Mitigation:**
- Beacon caps at 8 per page (reduces entity count)
- Galaxy uses LOD (level of detail) if needed for 20+ orbs
- Simplified nodes in Universe View (not full orbs)
- Lazy rendering (only render visible items)

**Risk:** Universe View cramped in Volume window  
**Mitigation:**
- Simplified constellation nodes (not full orb detail)
- Movable library overlay (can position anywhere)
- Can minimize library to tab (frees up space)
- Two-tier navigation (detail work in separate window)

**Risk:** Two-tier navigation feels disjointed  
**Mitigation:**
- Smooth window transitions
- Clear visual connection (tap node → opens detail)
- Can keep Universe View open while working in detail
- Familiar pattern (users understand "overview → detail")

### UX Risks

**Risk:** Too many modes confuses users  
**Mitigation:**
- Default to simplest (Window mode list view)
- Progressive disclosure (modes introduced gradually)
- Clear mode names and icons
- Onboarding tutorial explains each mode

**Risk:** Universe View overwhelming on first use  
**Mitigation:**
- Onboarding tutorial for Universe View
- Clear visual hierarchy (nodes + library)
- Starts with only active constellations (hidden ones don't appear)
- Library defaults to Favorites tab (smaller set)

**Risk:** Library overlay obstructs constellation view  
**Mitigation:**
- Movable (drag anywhere)
- Can minimize to tab (collapses to icon)
- Can close entirely (button or swipe off)
- Transparent background (see through it)

### Scope Risks

**Risk:** Feature creep delays launch  
**Mitigation:**
- Strict phase ordering (must complete in sequence)
- Phase 9 explicitly separate (not blocking launch)
- Each phase has clear deliverables and time estimates
- Scope changes require explicit decision and re-planning

**Risk:** Phase 8.5 complexity  
**Mitigation:**
- Well-scoped (4 hours, clear sub-phases)
- Uses existing patterns (volumetric window, orb components)
- Two-tier navigation keeps it simple (overview only)
- Can be tested independently of other phases

---

## Conclusion

Waypoint v3.0 Foundation incorporates Universe View as a core strategic feature, providing users with god-mode overview and organization capabilities while maintaining the focused Beacon and Galaxy modes for daily productivity.

**Key Additions in v3.0:**
- Phase 8.5: Universe View (strategic overview)
- Two-tier navigation system (overview → detail)
- Movable library overlay (drag anywhere, minimize to tab)
- Portal reference architecture (not ownership)
- Favorites/Pinned as filters (not constellations)
- Clear remove vs delete distinction

**Build Order:**
1. Phases 2-8: Core app (19 hours)
2. Phase 8.5: Universe View (4 hours)
3. Test and validate both volume modes work well
4. Phase 9: Immersive (if valuable, 11 hours, future)

**The vision is comprehensive. The plan is executable. Ready to build.** ✨

---

**End of Foundation Document v3.0**

*This document supersedes WAYPOINT_FOUNDATION_V2.md*  
*Last updated: December 29, 2024*
