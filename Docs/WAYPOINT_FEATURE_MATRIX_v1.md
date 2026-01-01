# Waypoint — Feature Matrix (v1)

This document is the authoritative feature inventory for Waypoint v1.
It reflects **Waypoint Spatial Graph Spec v1.0**, DECISIONS.md, BUILD.md,
and all confirmed implementation discussions.

---

## ✅ Core v1 Features

### Product Identity
- Launcher + organizer (not a browser)
- “2 seconds to anywhere” mental model
- Zero-maintenance capture and recall
- Spatial UX is additive, not required

---

### Core Entities
- **Portal**
  - Launchable target (URL, file, future deep link)
  - Icon support (favicon / app icon / thumbnail)
  - Pin, edit, assign to constellation
- **Constellation**
  - Grouping of portals
  - Can be pinned to Hub
  - Drives layout and swap behavior
- **Orb**
  - Spatial renderer for portals and constellations
  - Visual/interaction layer only

---

### Capture (Input)
- Clipboard paste → portal
- Manual add (text input)
- URL scheme routing (Shortcuts / automation)
- Drag & Drop (provider-based)
  - Accepts: public.url, public.file-url, public.text
  - Deduplication logic
  - Batch confirmation UX
  - Status: Implemented (Phase 1)
- Clipboard fallback always available

---

### Recall (Finding Things)
- Global search (name, domain, constellation)
- Recents view (true last-opened)
- Pinned portals
- Pinned constellations
- Constellation picker

---

### Launch
- Tap / pinch to launch portal
- Launch from list or orb
- Optional launch constellation (with confirmation)
- Native app behavior respected

---

### Orb Sacred Flow (Spatial UX)
- Canonical flow: Hub → Expand → Launch → Return
- Hub shows pinned constellations
- Pinch constellation → expand
- Portals bloom as orbs
- Back / pinch outside → collapse

---

### Orb Layout System (Auto)
- Auto-selected by visible count:
  - ≤6 → Linear
  - 7–14 → Arc
  - 15–30 → Spiral
  - >30 → Hemisphere 2.5D
- Layouts respect ordering
- Linear layout supports drag reorder (v1)

---

### Micro-Interactions
- Micro-actions on portal creation:
  - Open
  - Assign ▸
  - Pin
  - Edit
- Duplicate portal detection:
  - Summon existing instead of creating duplicate
  - Show micro-actions
  - Status: Implemented (Phase 2)

---

### Wormhole Swap (Linear Only)
- Used when switching constellations
- Bottom portal swallows old orbs
- Top portal spawns new orbs
- Interaction disabled during animation
- Gated to Linear layout

---

### Files (v1)
- Accept file URLs via drag & drop
- Launch files via system handlers
- File portals treated as launch targets

---

### Architecture Guardrails
- One canonical app state model
- PortalManager / ConstellationManager remain boring (CRUD + persistence)
- Renderers are interchangeable (List / Beacon / Orb)
- Services isolated (DropParser, URL sanitization, etc.)

---

## ⏸ Deferred Features (Intentionally Deferred)

- Share extensions (visionOS instability)
- Embedded browsers / web views
- Full Universe / physics-driven spatial map
- Multi-device sync
- Advanced constellation customization rules
- File import management UI
- Bookmark vs import decision UI
- Per-constellation layout overrides
- Rich tagging / metadata systems
- Advanced color / intensity systems

---

## ❌ Explicitly Out of Scope (v1 Non‑Goals)

- Replacing Safari or Files.app
- In-app browsing
- Heavy document management
- Mandatory spatial UX
- Mandatory drag & drop dependency
- Physics-heavy interactions as a requirement
- Complex rule engines for constellation behavior
- Early performance-risk features

---

## Status
This feature matrix is **v1-locked** and should be treated as the reference
for:
- Engineering scope
- QA validation
- AI coding agent alignment
- Future roadmap diffs
