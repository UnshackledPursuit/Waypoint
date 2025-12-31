# WAYPOINT SPATIAL GRAPH SPEC v1.0

**Status:** Definitive v1.0 (approved for downstream doc alignment)

**Applies to:** Waypoint Phase 1–3 architecture, UI, interaction model, terminology, and code alignment

---

## 0. Product Definition

**Waypoint = a quick‑access hub to the digital universe**

Waypoint is a visionOS‑native spatial system for organizing, recalling, and launching digital destinations using a graph of interactive **Nodes (Orbs)** grouped into **Constellations**, navigated through multiple presentation modes.

---

## 1. Core Axioms (Foundational — Non‑Negotiable)

1. **2 seconds from intent to action, anywhere**  
   If a user knows what they want, they must be able to launch it in ~2 seconds from a stable UI state.

2. **Spatial first, not flat UI in space**  
   Waypoint prioritizes spatial memory, depth, and object permanence over panels and lists.

3. **If it’s important enough to interact with, it’s a Node**  
   All meaningful interactions (content, actions, settings, launch behaviors) are represented as Nodes.

These axioms govern *all* design, documentation, and implementation decisions.

---

## 2. Canonical Terminology

### 2.1 Node (Orb)
A **Node** is the fundamental interactive unit in Waypoint, visually represented as a glass‑like orb.

A Node always has:
- Stable identity (`id`)
- Type (what it represents)
- Payload (data or target)
- One primary **Portal** action
- Visual state (idle / focused / selected)
- Membership in one or more Constellations

---

### 2.2 Portal (Action)
A **Portal** is an *action or transition*, not a saved item.

Examples:
- Open destination
- Expand constellation
- Launch all
- Edit settings

> **Important:** Legacy usage of the term “Portal” to mean a saved destination is deprecated conceptually. Existing code may temporarily retain the name for compatibility.

---

### 2.3 Constellation
A **Constellation** is a named contextual grouping of Nodes (e.g., Work, AI, Media, Reading).

Constellations define:
- Context
- Optional color scheme
- Default ordering (Beacon)
- Expansion behavior

---

### 2.4 Connection (Relationship)
A **Connection** is a semantic relationship between Nodes.

- Phase 1: implicit / conceptual
- Phase 3+: optionally visible when zoomed or focused

Connections are never required to satisfy the 2‑second rule.

---

## 3. Presentation Modes

### 3.1 Beacon Mode (Phase 1 Primary)

**Purpose:** Fast execution and stability.

- Bounded list/stack of Nodes (target: ~8 visible)
- Predictable ordering
- Minimal motion

Required Phase 1 behaviors:
- Select Node
- Trigger primary Portal
- Drag & drop to create Nodes
- Expand constellation Nodes

---

### 3.2 Galaxy Mode (Phase 2)

**Purpose:** Exploration and spatial grouping within a constellation.

- Orbital / radial spatial layouts
- Anchor Nodes supported
- Visual grouping and inspection

---

### 3.3 Universe Mode (Phase 3)

**Purpose:** Macro overview of Constellations.

- Constellations appear as clusters
- Detail deferred to Galaxy/Beacon
- Calm, low‑density presentation

---

## 4. Node Taxonomy

### 4.1 Required Node Types (Phase 1)

1. **Destination Node**  
   Payload: URL, app target, or file reference  
   Primary Portal: Open

2. **Constellation Node**  
   Represents a Constellation itself  
   Primary Portal: Expand / Open

3. **System Node**  
   Settings, environment, help  
   Primary Portal: Open system view

---

### 4.2 Optional Node Types (Phase 2+)

- Agent Node (AI entry)
- Concept Node (ideas/topics)
- Temporal Node (events/deadlines)
- Collection Node (contains Nodes)

---

## 5. Constellation Action Nodes

When a Constellation Node is expanded, it reveals a **branch** containing:

- **Launch All** Node (primary Portal: launch all child Nodes)
- Constellation Settings Nodes (rename, color, order)
- Organizational Nodes (add/remove/reorder)
- Member Nodes

All constellation actions are Nodes. No hidden menus.

---

## 6. Color & Visual Intensity System

### 6.1 Global Intensity Slider (Required)

A global slider controls brightness and saturation for *all* orbs:

- Lowest: frosted neutral
- Highest: vivid and expressive

This setting always applies.

---

### 6.2 Constellation‑Scoped Color (Optional)

A Constellation may define:
- No color (neutral / frosted)
- One primary color
- Up to two sub‑colors

Color is contextual, not global.

---

### 6.3 Node Color Assignment (Scoped)

Within a Constellation, a Node may be assigned:
- Primary color
- Sub‑color A or B
- No color (neutral)

Node colors do **not** persist across constellations.

---

## 7. Node Visual Identity

Nodes may display:
- App icons
- Favicons
- Thumbnails
- Text fallback

Visual identity is supported; free‑form shape systems are explicitly out of scope for v1.

---

## 8. Interaction Model (visionOS)

- **Gaze:** focus / reveal label
- **Pinch:** select
- **Pinch (primary):** trigger Portal
- **Drag:** reorder or reassign
- **Drop external item:** create Destination Node

---

## 9. Expansion & Collapse Behavior

- Expansion persists while attention persists
- Collapse occurs on explicit user intent (select elsewhere)
- Animations must be interruptible

---

## 10. Data Model Compatibility

Phase 1 maintains compatibility with existing models:

- Legacy `Portal` struct maps to Destination Node payload
- `portalIDs` map conceptually to `nodeIDs`

Renaming/refactors occur in Step 4 (post‑doc alignment).

---

## 11. Phase 1 Acceptance Criteria

A build is compliant if:
1. Nodes are reachable within ~2 seconds
2. Beacon is stable and usable as primary UI
3. Drag & drop creates launchable Nodes
4. Constellation expansion is clear and reversible
5. Terminology matches this spec

---

## 12. Explicit Non‑Goals (Phase 1)

- Full visible graph web
- Global per‑node color overrides
- Free‑form shapes
- AI‑generated structure at runtime

---

**End of Spec — v1.0**

