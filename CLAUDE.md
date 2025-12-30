# Waypoint Project Context

**Project:** Waypoint - Universal Link Manager for visionOS  
**Version:** 3.0  
**Status:** Phase 2 Complete → Ready for Phase 3
**Last Updated:** December 29, 2024

---

## Quick Context for Claude

This is a **visionOS spatial computing app** that transforms link management from flat lists into a 3D spatial experience with strategic universe-level organization.

**Core Promise:** "2 seconds to anywhere" - instant access to your digital universe.

**Current State:** Phase 2 complete (stable at commit 0e46db9). Ready to build Phase 3.

---

## Critical Architecture Update (V3)

**Major Change:** Universe View is now a core feature (Phase 8.5), not part of distant Immersive mode.

**What This Means:**
- Strategic overview available in Volume window (bounded space)
- Two-tier navigation: Universe (overview) → Detail windows (Galaxy/Beacon)
- Movable library overlay for portal assignment
- Builds on top of Beacon + Galaxy modes
- More accessible than full immersive experience

---

## Project Structure

### Primary Documents (READ THESE)

1. **WAYPOINT_FOUNDATION_V3.md** ← **START HERE** (Updated!)
   - Complete architecture with Universe View
   - Three primary modes: Beacon, Galaxy, Universe
   - Portal reference architecture (not ownership)
   - Technical feasibility analysis
   - Updated 9-phase build plan (8.5 hours added)

2. **WAYPOINT_TECHNICAL_SPEC.md** ← **For Implementation**
   - Code patterns and examples
   - Data models with full implementations
   - API usage patterns
   - Performance considerations

3. **PROJECT_STATUS_V2.md** ← **Current State**
   - Phase completion status
   - Testing checklists
   - Known issues
   - Git workflow

4. **EXECUTIVE_SUMMARY.md** ← **Quick Reference**
   - Vision in 30 seconds
   - Key features
   - Build timeline

### Deprecated Documents (DO NOT USE)

- `WAYPOINT_FOUNDATION.md` (v1.0 - superseded)
- `WAYPOINT_FOUNDATION_V2.md` (v2.0 - superseded by v3.0)
- `WAYPOINT_DESIGN_VISION.md` (optional reference only)
- `PROJECT_STATUS.md` (v1.0 - superseded)

### Code Style

- `SKILL.md` - Development principles and patterns

---

## Key Architectural Decisions (V3)

### What We're Building ✅

1. **Three Primary Interface Modes:**
   - **Beacon Mode** - Vertical stack, 8 orbs max per page, productivity-focused
   - **Galaxy Mode** - 3D sphere formation, all portals visible, exploration
   - **Universe View** - Strategic overview, all constellations, portal library
   - ~~Immersive (Phase 9, future FFX/Skyrim-style)~~

2. **Portal Reference Architecture:**
   - Portals exist independently in PortalManager
   - Constellations reference portals by UUID (like foreign keys)
   - Same portal can be in multiple constellations
   - Removing from constellation ≠ deleting portal
   - Delete requires explicit confirmation

3. **Universe View (New in V3):**
   - Volumetric window (~1.3m × 1.0m × 0.5m)
   - Simplified constellation nodes (not full orb detail)
   - Movable library overlay (drag anywhere, minimize to tab)
   - Portal assignment via drag & drop
   - Two-tier navigation (tap node → opens detail window)

4. **Orb Visualization System:**
   - SwiftUI orbs with glass effects (Phase 4)
   - RealityKit 3D orbs for Galaxy/Volume modes (Phase 6)
   - Three glow modes: app type, icon color, constellation color
   - Scatter/gather animations (Dragon Ball-style)

5. **Input Methods:**
   - Universal drag & drop (all file types)
   - Clipboard detection (auto-prompt on copy)
   - URL scheme (waypoint://add?url=...)
   - Manual creation form

6. **Constellation Workflows:**
   - Batch launch multiple portals
   - Staggered timing (0.05-0.5s delays, user configurable)
   - Opens in native apps (Safari default)
   - Optional embedded windows (Phase 3 experiment)

7. **visionOS-Native:**
   - USDZ 3D file support (RealityKit thumbnails)
   - Folder portals with nested contents
   - Spatial window positioning hints
   - Look + pinch interactions

### What We're NOT Building ❌

1. **Share Extension** - iOS paradigm, causes RealityKit issues
2. **Safari tab control** - Sandboxing prevents, accepted limitation
3. **Context-aware auto-launch** - Premature optimization
4. **Portal marketplace** - Need user base first
5. **Multi-device sync** - visionOS-first focus (for now)

### Key Terminology Changes (V3)

- ~~"Window Mode"~~ → Standard list view (not a special mode)
- ~~"Hybrid Mode"~~ → Removed (complexity not worth it)
- ~~"Tower Mode"~~ → **Beacon Mode** (vertical stack)
- **Galaxy Mode** - 3D sphere formation (unchanged)
- **Universe View** - Strategic overview (new, Phase 8.5)

---

## Current Phase: Phase 3 (Embedded Windows - Optional)

**Next Up:** Phase 3 - Embedded Browser Test (2h)

**Phase 2 Complete - What Was Built:**
- Quick Paste: One-tap portal creation from clipboard
- Quick Add: Type URL/site name (auto-adds https://www/.com)
- Manual drag reordering with Custom sort option
- Constellation system (models, manager, create view)
- Context menu "Add to Constellation" submenu
- Constellation filters in filter menu
- Constellation icons on portal rows
- URL scheme (waypoint://add, open, launch)
- Paste button in form with auto-fill
- Removed Favorites (replaced by Constellations)

**visionOS Limitation Discovered:** Safari drag & drop doesn't work reliably on visionOS. Solved with Quick Paste/Quick Add buttons instead.

**Reference:** WAYPOINT_TECHNICAL_SPEC.md > Phase 3 for implementation details

---

## Data Models (Quick Reference)

### Portal
```swift
struct Portal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String
    var type: PortalType  // web, file, usdz, folder, icloud, app
    var thumbnailData: Data?
    var isPinned: Bool
    var sortIndex: Int
    var dateAdded: Date
    var lastOpened: Date?
    var preferEmbedded: Bool
}
```

**Key Point:** Each portal has unique URL. Different playlists = different portals.

### Constellation
```swift
struct Constellation: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var portalIDs: [UUID]  // References, NOT ownership
    var icon: String
    var color: Color
    var dateCreated: Date
    var isActive: Bool  // Show/hide toggle
    var universePosition: CGPoint?  // For Universe View
    var beaconMode: BeaconDisplayMode  // favorites, manual, all
}
```

**Critical:** Constellations reference portals, don't own them. Deleting constellation doesn't delete portals.

### Beacon Display Mode
```swift
enum BeaconDisplayMode: String, Codable {
    case favorites  // Show favorited portals (max 8)
    case manual     // User-selected 8 portals
    case all        // All portals (paginated, 8 per page)
}
```

---

## Interface Modes Summary

| Mode | Use Case | Window Type | Portal Cap | Details |
|------|----------|-------------|------------|---------|
| **Beacon** | Quick access | Volume | 8 per page | Vertical stack, productivity |
| **Galaxy** | Exploration | Volume | No cap | 3D sphere, Fibonacci distribution |
| **Universe** | Organization | Volume | Library (scrollable) | Strategic overview, all constellations |
| **Immersive** | God mode | ImmersiveSpace | No cap | Phase 9, future |

### Beacon Mode Details
- Vertical stack (100px wide × ~800px tall)
- 8 orbs per page maximum
- 3 selection modes: Favorites (default), Manual, All (paginated)
- Swipe LEFT/RIGHT: Change constellation
- Swipe UP/DOWN: Change page (All mode only)
- Look + pinch: Launch portal

### Galaxy Mode Details
- 3D sphere formation (Fibonacci distribution)
- Radius: ~0.3m from center orb
- Look at center + pinch: Launch all
- Look at orb + pinch: Launch that portal
- Scatter/gather animations

### Universe View Details (New in V3)
- Volumetric window (~1.3m × 1.0m × 0.5m)
- Simplified constellation nodes (spheres with glow, not full detail)
- Movable library overlay (drag anywhere, minimize to tab)
- Two-tier navigation: Tap node → Opens detail window (Galaxy/Beacon)
- Portal assignment: Drag from library → onto constellation node

---

## Build Plan Overview (Updated for V3)

**Total Core Development:** 22 hours (Phases 2-8.5)  
**With Immersive:** 33 hours (includes Phase 9)

| Phase | Feature | Duration | Status |
|-------|---------|----------|--------|
| 1.2 | Foundation | - | ✅ Complete |
| 2 | Input Magic | 3h | ✅ Complete |
| 3 | Embedded Windows | 2h | ⏸️ Test |
| 4 | SwiftUI Orbs | 4h | 📋 Planned |
| 5 | Beacon + Galaxy | 2h | 📋 Planned |
| 6 | RealityKit Volume | 4h | 📋 Planned |
| 7 | Constellations | 2h | 📋 Planned |
| 8 | visionOS Polish | 2h | 📋 Planned |
| **8.5** | **Universe View** | **4h** | **📋 New** |
| 9 | Immersive Mgmt | 11h | 🔮 Future |

**Phase 8.5 is NEW** - Added after architecture refinement. Builds on Phases 4-6 orb work.

---

## Code Organization Principles

### Section Markers (ALWAYS USE)
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - UI Components
// MARK: - Event Handlers
// MARK: - Computed Properties
```

### Portal Reference Pattern
```swift
// ✅ CORRECT: Reference by UUID
struct Constellation {
    var portalIDs: [UUID]  // Just IDs
}

func getPortals(for constellation: Constellation) -> [Portal] {
    portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
}

// ❌ WRONG: Don't store Portal objects
struct Constellation {
    var portals: [Portal]  // NO! This is ownership
}
```

### Remove vs Delete Pattern
```swift
// Remove from constellation (portal stays in library)
func removePortals(_ portalIDs: [UUID], from constellation: Constellation) {
    constellation.portalIDs.removeAll { portalIDs.contains($0) }
    save()
}

// Delete permanently (requires confirmation)
func delete(_ portal: Portal) {
    // Remove from ALL constellations first
    for constellation in constellations {
        constellation.portalIDs.removeAll { $0 == portal.id }
    }
    // Then delete from source of truth
    portals.removeAll { $0.id == portal.id }
    save()
}
```

---

## Tech Stack
```swift
import SwiftUI              // UI framework
import RealityKit           // 3D graphics
import Observation          // @Observable pattern
import WebKit               // Embedded browser (Phase 3, optional)
import UniformTypeIdentifiers  // File type detection
```

**Requirements:**
- visionOS 2.0+
- Swift 5.9+
- Xcode 16.0+

---

## Starting a New Session

### What Claude Should Do:

1. **Read WAYPOINT_FOUNDATION_V3.md** (if needed for context)
2. **Reference WAYPOINT_TECHNICAL_SPEC.md** for implementation patterns
3. **Check PROJECT_STATUS_V2.md** for current phase details
4. **Use SKILL.md** for code style principles

### What User Will Say:
```
"Starting Phase [X]: [Feature Name]"
```

or
```
"Continue with Phase [X]"
```

or
```
"Ready to build [specific feature]"
```

### Claude's First Response Pattern:
```
Understood. Building Phase [X]: [Feature Name]

Current context:
- Previous phase: [X] complete
- Building: [specific features]
- Reference: [relevant doc sections]
- Estimated time: [X] minutes

Starting with [first subtask]...
```

---

## Important Reminders for Claude

### Design Philosophy
- **Simplicity first** - One great way > three mediocre options
- **Respect native apps** - Safari is excellent, use it as default
- **Spatial computing first** - Leverage visionOS unique capabilities
- **Progressive enhancement** - Beacon → Galaxy → Universe
- **Portal references, not ownership** - Constellations reference portals by UUID

### Technical Constraints
- **Cannot set exact window coordinates** (visionOS API limitation)
- **Cannot force Safari to open new windows** (Safari controls behavior)
- **Cannot extract Safari tabs** (sandboxing)
- **Share Extension breaks RealityKit** (skip entirely)

### Async Patterns (Non-Blocking)
```swift
// ✅ GOOD: Non-blocking
func addPortal(url: URL) {
    let portal = Portal(name: url.extractSmartName(), url: url)
    portalManager.add(portal)
    
    Task {
        if let favicon = await FaviconService.fetch(for: url) {
            portal.thumbnailData = favicon
            portalManager.update(portal)
        }
    }
}

// ❌ BAD: Blocks UI
func addPortal(url: URL) {
    let favicon = fetchFavicon(url)  // Blocks!
    let portal = Portal(name: name, url: url, thumbnailData: favicon)
}
```

### Universe View Key Concepts
- **Simplified nodes** - Not full orb detail, just sphere + glow + label
- **Two-tier navigation** - Overview (Universe) → Detail (Galaxy/Beacon)
- **Movable library** - Drag anywhere, minimize to tab, close entirely
- **Portal assignment** - Drag from library onto constellation node
- **Volume window** - Bounded space (~1.3m × 1.0m), not immersive

---

## Success Criteria for MVP (Updated)

- [ ] Drop any link → Instant portal creation
- [ ] Constellation launches 5 portals in 2 seconds
- [ ] Beacon mode feels focused and productive
- [ ] Galaxy mode feels spatial and explorable
- [ ] Universe View provides strategic overview
- [ ] Library overlay is movable and functional
- [ ] Two-tier navigation works smoothly (tap node → detail window)
- [ ] USDZ files have 3D previews
- [ ] 60fps performance maintained
- [ ] Intuitive for new users
- [ ] No critical bugs

---

## Git Workflow
```bash
# Current stable commit
git log --oneline -n 1
# Should show: 52b792a

# Create feature branch for phase
git checkout -b feature/phase-2-input

# After completion
git add .
git commit -m "Phase 2A: Universal drag & drop complete"
git checkout main
git merge feature/phase-2-input
git push origin main
```

---

## Testing Strategy

**Test after each phase:**
- Manual testing against checklist (in PROJECT_STATUS_V2.md)
- Performance monitoring (60fps target)
- Memory usage (target <500MB for 100 portals)
- User flow validation

**Critical test scenarios:**
- Drop 1 URL
- Drop 10 files
- Drop USDZ
- Drop folder
- Launch 5-portal constellation
- Switch between Beacon/Galaxy modes
- Open Universe View
- Move library overlay
- Assign portal from library to constellation
- Tap constellation node → detail window opens
- App restart persistence

---

## Common Questions

### Q: "Should I build the Share Extension?"
**A:** No. It's explicitly removed from scope. Use drag & drop + clipboard + URL scheme instead.

### Q: "Can I control Safari tab behavior?"
**A:** No. Safari controls its own windowing. Use staggered launch timing + optional embedded windows.

### Q: "What's the difference between Beacon and Galaxy modes?"
**A:** Beacon is vertical stack (8 max, productivity). Galaxy is 3D sphere (all portals, exploration).

### Q: "What's Universe View vs Immersive mode?"
**A:** Universe View is volumetric window (Phase 8.5, bounded space, strategic overview). Immersive is Phase 9 (unbounded space, full god-mode, future).

### Q: "How do constellation references work?"
**A:** Constellations store portal UUIDs, not portal objects. Think database foreign keys. Same portal can be in multiple constellations.

### Q: "Should I start Phase 9 (Immersive)?"
**A:** No. Only after Phases 2-8.5 complete and user validated. It's explicitly a future phase.

### Q: "What if I find a better way to implement something?"
**A:** Great! Document the change and reasoning. Update relevant docs. Architecture is solid but implementation can improve.

---

## Phase 8.5: Universe View (New Feature)

**Goal:** Strategic overview and high-level organization

**Key Components:**
1. Volumetric window (~1.3m × 1.0m × 0.5m)
2. Simplified constellation nodes (sphere + glow + label)
3. Visual web (lines connecting nodes, aesthetic)
4. Movable library overlay (portal grid with tabs)
5. Portal assignment (drag from library onto node)
6. Two-tier navigation (tap node → opens detail window)

**Why Added:**
- Provides god-mode overview without full immersive
- Available sooner (before Phase 9)
- Users can organize while staying in workspace
- Natural hierarchy: Strategic (Universe) → Tactical (Beacon/Galaxy)

**Reference:** WAYPOINT_FOUNDATION_V3.md > Interface Modes > Level 3

---

## Resources

- **Repository:** https://github.com/UnshackledPursuit/Waypoint
- **Bundle ID:** Unshackled-Pursuit.Waypoint
- **App Group:** group.Unshackled-Pursuit.Waypoint
- **Current Commit:** 0e46db9 (Phase 2 complete)

---

## This Session's Goal

**Phase 3: Embedded Windows (Optional Test)**

Test if embedded WebView windows provide value over Safari.

Reference WAYPOINT_TECHNICAL_SPEC.md > Phase 3 for detailed implementation.

---

## V3 Architecture Summary

**What Changed from V2:**
- Added Phase 8.5: Universe View (4 hours)
- Renamed "Tower" to "Beacon" (clarity)
- Removed "Hybrid Mode" (unnecessary complexity)
- Portal reference architecture explicitly defined
- Two-tier navigation system (overview → detail)
- Movable library overlay (drag anywhere, minimize to tab)
- Favorites/Pinned are filters, not constellations
- Remove vs Delete distinction clarified

**Total Build Time:**
- Core MVP: 22 hours (Phases 2-8.5)
- With Immersive: 33 hours (includes Phase 9)

**Build Order:**
1. Phases 2-8: Core features (18 hours)
2. Phase 8.5: Universe View (4 hours)
3. Test and validate
4. Phase 9: Immersive (if valuable, 11 hours, future)

---

**Claude: You're ready to build. Foundation V3 is the source of truth. Start when the user says "go".** 🚀
