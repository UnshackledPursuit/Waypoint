# DECISIONS — Waypoint

**Status:** Aligned to Waypoint Spatial Graph Spec v1.0  
**Last Updated:** Today

This document records binding product and architectural decisions. It does not restate implementation detail; it declares *what is true* so downstream documents and code remain consistent.

---

## Canonical Authority

The **Waypoint Spatial Graph Spec v1.0** is the single source of truth for core concepts, terminology, and interaction contracts. If a conflict exists, the Spec prevails.

---

## Core Axioms (Non‑Negotiable)

1. **Waypoint = a quick‑access hub to the digital universe**
2. **2 seconds from intent to action, anywhere**  
   If a user knows what they want, they can launch it in ~2 seconds from a stable UI state.
3. **If it’s important enough to interact with, it’s a Node**  
   All meaningful interactions (content, actions, settings) are represented as Nodes.

These axioms govern design, docs, and code.

---

## Terminology Lock (Authoritative)

- **Node (Orb):** Fundamental interactive unit.
- **Portal:** An action/transition (verb), not a saved item.
- **Constellation:** Contextual grouping of Nodes.
- **Connection:** Semantic relationship (implicit in Phase 1).

> **Legacy Note:** Prior usage of “Portal” to mean a saved destination is deprecated conceptually. Existing code may temporarily retain the name for compatibility.

---

## Presentation Modes

- **Beacon (Phase 1 primary):** Fast execution; bounded list/stack; minimal motion.
- **Galaxy (Phase 2):** Spatial exploration within a constellation.
- **Universe (Phase 3):** Macro overview; calm, low‑density; selection over editing.

---

## Node Model Decisions

- Nodes are first‑class for **content and actions** (no hidden menus).
- **Constellation Action Nodes** are explicit Nodes revealed on expansion, including:
  - Launch All
  - Constellation settings (rename, color, order)
  - Organization (add/remove/reorder)
- “Launch All” is a Node with a primary Portal; it is not the default tap on a constellation.

---

## Color & Visual Intensity

- **Global Intensity Slider (Required):** Controls overall brightness/saturation for all Orbs.
- **Constellation‑Scoped Color (Optional):**
  - A constellation may define no color (neutral), one primary color, and up to two sub‑colors.
  - Color is contextual, not global.
- **Node Color Assignment (Scoped):**
  - Within a constellation, a Node may inherit primary color, use sub‑color A/B, or opt out (neutral).
  - Node colors do **not** persist across constellations.
- The **All** constellation defaults to neutral (no color).

---

## Visual Identity

- Nodes may display app icons, favicons, thumbnails, or text fallback.
- Free‑form shape systems are out of scope for v1.

---

## Interaction & Behavior

- Gaze focuses; pinch selects; primary pinch triggers the Node’s primary Portal.
- Drag & drop creates Destination Nodes.
- Constellation expansion persists with attention; collapse occurs on explicit intent; animations are interruptible.

---

## Phase Discipline

- **Phase 1:** Beacon‑first, stability, drag & drop, explicit action Nodes, terminology discipline.
- **Phase 2:** Galaxy layouts, richer spatial grouping.
- **Phase 3:** Universe overview; optional visible connections.

---

## Compatibility & Migration

- Phase 1 preserves existing data models where needed (e.g., legacy `Portal`).
- Refactors and renames occur after doc alignment (Step 4), with compatibility bridges as required.

---

## Explicit Non‑Goals (Phase 1)

- Full visible graph webs
- Global per‑node color overrides
- Free‑form shapes
- Runtime AI‑generated structure

---

**End of Decisions**

