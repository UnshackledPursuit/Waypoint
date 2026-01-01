## Alignment Notes (v1)
- Terminology aligned to **Waypoint Spatial Graph Spec v1.0**
- Language reconciled with **DECISIONS.md**, **BUILD.md**, and **DEV_STANDARDS.md**
- No feature scope changes; content clarified and cross-referenced only
- Document remains implementation-focused and phase-accurate

---

# WAYPOINT_IMPLEMENTATION_PLAN_MASTER.md
**Date:** 2025-12-31  
**Audience:** You + Claude Code (or any other AI)  
**Purpose:** Single source of truth for near-term execution. Links to supporting design/plan docs.

---

## 0) What we are building
Waypoint is a **launcher + organizer**. No embedded browsing.  
We are implementing the **Orb Sacred Flow** on top of existing managers (no major refactor yet).

**Sacred flow:** **Hub → Expand → Launch → Return**  
- Pinch constellation → animates to center → portals bloom as orbs  
- Pinch portal → launches it  
- Back/pinch outside → return/collapse

---

## 1) Sacred decisions (do not change without explicit decision log)
1. **Keep `PortalManager` + `ConstellationManager`** as canonical truth for now.
2. **Global `Portal.isPinned`** is the pin signal for v1 (no per-constellation pinned yet).
3. **Auto Layout is default** (count-based):
   - n ≤ 6: Linear
   - 7–14: Arc
   - 15–30: Spiral
   - >30: Hemisphere 2.5D
4. **Linear supports drag reorder** (v1). Other layouts respect rank/order but do not require freeform drag v1.
5. **Wormhole Swap** animation triggers **only** when switching constellations in **Linear** layout.
6. Drag/drop must accept **URL + fileURL + text** (provider-based). Clipboard paste remains fallback.
7. **Micro-actions** appear for new portals and duplicates:
   - Open / Assign ▸ / Pin / Edit

---

## 2) Required Documents (read these first)
1. `WAYPOINT_NEXT_IMPLEMENTATION_STEPS.md`  
2. `WAYPOINT_DRAG_DROP_UPGRADE_PLAN.md`  
3. `WAYPOINT_ORB_WORMHOLE_SWAP.md`  
4. `WAYPOINT_PATH_A_EXECUTION_OUTLINE.md` *(older backbone + product spine)*

> If only 4 docs are available, these are sufficient to proceed.

---

## 3) Execution Phases (do in order)

### Phase 1 — Drag & Drop Upgrade (required)
**Goal:** Accept `public.url`, `public.file-url`, `public.text`. Feed into existing DropService portal creation.

**Changes**
- Replace `.dropDestination(for: String.self)` with `.onDrop(of:isTargeted:perform:)` in `PortalListView`.
- Add `DropParser.swift` to extract URLs from `NSItemProvider` payloads.
- Deduplicate URLs; preserve existing batch confirm UX.

**Done when**
- Safari link drop reliably creates portals
- Files PDF drop creates a portal (file URL)

**Risk notes**
- Providers may return Data; handle both URL and UTF-8 string fallback.

---

### Phase 2 — New Portal Micro-Actions + Duplicate Summon
**Goal:** Creation feels premium; duplicates summon existing portal.

**Changes**
- Add transient focus signals in a UI-facing state owner (can live in PortalListView state or a small app state object):
  - `lastCreatedPortalID`
  - `focusRequestPortalID`
- After create: pulse + show micro-actions for ~2s.
- On duplicate add: focus existing + show micro-actions.

**Done when**
- New portals show actions without extra taps
- Duplicate add does not create new portal; it summons original
**Status:** Completed

---

### Phase 3 — Orb Sacred Flow Scaffolding (SwiftUI first)
**Goal:** Hub → Expand → Launch works with Auto layout (no physics dependency).

**Add**
- `OrbSceneState` (hub/expanded/focused + auto layout + filters + focus requests)
- `OrbLayoutEngine` strategies:
  - Linear (vertical/horizontal toggle)
  - Arc
  - Spiral
  - Hemisphere 2.5D
- `OrbHubView`
- `OrbExpandedView` + `OrbTopBar`
- `PortalOrbView` + `ConstellationOrbView`

**Data source**
- Read from existing managers; do not migrate persistence yet.

**Done when**
- Pinch constellation → center expand → show portal orbs → pinch portal opens link
- Layout auto-switches by visible count

---

### Phase 4 — Wormhole Swap (Linear only)
**Goal:** Constellation switching in Linear feels magical + readable.

**Add**
- Swap phases: exitingOld → enteringNew → idle
- Two-layer render (old/new) + top/bottom portal visuals
- Disable interaction during swap

**Done when**
- Switching constellations in Linear triggers swallow/spawn with no accidental launches

---

### Phase 5 — Files (launch docs reliably)
**Goal:** User can launch specific files.

**Start with**
- Accept file URLs from drop
- Open file URL on pinch

**Later**
- Bookmark vs Import decision (security-scoped vs copy into sandbox)

---

## 4) Feasibility Spike Checklist (run after Phase 1)
### Spike A — Drag/drop provider behavior
Test:
- Safari: address bar link drag
- Safari: link on page drag
- Notes: URL drag
- Files: PDF drag
- Photos: image drag

Record:
- which UTTypes arrive
- whether file URLs are accessible
- whether duplicates appear (URL + text)

### Spike B — Wormhole swap performance (after Phase 3 baseline)
Test with 6, 12, 18 orbs.
Confirm:
- stable FPS
- interactions disabled during swap
- animation readability

---

## 5) Handoff instructions for Claude Code
**How to use these docs**
1. Read the 4 required docs listed in section 2.
2. Implement phases in section 3 in order.
3. Maintain a simple `DECISIONS.md` (or append to `PROJECT_STATUS`) with:
   - what changed
   - why
   - what was deferred

**Style guardrails**
- Prefer small PR-like changes per phase.
- Avoid refactors unless needed for the phase.
- Keep services separated (DropParser vs DropService vs UI).

---

## 6) What else needs to happen?
Nothing else is required to start implementation, but recommended:
- Create a `docs/` folder and place all four docs there.
- Add a short `README_DEV.md` that points to this master plan.
- If/when you add file portal support: create a mini spec for bookmark vs import.

---
