# BUILD — Waypoint

**Status:** Aligned to Waypoint Spatial Graph Spec v1.0  
**Last Updated:** Today

This document defines how Waypoint is built and phased. It translates binding decisions into execution without redefining core concepts.

> **Canonical Reference:** All core concepts and terminology are defined in **Waypoint Spatial Graph Spec v1.0**. This document defers to the Spec where applicable.

---

## Build Philosophy

Waypoint is built incrementally with strict scope discipline:
- Preserve the **2‑second intent‑to‑action rule** at all times
- Ship stability before complexity
- Add spatial richness only when it does not compromise execution speed

The build prioritizes *usable reality* over speculative features.

---

## Phase Overview

### Phase 1 — Beacon‑First MVP (Current Focus)

**Primary Goal:** Fast, reliable access to destinations using a Node‑based model.

**Core Characteristics:**
- Beacon is the primary interaction mode
- Nodes (Orbs) represent destinations and actions
- Constellations group Nodes contextually
- Minimal motion; predictable behavior

**Phase 1 Must‑Have Features:**
- Destination Nodes (legacy Portal payloads)
- Constellation Nodes (expandable)
- Explicit Constellation Action Nodes (e.g., Launch All)
- Drag & drop to create Destination Nodes
- Stable ordering and selection
- Terminology consistency with the Spec

**Out of Scope (Phase 1):**
- Full visible graph webs
- Complex spatial layouts
- Global per‑node color overrides
- AI‑generated structure

---

### Phase 2 — Galaxy View Expansion

**Primary Goal:** Improve spatial understanding *within* a constellation.

**Adds:**
- Orbital/radial layouts
- Anchor Nodes
- Visual grouping and inspection

**Constraints:**
- Beacon remains the fastest execution path
- Galaxy does not replace Beacon for speed‑critical workflows

---

### Phase 3 — Universe Overview

**Primary Goal:** Macro navigation across constellations.

**Adds:**
- Constellations as clusters
- Optional visible connections when zoomed/focused

**Constraints:**
- Universe favors overview and selection, not editing
- Density remains controlled to preserve calm

---

## Node Model (Execution Mapping)

### Destination Nodes

- Represent URLs, apps, or file references
- Primary Portal: **Open**
- Backed by existing legacy `Portal` data models in Phase 1

> **Compatibility Note:** Existing `PortalManager` and `Portal` structs remain valid as Destination Node payloads until Step 4 refactor.

---

### Constellation Nodes

- Represent contextual groupings
- Primary Portal: **Expand / Open**
- Expansion reveals a branch containing:
  - Launch All Node
  - Constellation settings Nodes
  - Organizational Nodes
  - Member Nodes

---

### System Nodes

- Settings, environment toggles, help
- Primary Portal: open system view

---

## Color & Visual Intensity (Build Implications)

- Implement **Global Intensity Slider** early (Phase 1)
- Constellation color is optional and scoped
- Node color selection is constellation‑scoped only
- Neutral (frosted) rendering is the baseline

No global per‑node color persistence is implemented in Phase 1.

---

## Interaction Contract (Phase 1)

- Gaze to focus
- Pinch to select
- Primary pinch triggers Node’s primary Portal
- Drag external items to create Destination Nodes
- Drag internal Nodes to reorder or reassign

Animations must be interruptible and must not delay interaction.

---

## Data & Migration Strategy

- Preserve existing schemas during Phase 1
- Use conceptual mapping rather than forced renames
- Defer structural refactors until documentation alignment is complete (Step 4)

---

## Build Guardrails

- If a feature risks violating the 2‑second rule, it is deferred
- If terminology conflicts with the Spec, it is corrected
- If a feature introduces hidden actions, it is rejected

---

**End of Build**

