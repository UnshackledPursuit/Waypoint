# ORB VIEW REVAMP PLAN

**Status:** Planning Phase
**Branch:** feature/orb-revamp (to be created)
**Last Updated:** January 2, 2026

---

## Vision Statement

> "For orb view, I want the window container to disappear. Just a couple ornaments and the orbs. That is the vision."

The Orb View should be a **spatial, immersive way to interact with portals** - not a fancy list. It should feel like looking at stars in a constellation, where you can quickly identify and launch any destination.

---

## Core Principles

### 1. The 2-Second Rule (from Spatial Graph Spec)
If a user knows what they want, they must be able to launch it in ~2 seconds from a stable UI state. This is non-negotiable.

### 2. Linear First
Get one layout working perfectly before attempting others. The Linear layout (vertical/horizontal stack) is the foundation.

### 3. Adaptive, Not Prescriptive
- Vertical when window is tall
- Horizontal when window is wide
- Scrollable when content exceeds space
- No arbitrary limits (remove "8 orbs max")

### 4. Stability Before Complexity
Ship working code. Add features incrementally. Don't patch - rebuild from first principles if needed.

---

## Current State Analysis

### What's Wrong
1. **Positioning math is broken** - Orbs overlap, pile up, overflow boundaries
2. **Layout modes don't work** - Arc/Spiral/Hemisphere produce unusable results
3. **Labels collide** - Text overlaps and becomes unreadable
4. **Scale assumptions wrong** - Orbs too large for container
5. **No collision detection** - Orbs placed without regard to neighbors

### Root Causes
- OrbLayoutEngine calculates positions without knowing actual orb sizes
- Container size assumptions don't match reality
- Multiple layout modes attempted before one works
- Complexity added before stability achieved

---

## Proposed Architecture

### Phase 1: Linear Foundation

**Goal:** A working Linear layout that feels good

**Implementation:**
```
OrbView
├── OrbContainerView (manages state, filtering)
│   └── OrbLinearField (new - replaces OrbFieldView for Linear)
│       ├── ScrollView (vertical or horizontal)
│       │   └── Stack (VStack or HStack)
│       │       └── PortalOrbView (individual orbs)
│       └── No background container (orbs float)
```

**Key Changes:**
1. **Remove ZStack positioning** - Use standard VStack/HStack
2. **Standard spacing** - Let SwiftUI handle layout
3. **Scroll when needed** - ScrollView wraps the stack
4. **Adaptive orientation** - Check container aspect ratio

### Phase 2: Visual Polish

**Goal:** Orbs look beautiful and spatial

**Work Items:**
- Orb sizing (find the right default size)
- Spacing (consistent, comfortable gaps)
- Labels (below orb, on hover, or hidden)
- Glow/shadow effects
- Animation on appear/disappear

### Phase 3: Container-less Mode

**Goal:** The window "disappears"

**Approach:**
- Transparent background on OrbView
- Only ornaments and orbs visible
- Consider ornament positioning adjustments

### Phase 4: Advanced Layouts (Future)

**Only after Linear is perfect:**
- Arc (curved arrangement)
- Grid (for many orbs)
- Spiral/Hemisphere (if ever needed)

---

## Technical Decisions to Make

### Question 1: Orb Size
- Current: ~70-80px
- Options: Fixed size, user preference, adaptive based on count?
- Recommendation: Start with 60px fixed, adjust based on testing

### Question 2: Spacing
- Current: Calculated dynamically (causing issues)
- Options: Fixed spacing, proportional, minimum constraint?
- Recommendation: Fixed 16px spacing in Linear mode

### Question 3: Labels
- Current: Always visible (causing overlap)
- Options: Always visible, hover-only, below orb, hidden?
- Recommendation: Below orb, truncated, or hover-only

### Question 4: Scroll Direction
- When vertical: scroll vertically
- When horizontal: scroll horizontally
- Threshold: width > height * 1.3 = horizontal

### Question 5: Empty State
- Current: "No portals yet" message
- Keep or replace? Keep, but style appropriately

---

## Implementation Checklist

### Phase 1: Linear Foundation
- [ ] Create OrbLinearField.swift (new file)
- [ ] Implement vertical stack with VStack
- [ ] Implement horizontal stack with HStack
- [ ] Add orientation detection (aspect ratio check)
- [ ] Add ScrollView wrapper
- [ ] Wire up to OrbContainerView
- [ ] Remove old OrbFieldView dependency
- [ ] Test with various portal counts (1, 5, 10, 20)

### Phase 2: Visual Polish
- [ ] Determine optimal orb size
- [ ] Set consistent spacing
- [ ] Fix label positioning (avoid overlap)
- [ ] Add subtle animations
- [ ] Test in different lighting conditions

### Phase 3: Container-less Mode
- [ ] Remove/hide OrbContainerView background
- [ ] Adjust ornament positioning if needed
- [ ] Test visual coherence

### Phase 4: Integration
- [ ] Ensure filtering works (All, Pinned, Constellation)
- [ ] Ensure Launch from ornament works
- [ ] Test constellation switching
- [ ] Consider Wormhole Swap animation (future)

---

## Ideas from Documentation

### From waypoint_spatial_graph_spec_v_1.md
- **Beacon Mode** is meant for fast execution (8 visible nodes target)
- **Galaxy Mode** is for spatial exploration within a constellation
- Gaze focuses, pinch selects, primary pinch triggers action
- Expansion persists with attention; collapse on explicit intent

### From WAYPOINT_ORB_WORMHOLE_SWAP_v1.md
- Constellation switching animation: bottom portal swallows old, top portal spawns new
- Duration target: 0.45-0.70s
- Disable interactions during animation
- Only for Linear layout (not filtering chips)

### From decisions.md
- "Launch All" is a Node, not a hidden button
- Constellation Action Nodes are explicit
- Global Intensity Slider controls orb brightness
- Color is constellation-scoped, not global

---

## Questions for Collaborative Discussion

1. **Should orbs have a fixed size or adapt?**
   - Fixed is simpler and more predictable
   - Adaptive could fit more but may feel inconsistent

2. **Where should labels be?**
   - Below orb (always visible, needs space)
   - On hover (cleaner, but less discoverable)
   - Inside orb (limited by size)

3. **When should we show the container vs. just orbs?**
   - Always container-less?
   - Container in List, container-less in Orb?
   - User preference toggle?

4. **Should constellations have a "center orb" anchor?**
   - The Wormhole Swap doc mentions keeping center orb fixed
   - Could be the constellation's "hub" concept

5. **What about very large portal counts (50+)?**
   - Linear scroll works but may be tedious
   - Grid layout would be more efficient
   - Or auto-switch to Grid above threshold?

---

## Success Criteria

The Orb View revamp is complete when:

1. **Linear layout works perfectly** - No overlaps, no label collisions
2. **Orientation adapts** - Vertical when tall, horizontal when wide
3. **Scrolling works** - Can scroll to see all orbs when they exceed space
4. **Filtering works** - All, Pinned, and Constellation filters apply correctly
5. **Launch works** - Can tap any orb to launch, Launch button works
6. **Feels spatial** - Not just a rotated list, but a true orb experience
7. **Meets 2-second rule** - Can launch any known portal in ~2 seconds

---

## Files to Modify/Create

### New Files
- `OrbLinearField.swift` - New Linear layout implementation

### Modify
- `OrbContainerView.swift` - Simplify, use new OrbLinearField
- `PortalOrbView.swift` - Review sizing and label handling
- `OrbSceneState.swift` - Simplify state if needed

### Potentially Remove/Deprecate
- `OrbFieldView.swift` - Replace with OrbLinearField
- `OrbLayoutEngine.swift` - Simplify or remove complex layouts

### Keep As-Is
- `OrbExpandedView.swift` - Review after Linear works
- `OrbTopBar.swift` - May need adjustment
- `OrbHubView.swift` - Review after Linear works

---

**End of Plan**
