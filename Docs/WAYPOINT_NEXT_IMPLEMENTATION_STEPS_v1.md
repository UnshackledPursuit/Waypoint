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
