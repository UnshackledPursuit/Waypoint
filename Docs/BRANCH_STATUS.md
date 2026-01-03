# Branch Status & Management

**Last Updated:** January 3, 2026
**Primary Branch:** `main`
**Active Feature Branch:** `feature/orb-microactions-v2`

---

## Branch Policy

### Golden Rules
1. **main is always stable** - Only merge working code
2. **Verify before cherry-pick** - Always check what's on main first
3. **Complete branches get deleted** - Don't keep stale branches
4. **One active feature branch** - Avoid parallel diverging branches

### Before Any Branch Operation
```bash
# 1. Check current state
git status
git log --oneline -5 main

# 2. If cherry-picking from another branch, compare first
git diff main..other-branch --stat

# 3. Never blindly overwrite - use git show to inspect
git show other-branch:path/to/file.swift | head -30
```

---

## Active Branches

| Branch | Purpose | Status | Action |
|--------|---------|--------|--------|
| `main` | Stable production | **ACTIVE** | Keep |
| `feature/orb-microactions-v2` | Phase A interaction polish | **READY TO MERGE** | Merge to main |

---

## Archived/Stale Branches (Safe to Delete)

| Branch | Original Purpose | Why Stale |
|--------|-----------------|-----------|
| `phase1-dragdrop` | Drag & drop upgrade | Merged to main |
| `phase2-microactions` | Micro-actions | Merged to main |
| `phase3-orb-scaffold` | Orb scaffolding (old) | Superseded by phase3-orb-clean |
| `phase3-orb-clean` | Clean orb scaffolding | Merged to main |
| `phase4-wormhole-swap` | Wormhole animation | Not started, premature |
| `feature/favicon-service` | Favicon fetching | Merged to main |

---

## Cleanup Commands

```bash
# Delete local branches that are merged
git branch -d phase1-dragdrop phase2-microactions phase3-orb-scaffold phase3-orb-clean feature/favicon-service

# Delete unmerged branches (use with caution)
git branch -D phase4-wormhole-swap

# Delete remote tracking branches
git push origin --delete branch-name
```

---

## Workflow for New Features

1. **Always start from main:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/descriptive-name
   ```

3. **Work and commit frequently:**
   ```bash
   git add -A && git commit -m "description"
   ```

4. **When complete, merge to main:**
   ```bash
   git checkout main
   git merge feature/descriptive-name
   git push origin main
   ```

5. **Delete feature branch:**
   ```bash
   git branch -d feature/descriptive-name
   ```

---

## Common Mistakes to Avoid

### Mistake: Cherry-picking without checking
**Problem:** Older branch may have outdated code that overwrites newer improvements.

**Prevention:**
```bash
# Always compare first
git diff main..other-branch -- path/to/file.swift
```

### Mistake: Leaving stale branches
**Problem:** Creates confusion about which branch has correct code.

**Prevention:** Delete branches immediately after merging.

### Mistake: Working on main directly for experiments
**Problem:** Can break stable code.

**Prevention:** Always create a branch for experiments, even small ones.

---

## Current Session Notes

**Session Date:** January 3, 2026

**What happened (Phase A: Core Interaction Polish):**
- Renamed Pin → Favorite with star icons system-wide
- Implemented constellation popover with drag-drop reordering
- Created trailing popover pattern from left ornament
- Added custom orb hover effects (scale + brightness) to replace system hoverEffect
- Created ConditionalHelpModifier to avoid empty tooltip visual issues
- Removed star.fill from constellation icon options (conflicts with favorites)
- Documented patterns in VISIONOS_INTERACTION_PATTERNS.md

**Known Issues to Address Next:**
- Orbs not responding to eye gaze on visionOS device (works in simulator with mouse)
- Aesthetic popover menu planned (like constellation popover)
- Filter popover menu planned (like constellation popover)

**Files Changed:**
- WaypointLeftOrnament.swift - Constellation popover with drag-drop
- WaypointBottomOrnament.swift - Star color fixes
- PortalOrbView.swift - Hover effects, tooltip, star colors
- PortalListView.swift - Pin→Star icons
- CreateConstellationView.swift - Removed star from icons
- EditConstellationView.swift - Removed star from icons
- Constellation.swift - Default icon to sparkles
- VISIONOS_INTERACTION_PATTERNS.md - New patterns documented

---

## Phase 1 Completion Checklist

Before declaring Phase 1 complete:
- [ ] All features working on main
- [ ] All stale branches deleted
- [ ] Documentation updated
- [ ] No uncommitted changes

---

**Remember:** When in doubt, `git status` and `git log` are your friends.
