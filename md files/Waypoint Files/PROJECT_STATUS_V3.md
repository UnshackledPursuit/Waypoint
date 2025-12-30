# Waypoint - Project Status v3.0

**Last Updated:** December 29, 2024  
**GitHub:** https://github.com/UnshackledPursuit/Waypoint  
**Current Phase:** Phase 2 Complete ✅
**Architecture Version:** V3
**Next Phase:** Phase 3 (Embedded Windows - Optional)

---

## Quick Reference

**Bundle ID:** `Unshackled-Pursuit.Waypoint`  
**App Group:** `group.Unshackled-Pursuit.Waypoint`  
**visionOS Target:** 2.0+  
**Swift Version:** 5.9+  
**Current Commit:** 0e46db9 (Phase 2 complete)

---

## Current State

### ✅ Phase 1.2: Complete and Stable

**What's Actually Built:**
- Portal CRUD (Create, Read, Update, Delete)
- Pin/Favorite system (filters, not collections)
- Sorting & filtering
- Quick Start collections (15 portals in 3 groups: AI, Pulse, Launchpad)
- Auto-https URL completion
- Context menus
- 3-column onboarding layout
- Clean architecture with section markers
- Stable persistence

**Architecture Note:**
- Built under V2 architecture concepts
- V3 refinements are **documentation updates** for future phases
- Phase 1.2 code is solid foundation - continue building from here

**Commit:** 52b792a  
**Status:** Production-ready foundation  
**Decision:** Continue building from this point (no rebuild needed)

---

## V3 Architecture Summary

**Key Changes from V2:**
- Renamed "Tower Mode" → **Beacon Mode** (vertical stack)
- Removed "Hybrid Mode" (unnecessary complexity)
- Added **Phase 8.5: Universe View** (strategic overview, 4 hours)
- **Portal Reference Architecture** explicitly defined (constellations reference portals by UUID, don't own them)
- Clarified **Favorites/Pinned as filters** (not constellations)
- **Phase 9: Immersive** moved to separate future vision

**Three Primary Modes:**
1. **Beacon Mode** - Vertical stack, 8 orbs max per page, productivity focus
2. **Galaxy Mode** - 3D sphere formation, all portals visible, exploration
3. **Universe View** - Strategic overview, movable library, portal assignment

**Core MVP:** 22 hours (Phases 2-8.5)  
**Future:** Phase 9 Immersive (11 hours, separate vision doc)

---

## Build Schedule Overview

### Phase Status Table

| Phase | Feature | Duration | Status | Priority |
|-------|---------|----------|--------|----------|
| 1.2 | Foundation | - | ✅ Complete | - |
| 2 | Input Magic | 3h | ✅ Complete | - |
| 3 | Embedded Windows | 2h | ⏸️ Experiment | Medium |
| 4 | SwiftUI Orbs | 4h | 📋 Planned | Critical |
| 5 | Beacon + Galaxy | 2h | 📋 Planned | Critical |
| 6 | RealityKit Volume | 4h | 📋 Planned | High |
| 7 | Constellations | 2h | 📋 Planned | Critical |
| 8 | visionOS Polish | 2h | 📋 Planned | High |
| 8.5 | Universe View | 4h | 📋 Planned | High |
| 9 | Immersive | 11h | 🔮 Future | Low |

**Legend:**
- ✅ Complete
- 🔜 Next up
- ⏸️ Test & evaluate
- 📋 Planned
- 🔮 Future roadmap (separate doc)

**Total Core Development:** 22 hours (Phases 2-8.5)

---

## Phase 2: Input Magic ✅ Complete

**Commit:** 0e46db9

### What Was Built:
- [x] Quick Paste: One-tap portal creation from clipboard
- [x] Quick Add: Type URL/site name (auto-adds https://www/.com)
- [x] Manual drag reordering with Custom sort option
- [x] Constellation system (Constellation.swift, ConstellationManager.swift)
- [x] CreateConstellationView for new constellations
- [x] Context menu "Add to Constellation" submenu
- [x] Constellation filters in filter menu
- [x] Constellation icons on portal rows (up to 3, +N for more)
- [x] URL scheme (waypoint://add, open, launch)
- [x] Paste button in AddPortalView with auto-fill
- [x] DropService.swift for smart name extraction
- [x] Removed Favorites (replaced by Constellations)

### visionOS Limitation Discovered:
Safari drag & drop doesn't work reliably on visionOS. **Solution:** Quick Paste/Quick Add toolbar buttons work perfectly.

### Testing Results:
- [x] Quick Paste creates portal instantly
- [x] Quick Add works with bare names ("youtube" → youtube.com)
- [x] Drag to reorder works with Custom sort
- [x] Constellation creation works
- [x] Add to Constellation context menu works
- [x] Filter by constellation works
- [x] waypoint://add?url=... works from Shortcuts

---

## Detailed Phase Status

### Phase 3: Embedded Windows (2 hours) ⏸️

**Goal:** Test controlled window creation  
**Status:** Experiment - build, test, decide to keep or remove

**Features:**
- [ ] WindowGroup for embedded browser
- [ ] WKWebView integration
- [ ] Toolbar with "Open in Safari" button
- [ ] Per-portal preference
- [ ] Constellation launch integration

**Decision Point After Phase 3:**
- [ ] Test with 5-portal constellation
- [ ] Compare: Embedded vs Safari experience
- [ ] User feedback (if available)
- [ ] **Decide:** Keep, refine, or remove

**If removed:** Revert code, update Phase 7 to use native-only launching

---

### Phase 4: SwiftUI Orbs (4 hours)

**Goal:** Beautiful spatial orb visualization

**Features:**
- [ ] PortalOrb component (glass sphere, glow, icon)
- [ ] ConstellationOrb component (larger, distinct)
- [ ] Color extraction from favicon
- [ ] 3 glow modes (App Type, Icon Color, Constellation)
- [ ] Expand/collapse animation (radial fan-out)
- [ ] Settings picker for glow mode

**Testing Criteria:**
- Single orb renders beautifully
- All 3 glow modes work
- Expand animation is smooth
- Collapse brings orbs back
- Tap orb → Opens portal

---

### Phase 5: Beacon + Galaxy Modes (2 hours)

**Goal:** Two primary interface modes with seamless switching

**Features:**
- [ ] Beacon Mode (vertical stack, 8 orbs per page)
- [ ] Portal selection system (3 modes: Favorites, Manual, All)
- [ ] Constellation swipe switching (horizontal)
- [ ] Page swipe (vertical, All mode only)
- [ ] Galaxy Mode (volumetric, 3D sphere)
- [ ] Look + pinch interactions
- [ ] Mode toggle button

**Testing Criteria:**
- Beacon shows 8 orbs vertically
- Swipe left/right changes constellation
- Swipe up/down changes page (All mode only)
- Galaxy shows orbs in sphere
- Mode toggle works smoothly
- Preference persists after restart

---

### Phase 6: RealityKit Volume (4 hours)

**Goal:** 3D interactive orb space

**Features:**
- [ ] Volumetric window setup
- [ ] PortalOrbEntity (RealityKit)
- [ ] Scatter/gather animations
- [ ] Look + pinch launch (individual)
- [ ] Look at center + pinch launch (all)
- [ ] Context menu (long pinch)
- [ ] Particle effects

**Testing Criteria:**
- Volume window appears
- Orbs render as 3D spheres
- Scatter animation is dramatic
- Gather brings them back
- Look + pinch launches portal
- 60fps performance

---

### Phase 7: Constellations (2 hours)

**Goal:** Complete constellation functionality

**Features:**
- [ ] ConstellationManager implementation
- [ ] Create from multi-select
- [ ] Staggered launch (0.05-0.5s delays)
- [ ] Edit (add/remove portals via references)
- [ ] Icon & color picker
- [ ] Drag portals into/out of constellation
- [ ] Delete with confirmation (portals remain)

**Testing Criteria:**
- Create constellation with 5 portals
- Launch → All open with delays
- Edit: Add 2, remove 1
- Change icon and color
- Delete constellation (portals persist)

---

### Phase 8: visionOS Polish (2 hours)

**Goal:** Native visionOS features and feel

**Features:**
- [ ] USDZ support (RealityKit thumbnails)
- [ ] Folder portals (nested contents)
- [ ] Recent section (last 10 opened)
- [ ] Search & filter UI
- [ ] Animations polish
- [ ] Error handling
- [ ] Accessibility

**Testing Criteria:**
- Drop USDZ → 3D thumbnail generates
- Tap USDZ → Quick Look preview
- Drop folder → Shows contents
- Recent section updates on open
- Search filters instantly

---

### Phase 8.5: Universe View (4 hours) 🆕

**Goal:** Strategic overview and high-level organization

**Features:**
- [ ] Universe View volumetric window (~1.3m × 1.0m × 0.5m)
- [ ] Simplified constellation nodes (sphere + glow + label)
- [ ] Visual web (lines connecting nodes)
- [ ] Movable library overlay (drag anywhere, minimize to tab)
- [ ] Portal assignment (drag from library onto node)
- [ ] Two-tier navigation (tap node → opens detail window)

**Testing Criteria:**
- Universe View opens
- All active constellations visible as nodes
- Library overlay appears
- Can move library panel anywhere
- Can minimize to tab at edge
- Can restore from tab
- Drag portal onto node → Assigns
- Tap constellation node → Detail window opens
- Detail window shows correct constellation
- Close detail → Returns to universe

---

### Phase 9: Immersive Management (Future - 11 hours)

**Goal:** FFX/Skyrim-style constellation organization in immersive space

**Status:** Do not start until Phases 2-8.5 complete and validated

**See:** PHASE_9_IMMERSIVE_VISION.md for full details

**Decision Point:**
- Wait for user feedback on Phases 2-8.5
- Assess if this adds value
- Evaluate technical complexity
- Consider as separate update/release

---

## What We're NOT Building

### ❌ Share Extension
**Reason:** 4 failed attempts, breaks RealityKit, iOS paradigm not visionOS-native

**Alternative:** Drag & drop + clipboard detection + URL scheme (superior)

### ❌ Safari Tab Control
**Reason:** Sandboxing prevents external apps from manipulating Safari

**Alternative:** Staggered launch + optional embedded windows

### ❌ Context-Aware Auto-Launch
**Reason:** Premature optimization, needs usage data first

**Alternative:** Manual constellation launching (simpler, more predictable)

### ❌ Portal Sharing/Marketplace
**Reason:** Need user base first

**Alternative:** Quick Start collections (covers initial need)

### ❌ Multi-Device Sync (For Now)
**Reason:** visionOS-first focus

**Alternative:** Can add later if expanding platforms

---

## Known Issues & Limitations

### Technical Limitations (System)
- **Cannot set exact window coordinates** (visionOS API limitation)
- **Cannot force Safari to open new windows** (Safari controls behavior)
- **Cannot extract Safari tabs** (sandboxing)

**Workarounds in place:**
- Use window placement hints
- Staggered launch for better separation
- Embedded windows for full control (Phase 3, optional)

### Phase 3 Decision Pending
- Embedded windows need user testing
- May remove if Safari is sufficient
- Don't block on this - continue to Phase 4

---

## Git Workflow

### Current Branch Strategy
```bash
main (production, stable at 0e46db9 - Phase 2 complete)
└── feature/phase-3-embedded (next, if desired)
```

### Before Starting Phase 3
```bash
# Confirm you're on stable commit
git log --oneline -n 5

# Should see 52b792a

# Create feature branch
git checkout -b feature/phase-2-input
```

### Commit Template
```bash
git commit -m "Phase 2A: Universal drag & drop

- Add drop destination with multi-item support
- Implement file type detection
- Add visual feedback overlay
- Integrate auto-fill (name + favicon)

Tested: Drop URLs, files, USDZ, folders all work"
```

### After Completing Each Phase
```bash
# Commit working code
git add .
git commit -m "Phase X: Feature complete"

# Merge to main
git checkout main
git merge feature/phase-2-input

# Tag major milestones
git tag -a v0.2.0 -m "Phase 2: Input Magic complete"

# Push
git push origin main --tags
```

---

## Testing Checklist

### Phase 2 (Input Magic) ✅
- [x] Quick Paste creates portal from clipboard
- [x] Quick Add works with bare names
- [x] Drag portal to reorder → Persists (Custom sort)
- [x] Constellation system complete
- [x] Add to Constellation context menu works
- [x] Filter by constellation works
- [x] waypoint:// URL scheme works

### Phase 3 (Embedded Windows)
- [ ] Single portal in embedded window
- [ ] Constellation → 5 embedded windows
- [ ] "Open in Safari" button works
- [ ] Window sizing correct
- [ ] Compare: Embedded vs Safari feel
- [ ] **Decide:** Keep or remove

### Phase 4 (SwiftUI Orbs)
- [ ] Portal orb renders correctly
- [ ] Constellation orb is larger
- [ ] All 3 glow modes work
- [ ] Expand shows radial fan-out
- [ ] Collapse brings orbs back
- [ ] Tap orb opens portal
- [ ] Animations are smooth

### Phase 5 (Beacon + Galaxy)
- [ ] Beacon shows 8 orbs vertically
- [ ] Swipe left/right changes constellation
- [ ] Swipe up/down changes page (All mode only)
- [ ] Galaxy shows orbs in sphere
- [ ] Mode toggle works
- [ ] Preference persists

### Phase 6 (RealityKit Volume)
- [ ] Volumetric window appears
- [ ] Orbs render as 3D spheres
- [ ] Scatter animation dramatic
- [ ] Gather animation smooth
- [ ] Individual orb draggable
- [ ] 60fps performance

### Phase 7 (Constellations)
- [ ] Create from 5 selected portals
- [ ] Edit: Add portals
- [ ] Edit: Remove portals
- [ ] Launch: All open with delays
- [ ] Icon & color picker works
- [ ] Delete constellation (portals remain)

### Phase 8 (Polish)
- [ ] USDZ thumbnail generates
- [ ] USDZ Quick Look preview
- [ ] Folder contents display
- [ ] Recent section updates
- [ ] Search filters work
- [ ] All animations smooth
- [ ] No critical bugs

### Phase 8.5 (Universe View)
- [ ] Universe View opens
- [ ] All active constellations visible
- [ ] Library overlay movable
- [ ] Can minimize/restore library
- [ ] Portal assignment works
- [ ] Two-tier navigation works
- [ ] Visual web connects nodes
- [ ] Can rearrange nodes

---

## Performance Metrics

### Target Performance
- **UI responsiveness:** 60fps at all times
- **Drop response:** <100ms to create portal
- **Favicon fetch:** Non-blocking, <3s timeout
- **USDZ thumbnail:** Background, <5s generation
- **Constellation launch:** 0.3s between portals (default)
- **Orb scatter:** Smooth spring animation
- **Search:** Real-time, no lag

### Memory Usage
- **Portal storage:** ~50KB per portal (with favicon)
- **USDZ thumbnail:** ~200KB per 3D model
- **RealityKit orbs:** Monitor with 20+ orbs
- **Target:** <500MB total for 100 portals

---

## Documentation Status

### ✅ Complete and Current
- [x] WAYPOINT_FOUNDATION_V3.md (core architecture)
- [x] WAYPOINT_TECHNICAL_SPEC_V3.md (implementation details)
- [x] PROJECT_STATUS_V3.md (this file)
- [x] CLAUDE.md (session context)
- [x] PHASE_9_IMMERSIVE_VISION.md (future roadmap)
- [x] SKILL.md (code development principles)
- [x] README.md (project overview)

### 📝 Reference Only
- [ ] WAYPOINT_DESIGN_VISION.md (Phase 7+ polish ideas)
- [ ] Waypoint-Marketing-Strategy.md (post-launch)
- [ ] EXECUTIVE_SUMMARY.md (overview)

---

## Next Session Plan

**When starting Phase 3 (or skipping to Phase 4):**

1. **Review documents:**
   - WAYPOINT_FOUNDATION_V3.md
   - PROJECT_STATUS_V3.md (this file)

2. **Confirm current state:**
   ```bash
   git status
   git log --oneline -n 5
   # Should show 0e46db9 as recent commit
   ```

3. **Decision: Phase 3 or skip to Phase 4?**
   - Phase 3 (Embedded Windows) is optional experiment
   - Can skip directly to Phase 4 (SwiftUI Orbs) if preferred

4. **Message to start:**
   ```
   Ready to build Phase [3 or 4].

   Current state: Phase 2 complete at 0e46db9
   Reference: WAYPOINT_FOUNDATION_V3.md
   ```

---

## Communication Patterns

### Starting a Phase
"Starting Phase [X]: [Feature Name]"

### Asking for Clarification
"Question about [specific feature]: [clear question]"

### Reporting Completion
"Phase [X] complete. Testing shows: [results]. Ready for Phase [Y]."

### Reporting Issues
"Issue in Phase [X]: [problem description]. Proposed solution: [approach]."

### Requesting Review
"Phase [X] implementation ready for review. Key files: [list]."

---

## Success Criteria

### MVP Success (Phases 2-8.5 Complete)
- [ ] Can create portals via drag & drop
- [ ] Constellations launch with staggered delays
- [ ] Orb visualization works in Beacon and Galaxy modes
- [ ] Universe View provides strategic overview
- [ ] USDZ files have 3D previews
- [ ] All three interface modes functional
- [ ] Search and organization tools work
- [ ] Performance is smooth (60fps)
- [ ] No critical bugs
- [ ] Ready for user testing

### Post-Launch Success Indicators
- User retention (daily usage)
- Constellation usage vs individual portals
- Interface mode preference distribution
- Feature discovery rate
- Performance metrics (battery, memory)
- User feedback sentiment
- Feature requests priorities

---

## Risk Register

### Current Risks

**Risk 1: RealityKit Performance (Phase 6)**
- **Probability:** Medium
- **Impact:** High
- **Mitigation:** Limit orbs per view (max 20), implement LOD if needed
- **Status:** Monitoring

**Risk 2: Embedded Windows UX (Phase 3)**
- **Probability:** High
- **Impact:** Medium
- **Mitigation:** Build as experiment, easy to remove if negative feedback
- **Status:** Planned as decision point

**Risk 3: Orb Mode Complexity (Phase 4-6)**
- **Probability:** Low
- **Impact:** Medium
- **Mitigation:** Extensive testing, keep list view as reliable fallback
- **Status:** Monitoring

**Risk 4: Scope Creep to Phase 9**
- **Probability:** Medium
- **Impact:** High (delays core launch)
- **Mitigation:** Explicit decision point, separate from core phases
- **Status:** Mitigated (Phase 9 is explicitly future)

### Retired Risks
- ~~Share Extension issues~~ (Removed from scope)
- ~~Safari tab control~~ (Accepted as limitation)

---

## Key Architectural Decisions (V3)

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
var portals: [Portal] = []  // ALL portals live here

// Constellations only hold references
var portalIDs: [UUID]  // References, not copies
```

### Beacon Mode Cap at 8 Orbs

**Decision:** Max 8 orbs per page in Beacon mode

**Why:**
- Working memory limit (Miller's Law: 5-9 items optimal)
- Visual clarity (not overwhelming)
- Forces intentionality
- Better performance
- Feels focused

**Alternatives:**
- Favorites mode: Auto-select favorited portals (max 8)
- Manual mode: User picks exactly 8
- All mode: Paginated (8 per page, swipe to see more)

### Universe View in Volume, Not Immersive

**Decision:** Build Universe View as volumetric window (Phase 8.5), save immersive for Phase 9

**Why:**
- Available sooner
- User doesn't need to leave workspace
- Can reference other windows while organizing
- Less dramatic context switch
- Immersive saved for future enhancement

### Favorites & Pinned as Filters

**Decision:** Favorites and Pinned are NOT constellations, just filtered views

**Why:**
- Conceptually simpler
- Can be toggled on/off in settings
- Don't clutter constellation list
- Standard UI pattern
- Prevents confusion

---

## Resources

### Documentation
- **Foundation:** WAYPOINT_FOUNDATION_V3.md
- **Technical:** WAYPOINT_TECHNICAL_SPEC_V3.md
- **Status:** PROJECT_STATUS_V3.md (this file)
- **Code Style:** SKILL.md
- **Future Vision:** PHASE_9_IMMERSIVE_VISION.md

### External References
- **visionOS Documentation:** developer.apple.com/visionos
- **RealityKit Guide:** developer.apple.com/realitykit
- **SwiftUI:** developer.apple.com/swiftui

### Repository
- **GitHub:** https://github.com/UnshackledPursuit/Waypoint
- **Stable Commit:** 52b792a

---

## Change Log

### December 29, 2024 - Phase 2 Complete
- Phase 2 (Input Magic) completed at commit 0e46db9
- Built: Quick Paste, Quick Add, Constellations, URL scheme
- Discovered visionOS drag & drop limitation (solved with toolbar buttons)
- Removed Favorites system (replaced by Constellations)
- Added constellation filters and icons on portal rows

### December 29, 2024 - v3.0
- Complete rewrite aligned with V3 architecture
- Removed reference to V2's 4-mode system
- Clarified Phase 1.2 as stable baseline
- Added Phase 8.5 (Universe View) as core feature
- Moved Phase 9 (Immersive) to separate vision doc
- Updated total build time to 22 hours (core) + 11 hours (future)
- Emphasized portal reference architecture
- Clarified favorites/pinned as filters
- Removed Share Extension entirely from scope
- Streamlined documentation references

### December 28, 2024 - v2.0
- Completed Phase 1.2 (CRUD, Quick Start, Pin/Favorite)
- Established stable baseline at 52b792a
- Decided to continue from current state (no rebuild)

---

**Current Status:** Phase 2 Complete ✅
**Next Action:** Phase 3 (Embedded Windows - optional) or skip to Phase 4 (SwiftUI Orbs)
**Estimated Time to MVP:** 19 hours remaining (Phases 3-8.5)

---

**End of Project Status v3.0**

*This document supersedes PROJECT_STATUS_V2.md*  
*Last updated: December 29, 2024*
