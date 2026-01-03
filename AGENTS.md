# AGENTS.md — Waypoint Codex/Claude Instructions
**Purpose:** Ensure any CLI agent reads the right docs and implements changes safely, one phase at a time.
**Last Updated:** 2026-01-02

---

## Required reading (do this first)
1) `Docs/PROJECT_STATUS_JAN2026.md` ← **PRIMARY STATUS DOC**
2) `Docs/build.md`
3) `Docs/decisions.md`
4) `Docs/dev_standards.md`

## Optional reading
- `Docs/WAYPOINT_ORB_WORMHOLE_SWAP_v1.md` (for Phase 6)
- `Docs/REPO_WORKFLOW.md` (phase branches, PR checklist)

---

## Scope guardrails
- **NO embedded web browsing.** Launch externally via Safari.
- Keep existing truth layer: `PortalManager` + `ConstellationManager`.
- Implement **one phase per change-set**, then stop for user testing.
- **2-second rule:** User must be able to launch any portal in ~2 seconds.

## Current Status (Jan 2026)
**Branch:** `feature/narrow-window-smush`

### ✅ COMPLETE
- Phase 1: Drag & Drop upgrade (provider-based)
- Phase 2: Micro-actions + duplicate handling
- Phase 3: Orb scaffolding + adaptive layouts
- Phase 4: Orb micro-actions (radial arc context menu)
- Phase 5: Adaptive layouts (both views auto-orient)
- Phase 3.0+: Ornament auto-collapse & polish
- **Onboarding Experience Overhaul (Jan 3, 2026)**

### 🟡 IN PROGRESS
- **Narrow Window / Smush Mode** (see detailed plan below)

### 🔴 NEXT
- **Phase 6:** Wormhole Swap Animation
- **Phase 7:** Universe View (strategic overview)
- **Phase 8:** App Store Polish

## Key Files
### Views
- `OrbContainerView.swift` - Main orb container with filtering/sorting
- `OrbLinearField.swift` - Adaptive smart grid (portrait/landscape)
- `PortalOrbView.swift` - Individual orb with radial arc menu
- `PortalListView.swift` - List view with full features
- `WaypointLeftOrnament.swift` - Left ornament (tabs, quick actions, aesthetics)
- `WaypointBottomOrnament.swift` - Bottom ornament (filters, constellations)

### Services
- `PortalManager.swift` - Portal CRUD and persistence
- `ConstellationManager.swift` - Constellation management
- `DropParser.swift` - URL extraction from drag items
- `DropService.swift` - Portal creation from URLs

## Working style
- Prefer minimal diffs. Do not “clean up” unrelated code.
- Keep new helpers isolated (e.g., `DropParser.swift`) rather than bloating views.
- Use `// MARK:` sections per `Docs/dev_standards.md`.
- When uncertain, add TODO comments and ask for clarification in the PR message / output.

## Validation expectations
- Ensure the project compiles after each phase.
- If `xcodebuild` is available, run a build and report results.
- If not available, at minimum ensure code type-checks and imports are correct.

## Output format (each phase)
- Summary of what changed
- List of files touched
- Any known risks / next tests for the user to run

---

## Future Feature Ideas (Backlog)
These are ideas for post-v1 consideration. Do not implement unless explicitly requested.

- **Save Profile / Workspace Presets:** Allow users to save and restore portal/constellation setups
- **Delete Constellation UI:** Add explicit delete option in constellation management
- **Per-constellation layout overrides:** Allow users to override auto-layout per constellation
- **Advanced color/intensity systems:** Constellation-scoped color palettes
- **Multi-device sync:** iCloud-based portal/constellation sync

---

## Known Issues (to address)
- Quick Add keyboard missing voice/mic button (cosmetic)
- RTFD duplicate portal creation from Notes drops (workaround: skip RTFD files)

---

## Onboarding Experience Overhaul (Jan 3, 2026)

### Progressive UI Disclosure
New users see a clean interface that reveals features as they use the app:

| Stage | Requirements | UI Revealed |
|-------|--------------|-------------|
| Fresh install | 0 portals | Welcome screen only (no ornaments) |
| First portal | 1+ portals | Bottom ornament (filters, + button) |
| First constellation | 1+ constellations | Left ornament (basic actions) |
| Power user | 10+ portals, 1+ constellation | Full left ornament (aesthetics, view toggle) |

### Simplified Portal Creation
- URL-only validation (name auto-derives from URL)
- Hidden Pin toggle in create mode (less clutter for new users)
- Name field hidden until edit mode

### Onboarding Toasts (OnboardingHintView.swift)
- **First portal toast:** "Portal created! Tap to open • Drag more links to add"
- **First constellation hint:** "[Name] created! Long press a portal to add it"
- Auto-dismiss after 6 seconds
- Green checkmark styling (neutral, not purple)
- Proper z-ordering (overlays main content, not ornaments)

### Portal Picker Improvements (CreateConstellationView)
- Glassy orb style with favicons (matches app design language)
- Prioritizes ungrouped portals (not in any constellation)
- Shows up to 8 portals to fill width
- Selection checkmark badge in constellation color

### Color Palette Update
Removed confusing purple shades, added yellow and black:
- Blue, Green, Orange, Red, **Yellow**, Indigo, Teal, **Black**

### Icon Name Improvements
More evocative auto-suggestions for constellation icons:
- book.fill → "Articles" (was "Reading")
- heart.fill → "Saved" (was "Personal")
- flame.fill → "Trending" (was "Hot")
- moon.fill → "Night Owl" (was "Night Mode")
- film.fill → "Watch" (was "Entertainment")
- wand.and.stars → "Creative" (new icon, replaces camera.fill)

### Ornament Settings (Power Users)
Collapsible settings submenu at bottom of left ornament:
- sidebar.left icon for side ornament auto-collapse
- dock.rectangle icon for bottom ornament auto-collapse
- Slash through icon = will auto-hide
- No slash = stays visible
- Settings respond immediately via onChange handlers

### Files Changed
- `OnboardingHintView.swift` (NEW) - Toast views and OnboardingState
- `WaypointApp.swift` - Progressive ornament visibility
- `WaypointLeftOrnament.swift` - Progressive controls, settings submenu
- `WaypointBottomOrnament.swift` - Hint removal, onChange for settings
- `PortalListView.swift` - Toast overlays and onChange handlers
- `CreateConstellationView.swift` - Portal picker, colors, icon names
- `EditConstellationView.swift` - Color palette, icon options
- `AddPortalView.swift` - Simplified validation, color palette

---

## Narrow Window / Smush Mode Plan (Jan 3, 2026)

### Problem Statement
The Waypoint window cannot resize narrower than ~400pt width. Users want:
1. **List view** to show icon-only when window is very narrow ("smush" mode)
2. **Orb view** to support single-line vertical/horizontal strip layouts
3. Window to resize freely down to ~150-200pt width

### Root Cause Analysis

#### Hard Constraints (Blockers)

| File | Line | Constraint | Impact |
|------|------|-----------|--------|
| `WaypointLeftOrnament.swift` | 1113 | `.frame(minWidth: 400, minHeight: 500)` | **PRIMARY BLOCKER** - QuickAddSheet forces 400pt minimum |
| `WaypointApp.swift` | 110 | `.defaultSize(width: 400, height: 600)` | Default window size (not hard limit) |

#### Soft Constraints (Layout Issues)

| File | Line | Constraint | Impact |
|------|------|-----------|--------|
| `OrbContainerView.swift` | 105 | `.padding(24)` | 48pt horizontal padding doesn't adapt |
| `OrbLinearField.swift` | 146 | `.frame(minHeight: 150)` | Minimum container height |
| `OrbLinearField.swift` | 87 | `orbItemWidth = orbSize * 1.7 + 8` | ~85pt per orb item (medium) |
| `WaypointBottomOrnament.swift` | 120 | `.frame(maxWidth: 350)` | Constellation scroll area |

#### Missing Features
- **No icon-only mode** in list view - always shows text
- **No strip mode** in orb view - no single-line scrollable layout
- **Fixed padding** doesn't reduce for narrow windows
- **No auto-collapse trigger** for ornaments at narrow widths

### Implementation Plan

#### Phase 1: Remove Hard Constraints
**Files:** `WaypointLeftOrnament.swift`, `WaypointApp.swift`

1. Reduce QuickAddSheet minWidth: `400pt → 280pt` (or make adaptive)
2. Reduce default window size to `320pt` width
3. Consider adding explicit minimum window hints

#### Phase 2: Adaptive Padding
**Files:** `OrbContainerView.swift`, `OrbLinearField.swift`

Replace fixed `.padding(24)` with adaptive padding:
```swift
let adaptivePadding: CGFloat = {
    if size.width < 200 { return 8 }
    if size.width < 300 { return 16 }
    return 24
}()
```

OrbLinearField already has `effectivePadding` logic for `isNarrow` - extend this pattern.

#### Phase 3: Icon-Only "Smush" Mode for List View
**Files:** `PortalListView.swift`, `PortalRow.swift` (or new `PortalIconRow.swift`)

1. Add `@AppStorage("listDisplayMode")` with values: `full`, `compact`, `iconOnly`
2. Auto-switch to `iconOnly` when `width < 180pt`
3. Create `PortalIconOnlyRow` component:
   - Shows just the orb/icon (no text)
   - Tap to open, long-press for micro-actions
   - Optional: horizontal scroll strip at extreme widths
4. Layout detection in `calculateListLayout()`:
   ```swift
   if width < 180 {
       return ListLayout(columns: 1, isCompact: true, isIconOnly: true)
   }
   ```

#### Phase 4: Orb View Narrow Strip Mode
**Files:** `OrbLinearField.swift`, `OrbLayoutEngine.swift`

1. Detect "strip" mode when:
   - Portrait: width < 150pt
   - Landscape: height < 150pt
2. Strip mode behavior:
   - Single line of orbs (scrollable)
   - Auto-switch to smallest orb size
   - Minimal padding (8pt)
   - Hide section headers
3. Update `OrbLayoutEngine.orientation()` to return `.strip` for extreme dimensions

#### Phase 5: Auto-Collapse Ornaments at Narrow Widths
**Files:** `WaypointApp.swift`, `WaypointBottomOrnament.swift`

1. Add width observer to WaypointApp
2. Auto-collapse bottom ornament when width < 250pt
3. Show minimal expand indicator when collapsed
4. Already have `@AppStorage("bottomOrnamentAutoCollapse")` mechanism to leverage

### Key Files to Modify

| File | Changes |
|------|---------|
| `WaypointApp.swift` | Reduce default size, add width observer for auto-collapse |
| `WaypointLeftOrnament.swift` | Reduce QuickAddSheet minWidth |
| `OrbContainerView.swift` | Adaptive padding based on width |
| `OrbLinearField.swift` | Strip mode, smaller minimums, extend isNarrow logic |
| `OrbLayoutEngine.swift` | Add `.strip` orientation detection |
| `PortalListView.swift` | Icon-only mode detection and rendering |
| `PortalRow.swift` | Icon-only variant or new component |

### Success Criteria
- [ ] Window resizes smoothly down to ~150pt width
- [ ] List view shows icon-only at narrow widths
- [ ] Orb view shows scrollable strip at narrow widths
- [ ] Padding adapts gracefully
- [ ] Bottom ornament auto-collapses when too narrow
- [ ] QuickAddSheet works at reduced width

### Testing Notes
- Test on visionOS simulator with window resize handles
- Test both portrait and landscape orientations
- Test with 1, 5, 10, 20+ portals
- Verify micro-actions still work in icon-only mode
