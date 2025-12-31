# DECISIONS.md — Waypoint Decision Log
**Purpose:** Record product/architecture decisions so future changes are intentional and traceable.  
**Rule:** Any change to a “sacred decision” requires a new entry.

---

## Template (copy/paste)
### [YYYY-MM-DD] Decision: <short title>
**Status:** Accepted | Proposed | Reversed  
**Context:**  
- What problem were we solving?

**Decision:**  
- What did we choose?

**Rationale:**  
- Why this over alternatives?

**Consequences:**  
- What becomes easier?
- What becomes harder / deferred?

**Follow-ups / TODO:**  
- Next actions

---

## Decisions

### [2025-12-31] Decision: Ship Path A spine with Orb-first sacred flow
**Status:** Accepted  
**Context:** Need a shippable launcher core while still achieving spatial “wow” without rewrite risk.  
**Decision:** Keep Path A architecture (managers as truth), implement Orb sacred flow as an alternate renderer.  
**Rationale:** Avoid RealityKit/physics complexity early; keep iteration fast; preserve existing Phase 2 work.  
**Consequences:** Orb module must remain decoupled (layout + interaction separate from data).  
**Follow-ups / TODO:** Implement OrbSceneState + OrbLayoutEngine after Drag/Drop upgrade.

### [2025-12-31] Decision: No embedded web browsing
**Status:** Accepted  
**Context:** Embedded windows are unstable/complex and not core to launcher value.  
**Decision:** Skip embedded browsing entirely. Launch externally instead.  
**Rationale:** Reduces bugs and scope; aligns with “2 seconds to anywhere.”  
**Consequences:** Need strong capture/recall and fast open behaviors.  
**Follow-ups / TODO:** Improve recents + search + launch set staging.

### [2025-12-31] Decision: Auto layout as default for Expanded constellation
**Status:** Accepted  
**Context:** Users will build link-by-link; layout must adapt gracefully as count grows.  
**Decision:** Default layout mode = Auto (count-based), with optional per-constellation override later.  
**Rationale:** Best balance of readability + wow + low friction.  
**Consequences:** Layout engine must support deterministic strategies.  
**Follow-ups / TODO:** Implement Linear/Arc/Spiral/Hemisphere 2.5D.

### [2025-12-31] Decision: Linear stack supports drag reorder (v1)
**Status:** Accepted  
**Context:** Reordering is critical, but freeform drag in non-linear layouts adds complexity.  
**Decision:** Enable true drag reorder in Linear; other layouts respect ordering but defer direct manipulation.  
**Rationale:** Stable v1 behavior; reorder where it’s most intuitive.  
**Consequences:** Need clear UX for “reorder mode” in other layouts later if desired.  
**Follow-ups / TODO:** Persist order via existing sortIndex or membership ordering upgrade later.

### [2025-12-31] Decision: Global pinning is the v1 pin signal
**Status:** Accepted  
**Context:** Existing Portal.isPinned works and is already integrated.  
**Decision:** Use global Portal.isPinned to influence placement across layouts (prime positions).  
**Rationale:** No data migration required; immediate UX value.  
**Consequences:** Per-constellation pinning deferred; may be added via membership struct later.  
**Follow-ups / TODO:** Define pinned placement rules per layout.

### [2025-12-31] Decision: Wormhole swap animation only in Linear constellation switching
**Status:** Accepted  
**Context:** Swap animation can confuse if applied to filtering/reordering or complex 3D.  
**Decision:** Trigger WormholeSwap only when switching constellations in Linear layout.  
**Rationale:** Maximum clarity, minimum risk, highest delight.  
**Consequences:** Need fallback for large counts (crossfade/top-drop only).  
**Follow-ups / TODO:** Implement swap phases after Orb baseline is stable.

### [2025-12-31] Decision: Drag & drop upgrade is gating for “foundational” visionOS feel
**Status:** Accepted  
**Context:** Current drop handling accepts only Strings, limiting Safari/Files drop reliability.  
**Decision:** Upgrade to provider-based drop parsing for URL + fileURL + text.  
**Rationale:** Unlocks native workflows; also enables file portals later.  
**Consequences:** Must handle duplicates and mixed payload types (URL+text).  
**Follow-ups / TODO:** Implement DropParser and update PortalListView drop target.
