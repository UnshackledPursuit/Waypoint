# Waypoint — Path A Execution Outline (with Orb Upgrade + Drag/Drop + Files)  
**Scope:** Ship a *fast launcher* first (Path A spine) while building Orbs as an alternate renderer so Path B becomes an upgrade, not a rewrite.  
  
> Phase 2 is complete (Quick Paste/Add, Constellations, filtering, sorting, URL scheme).  
  
> 
> Embedded windows: **explicitly out of scope**.  

⸻  
## 0) North Star  
Waypoint should feel like:  
- **2 seconds to anywhere**  
- **Zero maintenance friction**  
- **Spatial delight is additive**, not required for daily use  
  
**Non-goals (for now)**  
- In-app browsing / embedded web views  
- “Replace Safari” behavior  
- Heavy file management (Waypoint is a launcher, not Files.app)  
⸻  
## 1) Product Spine (Path A)  
### A) Capture  
- Quick Paste (clipboard → portal)  
- Quick Add (text input → portal)  
- URL scheme routes (Shortcuts / automation)  
- **Bonus**: Drag & Drop (when reliable)  
  
### B) Recall  
- Search (name, domain, constellation)  
- Recents (last-opened is a first-class view)  
- Pinned (portals and constellations)  
- Constellation Picker (fast jump)  
  
### C) Launch  
- Tap/pinch to open  
- Constellation launch (optional confirm)  
- Quick Start presets  
  
### D) Spatial Layer (delight)  
- Orbs renderer (PortalOrb)  
- Beacon / “Now” tray (selected constellation)  
- Later: Galaxy/Universe as additional renderers  
⸻  
## 2) App Layout (Path A default)  
### Primary: Waypoint Panel  
- Search bar (always visible)  
- Quick actions row: **Paste**, **Add**, **Pick Constellation**, **Recents**  
- List: All / Pinned / Recent / Constellation  
- “Pinned Constellations” section (hub candidates)  
  
### Optional: Beacon Tray (Orb strip)  
- Shows orbs for current constellation (or pinned set)  
- Tap/pinch launches  
⸻  
## 3) Architecture Guardrails (so Path B doesn’t force a rewrite)  
### One canonical state model  
- ==selectedConstellationID==  
- ==activeFilter== (all/pinned/recent/constellation)  
- ==activeSort== (custom/recent/name)  
- ==viewMode== (list/beacon/galaxy/universe)  
  
### Managers stay boring  
- ==PortalManager== / ==ConstellationManager==: CRUD + persistence + computed views  
  
### Services layer (small, strong)  
- ==URLSanitizer== (youtube → [https://youtube.com](https://youtube.com))  
- ==FaviconService== (cache + dominant color)  
- ==URLSchemeRouter== (inbound add/open/launch)  
  
### Renderers  
- ==ListRenderer==  
- ==BeaconRenderer==  
- ==OrbRenderer== (PortalOrb + ConstellationOrb)  
- (Later) ==GalaxyRenderer==, ==UniverseRenderer==  
⸻  
## 4) “Hub” via Pinned Constellations (bridges Path A → Path B)  
Add a ==isPinnedToHub== flag on Constellation.  
- Hub view shows pinned constellations as large buttons or orbs  
- Gaze + pinch expands constellation → shows its portals (as orbs or list)  
- Second pinch launches selected portal  
  
**Why this matters:** you get “wow” interaction without committing to a full spatial rewrite.  
⸻  
⸻  
## 5) Drag & Drop (visionOS) — incorporate without betting the app on it  
### Reality check  
Drag & drop from Safari can be flaky. Treat it as:  
- **Bonus input** when it works  
- Not the primary capture path  
  
### UX pattern (reliable + obvious)  
- Always show a **large drop zone** in the panel (or a “Drop to Add” overlay button)  
- Visual highlight when targeted  
- On drop: create portal(s) and show a toast:  
    - “Added ✓  Assign to Constellation ▸”  
  
### Technical approach (recommended)  
Use classic ==.onDrop== / ==DropDelegate== with ==NSItemProvider==:  
- Accept types: ==public.url==, ==public.text==, ==public.file-url==, ==public.item==  
- Parse priority:  
    1. URL  
    2. Text → detect URL in text  
    3. File URL / file representation  
  
**Key reliability tricks**  
- Ensure drop target has a real hit area (==contentShape==, explicit frame)  
- Use ==isTargeted== to show feedback  
- Accept multiple item providers (multi-drop)  
- Debounce duplicates (Safari often provides URL + text)  
  
### Success criteria  
- ≥90% success drag from Safari  
- Clear feedback + fallback to clipboard always available  
⸻  
## 6) Files support (launch documents/photos/etc.)  
You have two viable strategies:  
  
### Strategy A — Security-scoped bookmarks (link to original)  
Best when user wants “this exact file in iCloud Drive”.  
- Use ==fileImporter== / Document Picker to select files  
- Persist bookmark data (security-scoped)  
- On launch: resolve bookmark → ==startAccessingSecurityScopedResource()== → open  
  
**Pros:** no duplication  
  
**Cons:** more edge cases; user can revoke/move files  
  
### Strategy B — Import into Waypoint (copy into app container)  
Best for “drag in and launch forever”.  
- On drop (or import): ==loadFileRepresentation== then copy into app container  
- Store internal path + metadata  
- Launch local file URL  
  
**Pros:** rock-solid, fast  
  
**Cons:** storage use (needs management UI later)  
  
### Recommendation  
- Implement **A first** via fileImporter (fast, standard)  
- Add **B as an option on drag/drop** (“Import to Waypoint”)  
  
### Portal types  
- ==webURL==  
- ==fileBookmark== (security-scoped)  
- ==appIntent== / deep link (future)  
⸻  
## 7) Near-term build sequence (tight, shippable)  
### Step 1 — Recall upgrades (high ROI)  
- Search across portals + constellations  
- Recents view (true last-opened)  
- Pinned portals + pinned constellations  
- Constellation picker affordance (not buried)  
  
### Step 2 — Hub pinned constellations  
- ==HubView== + pinned section  
- Gaze/pinch to expand constellation  
  
### Step 3 — Orb renderer (wow without chaos)  
- ==PortalOrb== (icon + label + tap/pinch launch)  
- ==ConstellationOrb== (opens expanded view)  
- Beacon tray (current constellation → orb strip)  
  
### Step 4 — Drag & drop (bonus input)  
- Implement drop zone + provider parsing  
- Add “Assign to Constellation” post-drop toast  
  
### Step 5 — Files (fileImporter + bookmarks)  
- Add “Create File Portal”  
- Persist bookmark + open reliably  
⸻  
## 8) “Grease” checklist (micro-interactions)  
- After Add/Paste/Drop: toast with *one* follow-up action (“Assign ▸”)  
- Search opens instantly on ==/== key  
- Haptics/feedback on successful add (subtle)  
- Clear empty states (“Drop here”, “Paste to add”, “Pin constellations to Hub”)  
- Launch confirmation only for **launch all**  
- Quick-edit rename without modal hell (inline if possible)  
⸻  
## 9) What we intentionally defer  
- Share extensions (unstable, high risk on visionOS)  
- Embedded browsers/windows  
- Full “Universe map” and physics interactions  
- Multi-device sync (until core UX is proven)  
⸻  
## Appendix — Path B compatibility notes  
If you keep state/logic centralized, Path B becomes:  
- The same objects (Portal/Constellation)  
- The same filters/sorts  
- Different renderers + interaction router  
