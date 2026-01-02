# PROJECT STATUS — January 2026

**Last Updated:** January 2, 2026
**Branch:** main
**Commit:** e9caff9

---

## Executive Summary

Waypoint List View is **production-ready**. The ornament system and Quick Add functionality have been refined through multiple iterations and now provide an excellent user experience for portal management and constellation organization.

**Orb View requires a complete revamp** before it can be considered usable. The current implementation has positioning, scaling, and label overlap issues that make it non-functional for real use.

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
- **Left Ornament:** List/Orb tabs + Paste/Add quick actions
- **Bottom Ornament:** All/Pinned filters + scrollable constellation pills + Launch
- Larger touch targets (36px) for visionOS accuracy
- Hover-reveal labels on constellation pills
- Context menu on constellation pills (Edit/Launch All)
- Launch button: icon-only with constellation color

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

## What Needs Work

### Orb View (Critical - Requires Revamp)

**Current Issues:**
1. Orb positioning algorithms produce overlapping orbs
2. Labels pile up and become unreadable
3. Orbs overflow container boundaries
4. Layout modes (Arc, Spiral, Hemisphere) don't work correctly
5. Scale is wrong relative to container size
6. No clear visual hierarchy

**Root Causes:**
- Layout calculations don't account for actual orb sizes
- No collision detection or minimum spacing
- Container size assumptions are incorrect
- Trying to do too much (multiple layout modes) before one works

---

## Next Phase: Orb View Revamp

### Vision (from user)
> "For orb view, I want the window container to disappear. Just a couple ornaments and the orbs. That is the vision."

### Approach (agreed)
1. **Linear first** - Make one layout work perfectly before adding others
2. **Adaptive orientation** - Vertical when tall, horizontal when wide
3. **Scrollable** - When orbs exceed space, scroll (not shrink/overlap)
4. **Remove arbitrary limits** - No "8 orbs max" rule
5. **First principles** - Rethink from scratch, not patch existing code

### Key Documentation to Reference
- `waypoint_spatial_graph_spec_v_1.md` - Core axioms and node model
- `WAYPOINT_ORB_WORMHOLE_SWAP_v1.md` - Animation concepts for constellation switching
- `decisions.md` - Binding product decisions
- `build.md` - Phase discipline and guardrails

### Design Principles for Orb Revamp
1. **2-second rule** - Must be able to launch any portal in ~2 seconds
2. **Spatial first** - Not just a list in space, true spatial thinking
3. **Nodes are first-class** - Everything important is a node/orb
4. **Stability before complexity** - Ship working code, add features incrementally

---

## File Reference

### Core Views
- `PortalListView.swift` - Main list view (production ready)
- `OrbContainerView.swift` - Orb view container (needs revamp)
- `OrbFieldView.swift` - Orb layout rendering (needs revamp)
- `OrbLayoutEngine.swift` - Layout calculations (needs revamp)
- `PortalOrbView.swift` - Individual orb rendering (review needed)

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
