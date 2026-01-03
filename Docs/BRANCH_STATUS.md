# Branch Status & Management

**Last Updated:** January 3, 2026
**Primary Branch:** `main`
**Current State:** Clean (only main exists)

---

## Branch Policy

### Golden Rules
1. **main is always stable** - Only merge working code
2. **Delete after merge** - Never keep stale branches
3. **One feature at a time** - Avoid parallel diverging branches
4. **Archive experiments** - Use tags to preserve abandoned experimental code

---

## Current Branches

| Branch | Purpose | Status |
|--------|---------|--------|
| `main` | Stable production | **ACTIVE** |

*No other branches should exist. Feature branches are temporary.*

---

## Workflow

### Starting New Work
```bash
git checkout main
git pull origin main
git checkout -b feature/descriptive-name
```

### During Development
```bash
git add -A && git commit -m "description"
git push -u origin feature/descriptive-name  # first push
git push                                       # subsequent pushes
```

### Completing Work
```bash
# 1. Merge to main
git checkout main
git pull origin main
git merge feature/descriptive-name
git push origin main

# 2. Delete feature branch (REQUIRED)
git branch -d feature/descriptive-name
git push origin --delete feature/descriptive-name

# 3. Update documentation
# - AGENTS.md (current status)
# - PROJECT_STATUS_JAN2026.md (phase status)
# - This file if needed
```

### Archiving Experiments (Optional)
If abandoning experimental work but want to preserve for future reference:
```bash
git tag archive/experiment-name origin/experiment/xxx
git push origin archive/experiment-name
git push origin --delete experiment/xxx
```

---

## Why Delete Branches?

**Q: What if I need the code later?**
A: All commits are preserved in main's history. Use `git log` and `git show <commit>`.

**Q: What if I need to reference an old approach?**
A: For merged code, it's in main. For experiments, use the archive tag approach.

**Q: Can I recover a deleted branch?**
A: Local branches can be recovered via `git reflog` for ~30 days. Remote deletions are permanent.

---

## Cleanup History

### January 3, 2026
Deleted all stale branches after Phase A completion:

**Merged (deleted):**
- feature/orb-microactions-v2
- feature/narrow-window-smush
- feature/orb-linear-focus
- feature/orb-revamp
- feature/orb-smart-grid
- feature/favicon-service
- phase1-dragdrop
- phase2-microactions
- phase3-orb-clean
- phase4-wormhole-swap

**Discarded (not archived):**
- experiment/containerless-orbs (abandoned volumetric test)
- phase3-orb-scaffold (superseded by phase3-orb-clean)

---

**Remember:** A clean repo is a happy repo. Delete branches after merge.
