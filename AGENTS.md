# AGENTS.md — Waypoint Codex/Claude Instructions
**Purpose:** Ensure any CLI agent reads the right docs and implements changes safely, one phase at a time.
**Last Updated:** 2025-01-01

---

## Required reading (do this first)
1) `Docs/WAYPOINT_IMPLEMENTATION_PLAN_MASTER_v1.md`
2) `Docs/DOCS_INDEX.md`
3) `Docs/decisions.md`
4) `Docs/WAYPOINT_NEXT_IMPLEMENTATION_STEPS_v1.md`
5) `Docs/WAYPOINT_FEATURE_MATRIX_v1.md`
6) `Docs/WAYPOINT_ORB_WORMHOLE_SWAP_v1.md`

## Optional reading (recommended)
- `Docs/dev_standards.md` (coding style, `// MARK:` structure, modularity expectations)
- `Docs/REPO_WORKFLOW.md` (phase branches, PR checklist, tagging)

---

## Scope guardrails (v1)
- **NO embedded web browsing.** Launch externally.
- Keep existing truth layer: `PortalManager` + `ConstellationManager` (no refactor unless explicitly asked).
- Implement **one phase per change-set**, then stop for user testing.
- After each phase, update `Docs/decisions.md` **only if** a "sacred decision" changed.

## Phase order (do not reorder)
1) **Phase 1:** Drag & Drop upgrade (provider-based URL + fileURL + text) ✅ COMPLETE
2) **Phase 2:** Micro-actions + duplicate summon ✅ COMPLETE
3) **Phase 3:** Orb sacred flow scaffolding (SwiftUI renderer first) ✅ SCAFFOLDING COMPLETE
4) **Phase 4:** Wormhole swap (Linear only) ← NEXT
5) **Phase 5:** File portals (open + persistence strategy later)

## Phase 3 Orb Files Created
- `OrbSceneState.swift` - Scene state container (hub/expanded/focused)
- `OrbLayoutEngine.swift` - Auto-switching layouts (Linear/Arc/Spiral/Hemisphere)
- `OrbContainerView.swift` - Main container with drop support
- `OrbSceneView.swift`, `OrbHubView.swift`, `OrbFieldView.swift`, `OrbExpandedView.swift`
- `OrbTopBar.swift`, `OrbModeToggle.swift`, `OrbOrnamentControls.swift`
- `PortalOrbView.swift`, `ConstellationOrbView.swift`

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
