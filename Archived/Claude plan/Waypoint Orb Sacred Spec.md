# Waypoint Orb Sacred Spec  
  
# Waypoint — Orb Sacred Flow Spec (Auto Layout + New Portal Actions + Reorder + Pin)  
**Date:** 2025-12-31    
**Goal:** Implement a single sacred flow (**Hub → Expand → Launch**) with **Orb-first wow** while keeping Path A stability (canonical data + deterministic UI).  
  
---  
  
## 1) Sacred Flow (State Machine)  
  
### Modes  
- **Hub**  
  - Shows **Pinned Constellations** (big targets/orbs)  
  - Global actions: Search / Paste / Add / Recents  
- **Expanded(constellationID)**  
  - Selected constellation animates to center  
  - Portals render as orbs using **Auto layout**  
  - Quick filter ornaments appear (type/pinned/recent)  
- **Focused(portalID, constellationID?)**  
  - Orb pulses + moves into comfortable view  
  - Shows micro-actions (Open / Assign / Pin / Edit)  
  
### Events → Transitions  
- pinchConstellation(id):  
  - Hub → Expanded(id)  
  - Expanded(other) → Expanded(id) (switch)  
- pinchPortal(id):  
  - Expanded → Launch portal  
- longPinchPortal(id):  
  - Expanded → Focused(id)  
- back() or pinchOutside():  
  - Focused → Expanded  
  - Expanded → Hub  
  
---  
  
## 2) Auto Layout Selection (Count-based)  
**Default:** Auto  
  
### Supported Layout Styles (v1)  
1. **Linear Stack** (vertical/horizontal toggle) — supports drag reorder  
2. **Arc**  
3. **Spiral**  
4. **Hemisphere 2.5D** (sphere-grid prototype)  
  
### Auto Rule  
Let n = visible portal count (after filters):  
- n ≤ 6: Linear  
- 7–14: Arc  
- 15–30: Spiral  
- >30: Hemisphere 2.5D (or Spiral + paging)  
  
**Override:** user can cycle layout in Expanded mode; store per-constellation override.  
- constellation.layoutOverride: LayoutStyle?  
- When nil: use Auto  
  
---  
  
## 3) New Portal Creation UX (Elegant defaults + micro-actions)  
  
### A) Default placement (always automatic)  
On create (Paste/Add/Drop):  
1. If inside Expanded(constellationID): add to that constellation  
2. Else: add to Inbox/Unsorted constellation (always exists)  
  
### B) Micro-actions (for NEW portals too)  
After create, pulse orb and show:  
- Open  
- Assign ▸  
- Pin  
- Edit  
Auto-hide ~2s; reappear on long pinch.  
  
### C) Assign suggestions (3 options)  
Assign shows:  
1) Current constellation or Inbox  
2) Most recent constellation  
3) Best match (domain/tags later/pinned priority)  
Plus “Choose…”  
  
---  
  
## 4) Duplicate Add Behavior (Summon + Actions)  
If canonical URL already exists:  
- Do not create a new portal  
- Focus the existing orb (pulse + bring into view)  
- Show micro-actions:  
  - Open  
  - Add to Constellation ▸  
  - Pin  
  - Edit  
  
---  
  
## 5) Ordering, Reorder, and Pinning  
  
### Data model (per constellation membership)  
ConstellationMembership:  
- constellationID  
- portalID  
- rank: Double  
- isPinned: Bool  
  
Sort:  
1) pinned first  
2) then rank  
  
### Reorder rules  
- Linear: full drag reorder → update rank  
- Arc/Spiral/Hemisphere: rank-driven placement; defer freeform drag initially  
  
### Pin placement  
- Linear: pinned section at top  
- Arc: pinned occupy prime arc segment near center/top  
- Spiral: pinned start at spiral origin  
- Hemisphere: pinned placed in front/top band  
  
---  
  
## 6) Quick Filter Ornaments (Expanded only)  
Chips filter visiblePortals (not membership):  
- All  
- Web  
- Files  
- Pinned  
- Recent  
- (later) Tags  
  
Auto layout uses visible count.  
  
---  
  
## 7) Color Policy (v1)  
Default:  
1) favicon dominant color  
2) fallback: constellation theme  
3) fallback: type-based  
  
Apply to orb glow + ring + selection pulse.  
  
---  
  
## 8) Build Order (exact)  
1) OrbSceneState (hub/expanded/focused + auto layout + filters + focus requests)  
2) OrbLayoutEngine (Linear → Arc → Spiral → Hemisphere 2.5D)  
3) OrbFieldView (renders orbs; camera offset for “summon into view”)  
4) Expand animator (constellation to center + bloom)  
5) Top bar (Back / Layout Cycle / Flip (Linear) / Launch Set)  
6) PortalOrb + ConstellationOrb (color policy + pulses)  
7) MicroActionRow (Open / Assign / Pin / Edit)  
8) Rank utilities (drag reorder + pinned placement)  
9) Filter chips ornaments  
10) Launch Set (N) confirm behavior  
  
---  
  
## 9) Launch Set (N)  
- N ≤ 3: launch immediately  
- N > 3: confirm:  
  - Launch All  
  - Launch First 3  
  - Open Beacon Tray  
  
---  
