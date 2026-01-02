# PROJECT STATUS — January 2026

**Last Updated:** January 2, 2026
**Branch:** feature/orb-smart-grid
**Phase:** 3.0 Complete - Orb Linear Focus & Constellation Grouping

---

## Executive Summary

Both **List View** and **Orb View** are now **production-ready**. The orb revamp is complete with an adaptive linear layout system that auto-orients based on window dimensions.

**Next Phase Focus:**
1. **Orb Micro-Actions** - Add context actions to orb nodes (radial arc menu)
2. **Adaptive List View** - Auto-reorient list view like orb view does

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

### Global Intensity & Color Mode System (NEW - Jan 2, 2026)
- **Intensity Slider:** Collapsible vertical slider in left ornament
  - 0.0 = frosted/neutral glass, 1.0 = vibrant colors
  - Tap sun icon for max, snowflake for min
  - Collapsed state shows subtle icon (blends in)
  - Teal fill color when expanded (not attention-grabbing)
- **Color Mode Toggle:** 4-way collapsible toggle
  - Constellation mode (orange sparkles): All orbs use active constellation color
  - Default mode (blue palette): Each portal uses its own style color
  - Frost mode (cyan snowflake): Gray bubbles, icons keep color
  - Mono mode (gray slash): Complete grayscale - everything loses color
  - Auto-collapses after 3 seconds of inactivity
  - Shows selected mode icon when collapsed (subtle, no color)
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

## Next Phase: Feature Parity & Adaptive List

### Phase 3.1: Orb Micro-Actions

**Goal:** Add context actions to orb nodes matching list view functionality

**Design Vision:**
- **Radial Arc Menu** - Actions wrap around a quarter of the orb (ideal)
- **Fallback** - Standard context menu if radial is complex

**Actions to Include:**
- Open (primary tap - already works)
- Edit
- Pin/Unpin
- Add to Constellation (submenu)
- Delete

**Technical Approach:**
```
PortalOrbView
├── Orb visualization (existing)
├── Label (existing)
└── Radial Action Arc (NEW)
    ├── Appears on long-press or secondary gesture
    ├── 90° arc around orb (top-right quadrant)
    ├── 3-5 action buttons in arc formation
    └── Dismisses on selection or tap-away
```

**Considerations:**
- visionOS spatial interactions (look + pinch)
- Arc animation (fan out from orb)
- Button sizing for spatial accuracy
- Which quadrant works best ergonomically

### Phase 3.2: Adaptive List View

**Goal:** Auto-reorient list view based on window dimensions

**Current List View:**
- Fixed vertical layout
- Good at narrow width (see attached image)
- Doesn't adapt to landscape

**Target Behavior:**
- **Portrait (narrow):** Vertical list with full rows (current)
- **Landscape (wide):** Horizontal list OR multi-column grid
- **Maintain compact width:** Don't stretch rows to fill space

**Design Options:**

**Option A: Horizontal Scrolling List**
```
Landscape window:
┌────────────────────────────────────────────────┐
│ [Card] [Card] [Card] [Card] → scrolls →        │
└────────────────────────────────────────────────┘
```

**Option B: Multi-Column Grid**
```
Landscape window:
┌────────────────────────────────────────────────┐
│ [Card] [Card] [Card]                           │
│ [Card] [Card] [Card]                           │
│ [Card] [Card] ...                              │
└────────────────────────────────────────────────┘
```

**Option C: Narrow Column with Sections**
```
Landscape window (constellation sections):
┌────────────────────────────────────────────────┐
│ [Quick Access]  [AI Tools]    [Developer]      │
│ ├─ Amazon       ├─ ChatGPT    ├─ GitHub        │
│ ├─ Grok         ├─ Claude     ├─ Supabase      │
│ └─ ...          └─ ...        └─ ...           │
└────────────────────────────────────────────────┘
```

**Recommendation:** Option C aligns with orb view's constellation grouping.

**Technical Approach:**
```
PortalListView
├── GeometryReader (detect orientation)
├── Portrait: Current VStack/List layout
└── Landscape: HStack of constellation sections
    ├── Each section is a vertical ScrollView
    └── Mirrors OrbLinearField sectioned layout
```

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
- **Collapsible/Expand Toggle:** Add ability to collapse/expand ornaments on both left and bottom sides. When collapsed, show minimal indicator; tap to expand. Reduces visual clutter when not actively managing.

### Visual Effects & Immersion
- **Environmental Glow:** In constellation mode, emit a subtle glow from the app that affects the visionOS environment. The constellation's color would cast ambient light into the user's space. Could combine with other aesthetic effects for a more immersive experience.

### Other Potential Features
- Day/night environment toggle (requires visionOS API - currently not exposed)
- Orb size preferences (user-configurable)
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
