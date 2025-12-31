# README_DEV.md — Waypoint Dev Handoff

## Where to start
Read:
1) `docs/WAYPOINT_IMPLEMENTATION_PLAN_MASTER.md`
2) `docs/DECISIONS.md`
3) `docs/DOCS_INDEX.md`

## Golden rules (v1)
- No embedded web browsing. Launch externally.
- Keep existing managers as truth (`PortalManager`, `ConstellationManager`) until explicitly refactored.
- Drag/drop must accept URL + fileURL + text (provider-based).
- Orb module is a renderer: layout + interaction separate from persistence.

## How to work
Implement in phases (see master plan). Keep changes small and reviewable:
- Phase 1: Drag/drop upgrade
- Phase 2: Micro-actions + duplicate summon
- Phase 3: Orb sacred flow scaffolding
- Phase 4: Wormhole swap (Linear only)
- Phase 5: File portals (open + persistence strategy later)

## When changing direction
Add an entry to `docs/DECISIONS.md` describing:
- what changed
- why
- consequences
