# AGENTS.md — Waypoint Codex/Claude Instructions
**Purpose:** Ensure any CLI agent reads the right docs and implements changes safely, one phase at a time.
**Last Updated:** 2026-01-02

---

## Required reading (do this first)
1) `Docs/PROJECT_STATUS_JAN2026.md` ← **PRIMARY STATUS DOC**
2) `Docs/build.md`
3) `Docs/decisions.md`
4) `Docs/dev_standards.md`

## Optional reading
- `Docs/WAYPOINT_ORB_WORMHOLE_SWAP_v1.md` (for Phase 6)
- `Docs/REPO_WORKFLOW.md` (phase branches, PR checklist)

---

## Scope guardrails
- **NO embedded web browsing.** Launch externally via Safari.
- Keep existing truth layer: `PortalManager` + `ConstellationManager`.
- Implement **one phase per change-set**, then stop for user testing.
- **2-second rule:** User must be able to launch any portal in ~2 seconds.

## Current Status (Jan 2026)
**Branch:** `feature/orb-smart-grid`

### ✅ COMPLETE
- Phase 1: Drag & Drop upgrade (provider-based)
- Phase 2: Micro-actions + duplicate handling
- Phase 3: Orb scaffolding + adaptive layouts
- Phase 4: Orb micro-actions (radial arc context menu)
- Phase 5: Adaptive layouts (both views auto-orient)
- Phase 3.0+: Ornament auto-collapse & polish

### 🔴 NEXT
- **Phase 6:** Wormhole Swap Animation
- **Phase 7:** Universe View (strategic overview)
- **Phase 8:** App Store Polish

## Key Files
### Views
- `OrbContainerView.swift` - Main orb container with filtering/sorting
- `OrbLinearField.swift` - Adaptive smart grid (portrait/landscape)
- `PortalOrbView.swift` - Individual orb with radial arc menu
- `PortalListView.swift` - List view with full features
- `WaypointLeftOrnament.swift` - Left ornament (tabs, quick actions, aesthetics)
- `WaypointBottomOrnament.swift` - Bottom ornament (filters, constellations)

### Services
- `PortalManager.swift` - Portal CRUD and persistence
- `ConstellationManager.swift` - Constellation management
- `DropParser.swift` - URL extraction from drag items
- `DropService.swift` - Portal creation from URLs

## Working style
- Prefer minimal diffs. Do not “clean up” unrelated code.
- Keep new helpers isolated (e.g., `DropParser.swift`) rather than bloating views.
- Use `// MARK:` sections per `Docs/dev_standards.md`.
- When uncertain, add TODO comments and ask for clarification in the PR message / output.

## Validation expectations
- Ensure the project compiles after each phase.
- If `xcodebuild` is available, run a build and report results.
- If not available, at minimum ensure code type-checks and imports are correct.

## Output format (each phase)
- Summary of what changed
- List of files touched
- Any known risks / next tests for the user to run

---

## Future Feature Ideas (Backlog)
These are ideas for post-v1 consideration. Do not implement unless explicitly requested.

- **Save Profile / Workspace Presets:** Allow users to save and restore portal/constellation setups
- **Delete Constellation UI:** Add explicit delete option in constellation management
- **Per-constellation layout overrides:** Allow users to override auto-layout per constellation
- **Advanced color/intensity systems:** Constellation-scoped color palettes
- **Multi-device sync:** iCloud-based portal/constellation sync

---

## Known Issues (to address)
- Quick Add keyboard missing voice/mic button (cosmetic)
- RTFD duplicate portal creation from Notes drops (workaround: skip RTFD files)
