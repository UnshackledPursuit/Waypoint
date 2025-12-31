# REPO_WORKFLOW.md — GitHub Phase Branching & Release Discipline
**Purpose:** Keep progress clean and reversible while shipping one phase at a time.

---

## 1) Branching model
- `main` = stable baseline (demo-safe)
- One feature branch per phase, then merge to `main` via PR

### Branch naming
- `phase-1-drag-drop-providers`
- `phase-2-micro-actions`
- `phase-3-orb-sacred-flow`
- `phase-4-wormhole-swap`
- `phase-5-file-portals`

---

## 2) Phase PR checklist (non-negotiable)
Before merging:
- [ ] Scope is limited to the phase (no drive-by refactors)
- [ ] Builds in Xcode (or `xcodebuild` if configured)
- [ ] Manual test checklist completed for that phase
- [ ] Docs updated if needed:
  - `docs/DECISIONS.md` only if a sacred decision changed
  - otherwise optional notes in your project status/changelog

---

## 3) Tagging milestones (optional but recommended)
After merging a phase PR:
- `v0.2-phase1`
- `v0.3-phase2`
- `v0.4-phase3`
etc.

This makes rollback and demo selection easy.

---

## 4) PR template (copy/paste)
**Summary**
- What changed?

**Files touched**
- List key files

**How to test**
- Steps in Xcode / simulator

**Risks**
- Any known edge cases or follow-ups

**Docs**
- Which docs were updated (if any)

---

## 5) Working with CLI agents
Recommended pattern:
1. Start a new phase branch
2. Run Codex/Claude from repo root
3. Give one objective:
   - “Implement Phase 1 exactly as in docs/WAYPOINT_DRAG_DROP_UPGRADE_PLAN.md”
4. Review diffs
5. Build/run in Xcode
6. Fix issues
7. Merge PR

**Rule:** Never run multiple phases in one branch.

---

## 6) Rollback strategy
If a phase introduces instability:
- revert the phase merge commit, or
- reset to last milestone tag

Because phases are isolated, rollback is clean.

---
