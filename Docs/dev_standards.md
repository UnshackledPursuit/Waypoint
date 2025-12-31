# DEV STANDARDS — Waypoint

**Status:** Aligned to Waypoint Spatial Graph Spec v1.0  
**Audience:** Human developers + AI assistants (ChatGPT, Claude, Grok, Gemini)

This document defines mandatory development standards to keep Waypoint consistent, readable, and free of semantic drift.

---

## Canonical Authority

- **Primary:** Waypoint Spatial Graph Spec v1.0
- **Binding Decisions:** DECISIONS.md
- **Execution Rules:** BUILD.md

If any conflict exists, precedence is:
1) Spatial Graph Spec  
2) DECISIONS.md  
3) BUILD.md

---

## Core Axioms (Must Be Preserved in Code)

1. **2 seconds from intent to action, anywhere**
2. **Spatial-first interaction model**
3. **If it’s important enough to interact with, it’s a Node**

Any code or feature that violates these axioms must be revised or deferred.

---

## Canonical Terminology (Mandatory)

| Concept | Canonical Term | Forbidden / Deprecated |
|------|---------------|------------------------|
| Interactive unit | **Node (Orb)** | Item, Tile, Shortcut |
| Action / transition | **Portal** | OpenItem, LaunchItem |
| Saved destination (legacy) | **Destination Node payload** | Portal (as noun) |
| Grouping | **Constellation** | Folder, Category |
| Relationship | **Connection** | Edge (unless rendering graph) |

> **Rule:** Do not invent new synonyms. If a term is not in the Spec, do not introduce it.

---

## File & Type Naming Guidelines

### Swift / Code

- Prefer explicit types:
  - `Node`
  - `DestinationPayload`
  - `Constellation`
  - `PortalAction`

- Legacy compatibility allowed temporarily:
  - `typealias DestinationPayload = Portal` (example)

- Avoid UI-driven naming in models (e.g., `Card`, `Row`).

---

## UI Composition Rules

- All user-facing actions must map to a Node
- No hidden gesture-only actions without a visible Node
- Settings and quick actions are Nodes, not menus

---

## Visual & Interaction Standards

- Orbs are the primary visual metaphor
- Icons/thumbnails are allowed; free-form shapes are not (v1)
- Global intensity slider always applies
- Constellation-scoped color only; no global per-node color

---

## Interaction Contracts (visionOS)

- Gaze = focus
- Pinch = select
- Primary pinch = trigger primary Portal
- Drag & drop = create or reassign Node

Animations must be interruptible and never block interaction.

---

## AI Assistant Rules (Critical)

When using AI assistants:
- Provide the Spatial Graph Spec as context
- Reject suggestions that:
  - Introduce new core terms
  - Bypass Node-based actions
  - Violate the 2-second rule

If unsure, defer to the Spec rather than improvising.

---

## Code Review Checklist

Before merging:
- Terminology matches Spec
- No hidden actions introduced
- Beacon remains fastest path
- Node/Constellation logic is explicit
- Performance impact assessed

---

**End of Dev Standards**

