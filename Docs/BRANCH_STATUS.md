# Branch Status & Management

**Last Updated:** January 1, 2026
**Primary Branch:** `main`

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

**Session Date:** January 1, 2026

**What happened:**
- Attempted to cherry-pick orb files from `phase3-orb-scaffold`
- Discovered main already had enhanced versions of those files
- The scaffold branch had older/simpler code that would have overwritten improvements

**Lesson learned:**
- Always verify what's on main before cherry-picking
- Use `git diff` to compare branches before any extraction
- The orb files were already properly merged via `phase3-orb-clean`

---

## Phase 1 Completion Checklist

Before declaring Phase 1 complete:
- [ ] All features working on main
- [ ] All stale branches deleted
- [ ] Documentation updated
- [ ] No uncommitted changes

---

**Remember:** When in doubt, `git status` and `git log` are your friends.
