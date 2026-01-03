# AGENTS.md — Waypoint Codex/Claude Instructions
**Purpose:** Ensure any CLI agent reads the right docs and implements changes safely, one phase at a time.
**Last Updated:** 2026-01-03

---

## Required reading (do this first)
1) This file (`AGENTS.md`) - Contains full project status and implementation details

## Development Guidelines
- Build with Xcode for visionOS simulator
- Use `// MARK:` sections for code organization
- Prefer minimal diffs - don't "clean up" unrelated code
- Keep new helpers isolated rather than bloating views

## External Resources
- **[Step Into Vision](https://stepinto.vision)** - Premier visionOS tutorials and news
- [Apple visionOS Developer](https://developer.apple.com/visionos/) - Official documentation
- [Swift with Majid](https://swiftwithmajid.com) - SwiftUI/visionOS tutorials
- [Create with Swift](https://www.createwithswift.com) - visionOS implementation guides

---

## Scope guardrails
- **NO embedded web browsing.** Launch externally via Safari.
- Keep existing truth layer: `PortalManager` + `ConstellationManager`.
- Implement **one phase per change-set**, then stop for user testing.
- **2-second rule:** User must be able to launch any portal in ~2 seconds.

## Current Status (Jan 2026)
**Branch:** `main` (clean - no feature branches)

### ✅ COMPLETE
- Phase 1: Drag & Drop upgrade (provider-based)
- Phase 2: Micro-actions + duplicate handling
- Phase 3: Orb scaffolding + adaptive layouts
- Phase 4: Orb micro-actions (radial arc context menu)
- Phase 5: Adaptive layouts (both views auto-orient)
- Phase 3.0+: Ornament auto-collapse & polish
- **Onboarding Experience Overhaul (Jan 3, 2026)**
- **Narrow Window / Smush Mode** (Jan 3, 2026)
- **Focus Mode** (Jan 3, 2026)
- **Tooltips for All Ornament Controls** (Jan 3, 2026)
- **Phase A: Core Interaction Polish (Jan 3, 2026)**
  - Pin → Favorite rename (star icons system-wide)
  - Constellation popover with drag-drop reordering
  - Trailing popover pattern from ornaments
  - Custom orb hover effects (scale + brightness)
  - ConditionalHelpModifier for tooltips
  - Documented patterns in VISIONOS_INTERACTION_PATTERNS.md
- **Aesthetic Popover Menu (Jan 3, 2026)**
  - Vibrancy, Color Style, Orb Size in unified popover
  - Vibrancy slider with 150% boost mode
  - Focus mode reveal button moved to top-left
- **Filter/Sort Popover & Settings Consolidation (Jan 3, 2026)**
  - Consolidated Settings menu: Appearance, Sort & Filter, Ornaments
  - Ornaments popover with Focus Mode, Side Panel, Bottom Bar toggles
  - Contextual descriptions for each setting
  - Icon-only compact buttons with circular hover effects
  - Ungrouped filter option added
  - Constellation Color sort mode

### 🔴 NEXT (Priority Order)

#### Phase A.1: Remaining Interaction Polish
1. **Orb Eye/Gaze Interactions** - Orbs not responding visually to eye gaze (needs device testing)

#### Phase B: UX Refinements
2. **Haptic Feedback** - Subtle haptics on orb interactions
3. **Sound Design** - Audio cues on open/close/select
4. **Reduced Motion Support** - Accessibility alternatives

#### Phase C: Advanced Features
5. **Quick Start Portal Groups Enhancement** - Inspector/auxiliary window, live editing
6. **Spatial Widgets** (visionOS 26) - Waypoint widget snaps to walls/tables
7. **"Look to Scroll"** - For long portal lists

#### Phase B.5: View Behavior Consistency (Own Phase)
- **Duplicate link handling** - Unify behavior between List and Orb views
- List view: auto-scrolls to existing portal (works)
- Orb view: silent (spatial layout can't scroll)
- Solution: Toast notification + visual highlight in both views

#### Phase D: Final Polish
8. **Liquid Glass Adoption** - Update sheets/inspectors when ready
9. **Custom Hover for Constellations** - Expand to show portal thumbnails
10. **3D Depth Effects** - Subtle z-offset for selected/active states
11. **Universe View** - Strategic overview
12. **App Store Polish** - Final refinements

### 🔵 DEFERRED (Not Now)
- **Wormhole Swap Animation** - Visual reordering feedback (nice-to-have)
- **Full Space Experiences** - Immersive mode
- **RealityKit 3D Orbs** - Volumetric orb rendering
- **Spatial Anchoring** - Lock to surfaces
- **Hand Tracking Custom Gestures** - ARKit hand skeleton

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

## Branch Management (IMPORTANT)

### After Merging a Feature Branch
Every merge MUST be followed by cleanup:

```bash
# 1. Verify merge is complete
git branch --merged main  # your branch should appear

# 2. Delete local branch
git branch -d feature/xxx

# 3. Delete remote branch
git push origin --delete feature/xxx

# 4. Update documentation (AGENTS.md, PROJECT_STATUS, BRANCH_STATUS)
```

### For Abandoned Experiments
If abandoning experimental work but want to preserve for future reference:

```bash
# Archive via tag (preserves code without cluttering branches)
git tag archive/experiment-name origin/experiment/xxx
git push origin archive/experiment-name
git push origin --delete experiment/xxx
```

If discarding entirely (code will be lost):
```bash
git push origin --delete experiment/xxx
```

### Branch Policy
- **Only `main` should exist long-term**
- Feature branches are temporary - delete after merge
- Never keep merged branches "just in case" - history is preserved in main
- Archive experiments via tags if code might be useful later

---

## v1.0 Launch Roadmap (Jan 2026)

### Ship-Ready Checklist

| Category | Item | Status | Priority |
|----------|------|--------|----------|
| **Accessibility** | Reduced Motion Support | 🔴 TODO | Critical |
| **Accessibility** | Haptic Feedback | 🔴 TODO | High |
| **Accessibility** | Eye Gaze Verification | 🔴 TODO | Critical |
| **Polish** | Sound Design | 🔴 TODO | Medium |
| **Polish** | Glass Effect Consistency Audit | 🔴 TODO | High |
| **UX** | Duplicate Link Magic Appear | 🔴 TODO | Medium |
| **QA** | Link Features Audit (all packs) | 🔴 TODO | High |
| **Feature** | Quick Add Redesign (trailing window) | 🔴 TODO | High |
| **Branding** | App Intro Animation | 🔴 TODO | High |
| **Branding** | Logo & Color Palette | 🔴 TODO | High |

### Execution Order

```
Week 1: Foundation (Accessibility)
├── Phase 1: Reduced Motion
├── Phase 2: Haptic Feedback
├── Phase 3: Eye Gaze Test + Fix
└── Phase 7: Link Audit

Week 2: Polish
├── Phase 4: Sound Design
├── Phase 5: Glass Audit & Consistency
└── Phase 6: Duplicate UX (Magic Appear)

Week 2.5: Quick Add Redesign
├── Phase 8: Trailing Window for Portal Packs
├── Quick URL modal (fast popup)
└── Live constellation updates

Week 3: Branding & Ship
├── Phase 11: App Intro/Logo/Colors
└── Final testing & App Store submission
```

### Post-Launch Roadmap

| Version | Features |
|---------|----------|
| **v1.1** | Liquid Glass toggle, Compact card density option |
| **v2.0** | Special Orb Types (Voice Note, Sticky Note, Scribble Pad, AI Chat, Document Folder), Siri-style Prismatic orbs, Appearance options toggle |

---

## Future Feature Ideas (Backlog)
These are ideas for post-v1 consideration. Do not implement unless explicitly requested.

- **Custom Sort Enhancements:** Review/improve custom sort behavior (known issues with drag-reorder - needs investigation before modifying)
- **Quick Add Redesign (PRE-LAUNCH v1.0):** Split URL input from Portal Packs. Consider:
  - Portal Packs as trailing auxiliary window (right side of app)
  - Live constellation assignment with real-time main view updates
  - Quick URL input as fast popup modal (keep simple, URL-focused)
  - Preserve current layout structure - works well
- **Portal Display Density Option:** Add explicit toggle for orb display density:
  - Comfortable: Current orbs with labels
  - Compact: Smaller orbs, labels hidden
  - Dense: Square/rectangle cards in grid layout
  - See `LiquidGlassOrbPreview.swift` for card prototypes
- **Orb Visual Redesign:** Explore alternative orb rendering styles (current: 7-layer glass sphere). Options to investigate: Liquid Glass (visionOS 26), RealityKit 3D, simpler flat styles, custom shapes per portal type
- **Siri-Style Prismatic Orb (v2):** Multi-color swirling orb inspired by Apple's Siri orb. Achievable with:
  - `AngularGradient` for multi-color swirl (red/green/blue/purple blend)
  - Animated rotation for swirl effect
  - Boosted specular highlight (0.9 opacity vs current 0.7)
  - Tinted rim light (cyan/purple gradient)
  - ~80% achievable in SwiftUI; true 3D depth needs RealityKit
  - See Siri orb reference in visionOS for target aesthetic
- **Appearance Options Toggle (v2):** User-selectable orb styles:
  - Classic (current 7-layer)
  - Liquid Glass (simpler, system-native)
  - Prismatic (Siri-inspired multi-color)
  - See `LiquidGlassOrbPreview.swift` for prototypes
- **Save Profile / Workspace Presets:** Allow users to save and restore portal/constellation setups
- **Delete Constellation UI:** Add explicit delete option in constellation management
- **Per-constellation layout overrides:** Allow users to override auto-layout per constellation
- **Advanced color/intensity systems:** Constellation-scoped color palettes
- **Multi-device sync:** iCloud-based portal/constellation sync

---

## Known Issues (to address)
- Quick Add keyboard missing voice/mic button (cosmetic)
- RTFD duplicate portal creation from Notes drops (workaround: skip RTFD files)
- **Duplicate link behavior inconsistent:** List view auto-scrolls to existing portal; Orb view does nothing (architectural - orbs are spatial, not scrollable). Needs unified feedback approach.

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

## Narrow Window / Smush Mode (Jan 3, 2026) ✅ IMPLEMENTED

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
- [x] Window resizes smoothly down to ~150pt width
- [x] List view shows icon-only at narrow widths (<180pt)
- [x] Orb view shows scrollable strip at narrow widths (<150pt)
- [x] Padding adapts gracefully (24pt → 16pt → 12pt → 8pt)
- [x] Ornaments auto-hide when too narrow (<250pt)
- [x] QuickAddSheet works at reduced width (280pt min)

### Testing Notes
- Test on visionOS simulator with window resize handles
- Test both portrait and landscape orientations
- Test with 1, 5, 10, 20+ portals
- Verify micro-actions still work in icon-only mode

---

## Focus Mode (Jan 3, 2026) ✅ IMPLEMENTED

### Overview
Focus Mode provides a distraction-free viewing experience by hiding ornaments. Can be triggered manually or automatically when the window becomes very narrow/short.

### Trigger Conditions
Ornaments hide when ANY of these conditions are true:
- **Focus Mode enabled** via toggle button (eye icon in left ornament)
- **Window width < 250pt** (auto-trigger)
- **Window height < 200pt** (auto-trigger)

### Temporary Reveal Mechanism
When ornaments are hidden, a small "..." button appears in the bottom-left corner:
- Tap to reveal ornaments for 8 seconds
- Auto-hides after timeout
- Allows quick access to controls without exiting focus mode

### Implementation Details

| Component | Purpose |
|-----------|---------|
| `@AppStorage("focusMode")` | Persistent toggle state |
| `temporaryOrnamentReveal` | Transient reveal state |
| `ornamentRevealWorkItem` | Cancellable timer for auto-hide |
| `FocusModeRevealButton` | Small circular button with "..." icon |
| `FocusModeToggle` | Eye/eye.slash toggle in left ornament |

### Files Changed
- `WaypointApp.swift` - Focus mode state, window tracking, reveal button overlay, ornament visibility logic
- `WaypointLeftOrnament.swift` - Added `focusMode` binding, `FocusModeToggle` component

### UX Flow
1. User taps eye icon → ornaments hide immediately
2. Small "..." button appears in corner
3. User can tap "..." to temporarily reveal ornaments (8s)
4. User can tap eye.slash to exit focus mode entirely
5. Resizing window very small auto-enters focus-like state

---

## Tooltips for All Ornament Controls (Jan 3, 2026) ✅ IMPLEMENTED

### Overview
Added `.help()` tooltips to all interactive controls in both ornaments. Tooltips appear on hover/gaze in visionOS, providing discoverability for new users.

### Left Ornament Tooltips (WaypointLeftOrnament.swift)

| Control | Tooltip |
|---------|---------|
| View toggle | "Switch to Orb View" / "Switch to List View" (dynamic) |
| Focus Mode | "Enter Focus Mode" / "Exit Focus Mode" (dynamic) |
| Paste button | "Paste from Clipboard" |
| Add Portal button | "Add Portal" |
| Intensity slider | "Adjust Intensity" |
| Color mode picker | "Color Style" |
| Orb size picker | "Orb Size" |
| Constellation button | "Create Constellation" / "Edit Constellation" (dynamic) |
| Settings gear | "Ornament Settings" |
| Side ornament toggle | "Side: Auto-hide ON" / "Side: Always Visible" (dynamic) |
| Bottom ornament toggle | "Bottom: Auto-hide ON" / "Bottom: Always Visible" (dynamic) |

### Bottom Ornament Tooltips (WaypointBottomOrnament.swift)

| Control | Tooltip |
|---------|---------|
| All filter | "Show All" |
| Pinned filter | "Show Pinned" |
| Constellation pills | "View [constellation name]" (dynamic) |
| Create button (+) | "Create Constellation" |
| Launch All button | "Launch All" |

### Implementation Pattern
Added optional `helpText` parameter to reusable button components:
```swift
private struct TabIconButton: View {
    let icon: String
    var helpText: String? = nil
    // ...
    .help(helpText ?? "")
}
```

### Files Changed
- `WaypointLeftOrnament.swift` - Added tooltips to all controls
- `WaypointBottomOrnament.swift` - Added tooltips to all controls

---

## Orb Micro-Actions v2 (PARTIALLY COMPLETE)

### What's Done
- Pin → Favorite rename with star icons throughout app
- Custom hover effects (scale 1.12x + brightness boost)
- Removed system `.hoverEffect()` that caused frosted bubble artifacts
- ConditionalHelpModifier to avoid empty tooltip issues
- Constellation popover with drag-drop reordering
- Documented trailing popover and drag-drop patterns

### What Remains
- **Orb gaze interactions not working** - custom hover effects work in simulator but need device testing
- May need different approach for visionOS eye tracking vs mouse hover

### Current Implementation
`PortalOrbView.swift` uses a custom radial arc layout:
- Long-press triggers `showActions` state
- Actions positioned in arc above orb
- Custom animation with delay per action
- Works but eye gaze response needs investigation

### Options to Explore

#### Option A: Native Context Menu with Preview
```swift
.contextMenu {
    Section("Open") {
        Button("Open in Safari") { }
        Button("Open in New Window") { }
    }
    Section("Edit") {
        Button("Rename") { }
        Button("Pin/Unpin") { }
        Button("Add to Constellation") { }
    }
    Section {
        Button("Delete", role: .destructive) { }
    }
} preview: {
    PortalPreviewCard(portal: portal)
}
```
**Pros:** Native feel, automatic styling, preview support
**Cons:** Less visual flair, may feel generic

#### Option B: Popover with Sections
```swift
.popover(isPresented: $showActions) {
    VStack(spacing: 0) {
        PortalHeader(portal: portal)
        Divider()
        ActionGrid(actions: primaryActions)
        Divider()
        ActionList(actions: secondaryActions)
    }
}
```
**Pros:** Rich content, extends beyond window, customizable
**Cons:** More code, different interaction model

#### Option C: Enhanced Radial + Hover
Keep current radial but add:
- Glow/lift effect on gaze (before long-press)
- Quick action on single tap (open portal)
- Radial only for secondary actions
- Smoother spring animations

**Pros:** Preserves unique identity, enhances existing
**Cons:** Still non-native, more polish needed

#### Option D: Hybrid Approach
- **Tap:** Open portal immediately
- **Gaze hover (1s):** Show mini preview tooltip
- **Long-press:** Native context menu with full actions
- **Two-finger tap:** Quick constellation add

**Pros:** Multiple interaction depths, progressive disclosure
**Cons:** Complex, learning curve

### Recommended Approach
Start with **Option C (Enhanced Radial + Hover)** because:
1. Preserves Waypoint's unique visual identity
2. Minimal code changes required
3. Can add Option A as fallback later
4. Aligns with existing design language

### Implementation Plan

#### Phase 1: Enhanced Hover Feedback
1. Add `.hoverEffect(.lift)` to orb
2. Add custom glow effect on hover
3. Show portal name tooltip on hover
4. Animate orb scale slightly on gaze

#### Phase 2: Improved Radial Animation
1. Smoother spring animations
2. Staggered appearance with better timing
3. Add subtle backdrop blur when open
4. Better dismiss gesture (tap outside)

#### Phase 3: Quick Actions
1. Single tap = open portal (currently requires action button)
2. Consider double-tap for pin toggle
3. Add haptic feedback on interactions

#### Phase 4: Context Menu Fallback
1. Add `.contextMenu` as accessibility alternative
2. Include all actions for keyboard/switch control users
3. Add preview card to context menu

### Files to Modify
- `PortalOrbView.swift` - Primary changes
- `OrbLinearField.swift` - May need hover coordination
- `PortalListView.swift` - Mirror enhancements for consistency

### Success Criteria
- [x] Hover shows subtle feedback before long-press (scale + brightness implemented)
- [ ] Radial menu animations feel native/polished
- [ ] Single tap opens portal (no extra button needed)
- [x] Actions have tooltips (ConditionalHelpModifier)
- [ ] Context menu available as fallback
- [ ] Consistent with visionOS design guidelines
- [ ] Orbs respond to eye gaze on device (needs testing)

### Testing Notes
- **IMPORTANT:** Test on device for eye gaze interaction accuracy - simulator uses mouse hover
- Verify 60pt touch target compliance
- Test with reduced motion settings
- Ensure accessibility with VoiceOver
