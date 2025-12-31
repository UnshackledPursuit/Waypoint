# AGENTS.md — Waypoint Codex/Claude Instructions
**Purpose:** Ensure any CLI agent reads the right docs and implements changes safely, one phase at a time.

---

## Required reading (do this first)
1) `docs/WAYPOINT_IMPLEMENTATION_PLAN_MASTER.md`
2) `docs/DOCS_INDEX.md`
3) `docs/DECISIONS.md`
4) `docs/WAYPOINT_NEXT_IMPLEMENTATION_STEPS.md`
5) `docs/WAYPOINT_DRAG_DROP_UPGRADE_PLAN.md`
6) `docs/WAYPOINT_ORB_WORMHOLE_SWAP.md`

## Optional reading (recommended)
- `docs/DEV_STANDARDS.md` (coding style, `// MARK:` structure, modularity expectations)
- `docs/REPO_WORKFLOW.md` (phase branches, PR checklist, tagging)

---

## Scope guardrails (v1)
- **NO embedded web browsing.** Launch externally.
- Keep existing truth layer: `PortalManager` + `ConstellationManager` (no refactor unless explicitly asked).
- Implement **one phase per change-set**, then stop for user testing.
- After each phase, update `docs/DECISIONS.md` **only if** a “sacred decision” changed.

## Phase order (do not reorder)
1) **Phase 1:** Drag & Drop upgrade (provider-based URL + fileURL + text)
2) **Phase 2:** Micro-actions + duplicate summon
3) **Phase 3:** Orb sacred flow scaffolding (SwiftUI renderer first)
4) **Phase 4:** Wormhole swap (Linear only)
5) **Phase 5:** File portals (open + persistence strategy later)

## Working style
- Prefer minimal diffs. Do not “clean up” unrelated code.
- Keep new helpers isolated (e.g., `DropParser.swift`) rather than bloating views.
- Use `// MARK:` sections per `docs/DEV_STANDARDS.md`.
- When uncertain, add TODO comments and ask for clarification in the PR message / output.

## Validation expectations
- Ensure the project compiles after each phase.
- If `xcodebuild` is available, run a build and report results.
- If not available, at minimum ensure code type-checks and imports are correct.

## Output format (each phase)
- Summary of what changed
- List of files touched
- Any known risks / next tests for the user to run
