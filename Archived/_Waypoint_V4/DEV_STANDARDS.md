# DEV_STANDARDS.md — Waypoint Development Standards
**Purpose:** Shared conventions for humans + CLI agents (Codex/Claude).  
**Priority:** If this conflicts with `/docs/WAYPOINT_IMPLEMENTATION_PLAN_MASTER.md`, the master plan wins.

---

## 1) How we build (phase-gated)
- Work **one phase per branch** (see `REPO_WORKFLOW.md`).
- Keep diffs small and reviewable.
- After each phase:
  - build/run in Xcode (or `xcodebuild` if set up)
  - fix issues
  - update docs as needed

**Rule:** Don’t “clean up” unrelated code while implementing a phase.

---

## 2) File/Module boundaries (modular without spaghetti)
Prefer adding **small, single-purpose files** over bloating views/managers.

### Recommended module splits
- **Models:** `Portal`, `Constellation`, related lightweight types
- **Managers/Stores:** `PortalManager`, `ConstellationManager` (truth layer, minimal UI state)
- **Services:** parsing, drop handling, favicon, file IO, URL scheme routing
- **UI:** SwiftUI views grouped by feature (List, Orbs, Constellations)

### Practical rule of thumb
- If a view exceeds ~300–400 lines, look for:
  - extracted subviews (`PortalRow`, `MicroActionRow`, `FilterChips`)
  - extracted helpers into a Service
  - extracted “state machine” into a `@Observable` model

---

## 3) Code organization inside files (use `// MARK:`)
You prefer clearly delineated sections. Use this consistently:

```swift
// MARK: - Imports

// MARK: - View

// MARK: - Subviews

// MARK: - State

// MARK: - Actions

// MARK: - Helpers

// MARK: - Previews
```

### For Managers/Services
```swift
// MARK: - Public API
// MARK: - Persistence
// MARK: - Parsing / Validation
// MARK: - Private Helpers
```

**Rule:** Keep `// MARK:` headers meaningful. Avoid excessive micro-sections.

---

## 4) Naming conventions
- Types: `UpperCamelCase`
- Methods/vars: `lowerCamelCase`
- Booleans: `isPinned`, `hasThumbnail`, `shouldConfirmBatch`
- Views: `ThingView` (`OrbHubView`, `PortalOrbView`)
- Services: `ThingService` or `ThingParser` (`DropParser`, `FaviconService`)

---

## 5) SwiftUI conventions (Waypoint-specific)
### State placement
- Keep **persistent state** in managers (UserDefaults/App Group, etc.)
- Keep **UI-only state** in feature state models:
  - Example: `OrbSceneState` owns hub/expanded/focused mode + animation flags

### View composition
- Prefer:
  - small subviews
  - explicit `@Binding` or closures for actions
- Avoid:
  - deep nested closures with heavy logic
  - network/file work inside views (push into Services)

### Animations
- Use deterministic layouts first (Arc/Spiral/Linear/Hemisphere 2.5D).
- “Physics” is decorative; it must not own navigation or data.

---

## 6) Error handling & logging
- Prefer safe fallbacks over crashes:
  - invalid URL → show toast and discard
  - favicon fetch fails → fallback color/icon
- For debug builds:
  - use `print()` sparingly
  - consider lightweight `Logger` later

---

## 7) Testing & verification (per phase)
Minimum per phase:
- App compiles
- Core flow for that phase works (see phase checklist in master plan)
- No new warnings introduced without reason

For Phase 1 Drag & Drop, always test:
- Safari URL drop
- Files PDF drop
- multi-drop triggers batch confirm
- duplicate drop summons existing portal (if implemented)

---

## 8) Documentation discipline
### When to update docs
- **Always** keep `/docs/WAYPOINT_IMPLEMENTATION_PLAN_MASTER.md` as truth.
- Update `docs/DECISIONS.md` only when:
  - a “sacred decision” changes, or
  - a major tradeoff is accepted

### Decision entries should be short
- what changed
- why
- consequences
- follow-ups

---

## 9) CLI agent behavior (Codex/Claude)
Agents must:
1. Read docs listed in `AGENTS.md`
2. Implement only the requested phase
3. Stop and summarize:
   - files touched
   - risks
   - how to test
4. Avoid refactors unless required

---

## 10) “Keep it simple” principles
- Launcher first, spatial delight second
- Prefer clarity over cleverness
- A reliable 80% beats a fragile 100%
