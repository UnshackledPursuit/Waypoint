## Alignment Notes (v1)
- Terminology aligned to **Waypoint Spatial Graph Spec v1.0**
- Language reconciled with **DECISIONS.md**, **BUILD.md**, and **DEV_STANDARDS.md**
- No feature scope changes; content clarified and cross-referenced only
- Document remains implementation-focused and phase-accurate

---

# Next Implementation Steps (Immediate)
**Objective:** Keep shipping momentum: improve drag/drop reliability and build Orb sacred flow scaffolding without changing your existing managers.

---

## Step 0 — Decide initial UI placement (recommended)
- Keep existing `PortalListView` as the “management” panel
- Add a new `OrbHubView` as the “wow” panel (can be a new tab/route)

---

## Step 1 — Drag & Drop Upgrade (required) ✅ Completed
1. Replace `.dropDestination(for: String.self)` with provider-based `.onDrop(of:...)`
2. Add `DropParser.swift` (async provider extraction)
3. Route extracted URLs → existing `handleDroppedURLs(_:)`
4. Confirm:
   - Safari link drop works
   - Files PDF drop works

**Output:** Drag/drop becomes “foundational” without breaking Quick Paste.
**Status:** Completed (provider-based URL + fileURL + text drop; DropParser in place)

---

## Step 2 — New Portal Micro-Actions (create + duplicate) ✅ Completed
1. Add a transient `lastCreatedPortalID` and `focusRequestPortalID` to drive UI feedback
2. After create:
   - pulse orb/row
   - show micro-actions (Open / Assign / Pin / Edit)
3. On duplicate add:
   - summon existing (focus request) + same micro-actions

**Output:** Creation feels premium and guided.
**Status:** Completed (micro-actions + duplicate summon in place)

---

## Step 3 — Orb Sacred Flow Scaffolding (no physics yet) ✅ Scaffolding Complete
1. Add `OrbSceneState` (hub/expanded/focused) ✅
2. Implement `OrbTopBar` (Back / Layout / Flip / Launch Set) ✅
3. Implement `OrbLayoutEngine` strategies: ✅
   - Linear (vertical/horizontal)
   - Arc
   - Spiral
   - Hemisphere 2.5D
4. Implement `OrbFieldView` using: ✅
   - `PortalManager.portals`
   - `ConstellationManager.constellations`

**Output:** You can pinch a constellation → expand → see portals as orbs → launch.
**Status:** Scaffolding complete. Files created:
- `OrbSceneState.swift`, `OrbLayoutEngine.swift`
- `OrbContainerView.swift`, `OrbSceneView.swift`, `OrbHubView.swift`
- `OrbFieldView.swift`, `OrbExpandedView.swift`
- `OrbTopBar.swift`, `OrbModeToggle.swift`, `OrbOrnamentControls.swift`
- `PortalOrbView.swift`, `ConstellationOrbView.swift`

**Additional work completed:**
- Constellation UI redesign (orbital picker, context menu, edit portal toggles)
- visionOS glass background effects on micro-actions
- Sample data with coordinated portal/constellation relationships
- Debug menu loads both portals and constellations

---

## Step 3.5 — UI Polish & Micro-Actions Refinement ✅ Completed

**EditConstellationView improvements:**
- Larger hero orb (56px → 80px) with enhanced glass effects
- 4-layer gradient with ambient glow, specular highlight, rim light
- Constellation picker with beautiful glass orbs and drag-to-reorder
- Header with "Constellations" title and "Drag to Reorder" hint
- Centered color selection with glass orb buttons

**PortalListView micro-actions fixes:**
- Fixed long-press gesture (was conflicting with List's drag-to-reorder)
- Orbital picker stays open when toggling constellations
- Auto-dismiss pauses while orbital picker is expanded
- Vibrant orb colors with colored shadows
- Context menu only shows Edit option (removed Delete from orbital picker)
- Duplicates now scroll to top (anchor: .top)

**Status:** Completed. Long-press → micro-actions works reliably.

---

## Known Issue: Custom Sort (Drag-to-Reorder) Disabled ⚠️

**Problem:** List's `.onMove` and `.editMode` use long-press internally for drag-to-reorder, which conflicts with our custom long-press → micro-actions gesture.

**Current state:** Disabled in PortalListView.swift (commented out):
- `.onMove { ... }`
- `.environment(\.editMode, $editMode)`
- Related onChange/onAppear handlers

**To fix (future):**
1. **Option A:** Add dedicated drag handles on each row (long-press row = micro-actions, drag handle = reorder)
2. **Option B:** Add explicit "Reorder Mode" toggle button that switches gesture behavior
3. **Option C:** Use context menu for micro-actions instead of long-press (frees long-press for reorder)

**Recommendation:** Option A (drag handles) provides best UX - both gestures work simultaneously.

---

## Step 3.7 — FaviconService (Required before Wormhole) ✅ Completed

**Goal:** Fetch and cache favicons for web portals so orbs display actual icons instead of letter avatars.

**Implementation completed:**
1. Created `FaviconService.swift`:
   - Actor-based singleton for thread-safe operations
   - Memory cache (NSCache, 100 items, 50MB limit) + disk cache
   - Multiple favicon sources: Google, DuckDuckGo, direct favicon.ico, apple-touch-icon
   - Image resizing to 64x64 for consistency
   - Dominant color extraction for orb glow effects
2. Integrated with `PortalManager`:
   - `add()` triggers async favicon fetch (non-blocking)
   - `addMultiple()` triggers batch favicon fetch
   - `fetchFavicon(for:)` method updates portal thumbnailData
   - `refreshAllFavicons()` for bulk refresh of existing portals

**Portal model already has:**
- `thumbnailData: Data?` - for auto-fetched favicon ✅
- `customThumbnail: Data?` - for user override ✅
- `displayThumbnail` computed property ✅

**Output:** Portals automatically display website favicons in List view and Orb view.
**Status:** Completed (commits d916f73, f4e28fc)

**Additional improvements (f4e28fc):**
- Fixed Huggingface and similar sites by reordering favicon sources (DuckDuckGo first)
- Added `Color.fromHost()` for consistent fallback colors based on URL host
- Added `Portal.fallbackColor` and `Portal.avatarInitial` helpers
- QuickStartPortalsView now shows styled initial avatars with gradient orbs
- Duplicate detection triggers favicon fetch if portal missing thumbnail
- AddPortalView form made more compact

---

## Step 3.8 — Test Orb Tab Functionality 🟡 Future

**Goal:** Verify the scaffolded Orb views work correctly.

**Test checklist:**
- [ ] Orb tab opens without crash
- [ ] Constellations display as orbs in Hub
- [ ] Pinch constellation → expands to show portal orbs
- [ ] Pinch portal → launches URL
- [ ] Back gesture → returns to Hub
- [ ] Layout auto-switches by portal count (Linear/Arc/Spiral/Hemisphere)

**Output:** Orb Sacred Flow works: Hub → Expand → Launch → Return

---

## Step 3.9 — Glassy Orb UI Polish ✅ Completed

**Goal:** Unify visual aesthetic across all portal displays with premium glass orb styling.

**Implementation completed:**

1. **Glassy Orb Aesthetic (all views):**
   - Outer glow (RadialGradient with app-type color)
   - Glass specular highlight (top-left)
   - Rim light stroke (LinearGradient)
   - Colored drop shadow
   - Applied to: PortalListView, QuickStartPortalsView, AddPortalView

2. **Portal Model Enhancement:**
   - Added `keepFaviconWithCustomStyle: Bool` property
   - Allows custom glow color while preserving fetched favicon
   - Three-way toggle: default style, custom style, custom style + keep favicon

3. **AddPortalView Improvements:**
   - Quick start orbs now create portals directly (one-tap creation)
   - Removed Preview section from Create Portal screen
   - Added "Keep Favicon" toggle in Custom Style section
   - Reordered Edit Portal form: Custom Style + Constellations at top for favicon portals
   - Hero preview reflects keepFaviconWithCustomStyle state

4. **QuickStartPortalsView Enhancements:**
   - Favicons fetched via DuckDuckGo API
   - Glassy orb styling with fallback to colored initial

5. **PortalListView Updates:**
   - Full glassy orb thumbnailView rewrite
   - Supports all combinations: custom style, favicon, keep favicon + custom color, type icon, fallback initial
   - quickStartPortalButton with matching glass aesthetic

6. **Portal Pack Updates:**
   - Added Vibe Code to Indie developer pack
   - Freeform default color changed to soft blue (0.4, 0.7, 0.95)

**Output:** Consistent premium glass orb aesthetic across entire app.
**Status:** Completed

---

## Step 3.10 — Fix Custom Sort (Drag Handles) 🟡 OPTIONAL

**Goal:** Re-enable drag-to-reorder portals without breaking long-press micro-actions.

**Implementation:** Add dedicated drag handle icon on each PortalRow that initiates reorder.

---

## Already Fixed (in main, commit 7a78190):
- ✅ RTFD duplicate portal creation from Notes drops
- ✅ Quick Add keyboard mic button (removed .keyboardType(.URL))
- ✅ YouTube naming improvements

---

## Known Limitations (To Address in Future Phases)

### Orb View Ornament Filters
- Currently only "All" filter is available in the Orb view ornament
- Constellation filters and other filter options not yet wired up
- Will be addressed when building out full Orb Sacred Flow (Phase 4+)

### AddPortalView Window Size
- visionOS window sizing is controlled by system, not explicitly settable
- Form made more compact but window size may still feel large
- Consider using `.defaultSize()` modifier in WindowGroup if needed

---

## Step 4 — Wormhole Swap (Linear layout only)
Implement the constellation switch animation in Linear mode:
- bottom portal swallow old
- top portal drop new

**Output:** Swapping constellations feels magical and intentional.

---

## Step 5 — Documentation discipline
Every time you complete a step:
- Update `PROJECT_STATUS` with:
  - what shipped
  - what changed in data model
  - any known bugs
- Add a short “Decision Log” entry:
  - why you chose it
  - what you deferred

---

## Optional (later)
- File launch persistence (bookmark vs import)
- Per-constellation layout override
- Tag/type ornaments in orb view
