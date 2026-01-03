# PROJECT STATUS — January 2026

**Last Updated:** January 3, 2026
**Branch:** main (clean)
**Phase:** Aesthetic Popover Complete

---

## Executive Summary

Both **List View** and **Orb View** are now **production-ready**. The orb revamp is complete with an adaptive linear layout system that auto-orients based on window dimensions.

**Aesthetic Popover Complete (Jan 3, 2026):**
- Unified appearance controls in trailing popover
- Vibrancy slider with 150% boost mode
- Color Style: Mono → Portal → Frost → Group
- Orb Size: S/M/L options
- Focus mode reveal button moved to top-left

**Next Phase Focus:**
1. **Orb Eye/Gaze Interactions** - Custom hover effects not responding to visionOS eye gaze (needs device testing)
2. **Filter Popover Menu** - Sort/filter options in trailing popover style

---

## What's Complete

### List View (Production Ready)
- Full portal management (add, edit, delete, pin, reorder)
- Constellation system (create, edit, assign portals)
- Multi-constellation membership with visual indicators
- Drag & drop portal creation from any URL/file
- Clipboard detection and Quick Paste
- URL scheme support (waypoint://add, open, launch)
- Custom sort ordering with manual drag reorder
- Favicon fetching with AsyncImage loading
- Last opened tracking and display

### Ornament System (Refined)
- **Left Ornament:** List/Orb tabs + Paste/Add quick actions + Intensity/Color controls
- **Bottom Ornament:** All/Pinned filters + scrollable constellation pills + Launch
- Larger touch targets (36px) for visionOS accuracy
- Hover-reveal labels on constellation pills
- Context menu on constellation pills (Edit/Launch All)
- Launch button: icon-only with constellation color

### Aesthetic Popover (Updated Jan 3, 2026)
- **Unified Appearance Controls** in trailing popover from left ornament
- **Vibrancy Slider:**
  - 0% = frosted/neutral glass, 100% = vibrant colors, 150% = boost mode
  - Dark accent when in boost zone (>100%)
  - Tick mark shows where 100% sits on slider
  - Footer shows "Boost mode: +X%" when applicable
- **Color Style Picker:** (Left to right: Mono → Portal → Frost → Group)
  - Mono: Complete grayscale (circle.slash icon)
  - Portal: Each portal uses its own style color
  - Frost: Gray bubbles, icons keep color
  - Group: All orbs use active constellation color
- **Orb Size Picker:** S/M/L with visual indicators
- **Mono Mode Effects:**
  - Orb bubbles grayscale
  - Favicons grayscale (saturation: 0)
  - Constellation icons in list view grayscale
  - Pin icons grayscale
  - Bottom ornament constellation pills grayscale
  - Launch button grayscale
- **Multi-constellation handling:**
  - List view: Gradient glow for portals in multiple constellations
  - Orb view: Uses active constellation color
- **Persistence:** All settings stored via @AppStorage

### Quick Add Sheet (Feature Complete)
- Constellation picker at top for quick switching
- Portal pack templates organized by category (AI, Social, Developer, etc.)
- Portal chips color-coded by constellation membership
- Toggle functionality: tap added portal to add/remove from constellation
- Multi-constellation indicators (gradient backgrounds, colored dots)
- Auto-adds to selected constellation
- Close button (not Cancel - everything auto-saves)

### Architecture
- Clean separation: PortalManager, ConstellationManager, NavigationState
- Portal reference architecture (constellations reference by UUID)
- Shared NavigationState for filtering across views
- visionOS ornament integration
- Provider-based drag & drop (DropParser + DropService)

---

## What's Complete (continued)

### Phase 3.0: Orb Linear Focus (Complete - Jan 2, 2026)

**OrbLinearField - Adaptive Smart Grid:**
- Auto-detects orientation (landscape vs portrait)
- Portrait: Multiple scrollable columns, scroll horizontally
- Landscape: Multiple scrollable rows, scroll vertically
- Dynamic padding for narrow views (12pt vs 24pt)
- Smooth scroll indicators with fade and chevron

**Constellation Grouping:**
- ConstellationSection struct for grouped layout
- Section headers with capsule labels (icon + name)
- Responds to constellation color mode
- Scrollable sections in both orientations
- "Ungrouped" section for unassigned portals

**Narrow View Support:**
- OrbTopBar hides title in compact mode (icon-only)
- isCompact parameter flows through component hierarchy
- Dynamic padding reduces in narrow windows

**Constellation Sort Option:**
- Sort by constellation groups portals by membership
- Visual section headers in All view
- Ungrouped portals appear at end

---

## Next Phases (Priority Order)

### ✅ Phase 4: Orb Micro-Actions (COMPLETE)
Radial arc context menu on orbs - edit, pin, delete, add to constellation. Full feature parity with list view.

### ✅ Phase 5: Adaptive Layouts (COMPLETE)
Both orb view and list view auto-reorient based on window dimensions. Constellation grouping works in both views.

### ✅ Phase A: Core Interaction Polish (COMPLETE - Jan 3, 2026)
- Pin → Favorite rename with star icons (white color throughout)
- Constellation popover from left ornament with drag-drop reordering
- Trailing popover pattern (arrowEdge: .trailing, toggle state management)
- Custom orb hover effects (1.12x scale + 0.05 brightness boost)
- Removed system .hoverEffect() that caused frosted bubble artifacts
- ConditionalHelpModifier for tooltips (avoids empty tooltip visual issues)
- Removed star.fill from constellation icon picker (conflicts with favorites)
- Updated default constellation icon to "sparkles"
- Documented patterns in VISIONOS_INTERACTION_PATTERNS.md

---

### 🔴 Phase A.1: Remaining Interaction Polish (NEXT)

**Goal:** Complete orb gaze interactions and add more trailing popovers

**Issues to Resolve:**
- Orbs not responding to eye gaze on visionOS device (custom hover works in simulator)
- May need visionOS-specific approach vs standard SwiftUI .onHover

**Planned Features:**
- Aesthetic Popover Menu (color/intensity controls like constellation popover)
- Filter Popover Menu (sort options like constellation popover)

---

### 🟡 Phase 6: Wormhole Swap Animation (FUTURE)

**Goal:** Dramatic constellation switching animation

**Why Important:** Visual delight. Makes switching constellations feel magical.

**Design Vision:**
- Bottom portal "swallows" current orbs (spiral drain animation)
- New constellation orbs spawn from top portal
- Constellation color influences animation hue

---

### 🟡 Phase 7: Universe View (FUTURE)

**Goal:** Strategic overview of all constellations in a volumetric window

**Design Vision:**
- Volumetric window (~1.3m × 1.0m × 0.5m)
- Simplified constellation nodes (spheres with glow, not full orb detail)
- Movable library overlay for portal assignment
- Two-tier navigation: tap constellation node → opens detail window

---

### 🟢 Phase 8: Polish & App Store Prep (FUTURE)

**Goal:** Final polish for App Store submission

**Includes:**
- Performance optimization
- Onboarding flow
- App Store assets and description
- Bug fixes and edge cases

---

## Design Principles

1. **2-second rule** - Must be able to launch any portal in ~2 seconds
2. **Spatial first** - Not just a list in space, true spatial thinking
3. **Feature parity** - Both views should have equivalent capabilities
4. **Adaptive layouts** - Both views auto-orient based on window size
5. **Consistent grouping** - Constellation sections work in both views

---

## File Reference

### Core Views
- `PortalListView.swift` - Main list view (production ready)
- `OrbContainerView.swift` - Orb view container (production ready)
- `OrbLinearField.swift` - Adaptive smart grid layout (NEW - production ready)
- `OrbExpandedView.swift` - Expanded orb view with top bar
- `OrbTopBar.swift` - Capsule-style header with compact mode
- `PortalOrbView.swift` - Individual orb rendering (needs micro-actions)

### Ornaments
- `WaypointLeftOrnament.swift` - Tabs + quick actions
- `WaypointBottomOrnament.swift` - Filters + constellations + launch

### Services
- `PortalManager.swift` - Portal CRUD and persistence
- `ConstellationManager.swift` - Constellation management
- `DropParser.swift` - URL extraction from drag items
- `DropService.swift` - Portal creation from URLs
- `FaviconService.swift` - Async favicon fetching

### State
- `NavigationState.swift` - Shared filtering state
- `OrbSceneState.swift` - Orb view specific state

---

## Git Workflow

```bash
# Current state
git log --oneline -3
e9caff9 Phase 2.5: Ornament system overhaul + Quick Add enhancements
... (previous commits)

# For orb revamp
git checkout -b feature/orb-revamp
# Work on revamp
git add . && git commit -m "..."
git push -u origin feature/orb-revamp
# When complete, merge to main
```

---

## Recommended Next Session

1. **Collaborative design discussion** - Review orb vision, constraints, and approach
2. **Create minimal Linear prototype** - Vertical stack that works perfectly
3. **Add horizontal adaptation** - When window is landscape
4. **Add scroll support** - When orbs exceed container
5. **Iterate visuals** - Orb styling, spacing, labels
6. **Consider container-less mode** - Just orbs + ornaments

---

## Notes for Future Sessions

### From Documentation Review
- **Wormhole Swap animation** is planned for constellation switching (bottom portal swallows old orbs, top portal spawns new)
- **Constellation Action Nodes** concept - Launch All could be a special orb, not a button
- **Global Intensity Slider** - Controls brightness/saturation for all orbs
- **Node Color is scoped** - Colors don't persist across constellations

### From User Feedback
- Window container should disappear (just ornaments + orbs)
- Linear is the right starting point
- Adaptive vertical/horizontal is expected
- No arbitrary limits (8 orbs max is removed)
- Scroll when needed, don't shrink

---

## Future Features (Backlog)

### Ornament Enhancements
- ~~**Collapsible/Expand Toggle:**~~ ✅ DONE - Both ornaments now auto-collapse
- **Hover Labels for Icon Buttons:** Show labels on gaze for left ornament icons. Currently blocked by visionOS `onHover` limitations - doesn't reliably trigger custom content on gaze. Revisit when visionOS provides better hover API or use native tooltips if available.
- **Duplicate Link Feedback:** When dropping a duplicate URL onto orb view, show visual feedback (currently silently ignores)

### Visual Effects & Immersion
- **Environmental Glow:** In constellation mode, emit a subtle glow from the app that affects the visionOS environment. The constellation's color would cast ambient light into the user's space. Could combine with other aesthetic effects for a more immersive experience.

### Other Potential Features
- Day/night environment toggle (requires visionOS API - currently not exposed)
- ~~Orb size preferences (user-configurable)~~ ✅ DONE - S/M/L toggle in left ornament
- Animation customization (speed, style)

---

## Completed Phases

### Phase 2.5: Ornament System Overhaul (Complete)
- Unified left/bottom ornament design
- Quick Add sheet with constellation picker
- Portal pack templates

### Phase 2.6: Intensity & Color Mode System (Complete - Jan 2, 2026)
- Global intensity slider with collapsible UI
- 4-way color mode toggle (constellation, default, frost, mono)
- Full mono mode grayscale across entire app
- Auto-collapse after inactivity
- Multi-constellation gradient support

### Phase 3.0: Orb Linear Focus & Constellation Grouping (Complete - Jan 2, 2026)
- OrbLinearField adaptive smart grid (replaces broken OrbFieldView)
- Auto-orientation: portrait columns, landscape rows
- Multi-row/column support based on container size
- Scrollable rows/columns with visual indicators
- Constellation sort with section headers
- ConstellationSection struct for grouped layouts
- Capsule-style headers responding to color mode
- Narrow view support (icon-only compact mode)
- Dynamic padding (12pt narrow, 24pt normal)
- Per-portal constellation color lookup in All view

### Phase 3.0+: Ornament Polish & Auto-Collapse (Complete - Jan 2, 2026)
- **Ornament Auto-Collapse System:**
  - Left ornament: Collapses to view toggle + ellipsis after 8 seconds inactivity
  - Bottom ornament: Collapses to show only selected filter (icon for All/Pinned, icon+name for constellation)
  - Both expand on hover/gaze or tap
  - Interactions reset collapse timer
- **Intensity Slider Improvements:**
  - Auto-switches to constellation color mode when slider moved in mono/frost mode
  - Continuous timer reset during drag interaction (prevents collapse while using)
- **Removed constellation header from orb view** - Bottom ornament shows current selection
- **Removed section headers toggle** - Ornament was getting crowded
- **Simplified left ornament** - Clean icon buttons without hover labels (visionOS limitation)

### Onboarding Experience Overhaul (Complete - Jan 3, 2026)

**Goal:** Reduce cognitive load for new users while preserving power user features.

**Progressive UI Disclosure:**
- Fresh install: Clean welcome screen, no ornaments visible
- First portal created: Bottom ornament appears (filters + create constellation button)
- First constellation created: Left ornament appears (basic actions only)
- Power user (10+ portals, 1+ constellation): Full left ornament with aesthetics and view toggle

**Onboarding Toasts:**
- First portal toast: "Portal created! Tap to open • Drag more links to add"
- First constellation hint: "[Name] created! Long press a portal to add it"
- Green checkmark styling, auto-dismiss after 6 seconds
- Proper z-ordering (overlays content, not hidden behind ornaments)

**Simplified Portal Creation:**
- URL-only validation in create mode (name auto-derives)
- Hidden Pin toggle in create mode
- Auto-name derivation from URL hostname

**Portal Picker Redesign (CreateConstellationView):**
- Glassy orb style with favicons matching app design language
- Prioritizes ungrouped portals (not in any constellation)
- Shows up to 8 portals to fill width
- Selection checkmark badge in constellation color

**Color Palette Update:**
- Removed light purple (#AF52DE) and pink (#FF2D55)
- Added yellow (#FFCC00) and black (#1C1C1E)
- Consistent across CreateConstellationView, EditConstellationView, AddPortalView

**Icon Name Improvements:**
- book.fill → "Articles" (was "Reading")
- heart.fill → "Saved" (was "Personal")
- flame.fill → "Trending" (was "Hot")
- moon.fill → "Night Owl" (was "Night Mode")
- film.fill → "Watch" (was "Entertainment")
- wand.and.stars → "Creative" (new, replaces camera.fill)

**Ornament Settings Submenu:**
- Collapsible gear button at bottom of left ornament (power users only)
- sidebar.left toggle for side ornament auto-collapse
- dock.rectangle toggle for bottom ornament auto-collapse
- Slash overlay indicates "will auto-hide"
- No slash indicates "stays visible"
- Settings respond immediately via onChange handlers

**Files Changed:**
- `OnboardingHintView.swift` (NEW) - Toast views and OnboardingState
- `WaypointApp.swift` - Progressive ornament visibility
- `WaypointLeftOrnament.swift` - Progressive controls, settings submenu
- `WaypointBottomOrnament.swift` - onChange for settings
- `PortalListView.swift` - Toast overlays and onChange handlers
- `CreateConstellationView.swift` - Portal picker, colors, icon names
- `EditConstellationView.swift` - Color palette, icon options
- `AddPortalView.swift` - Simplified validation, color palette
