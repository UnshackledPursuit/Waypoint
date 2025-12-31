# Orb Swap Animation — “Wormhole Stack” (Linear Layout)
**Purpose:** When switching constellations in **Linear Stack**, create a satisfying “portals swallowing and spawning orbs” animation without confusing the user.

---

## Concept
When user switches to a different constellation while in **Expanded** mode:

1. A **bottom portal** appears.
2. Existing orbs “drop” into it (shrink + fade + slight blur).
3. A **top portal** appears.
4. New constellation orbs “fall out” from the top into their final positions (spring settle).

This reads as: *“we changed sets”* — not *“we rearranged the same items.”*

---

## When to use
- ✅ Switching expanded constellation **while Linear layout is active**
- ✅ Switching from Hub → Expanded (optional lighter variant)
- ❌ Not used for filtering chips (too noisy)
- ❌ Not used during drag reorder (must stay stable)

---

## UX Rules (keep it clean)
- Animation duration target: **0.45–0.70s**
- Do not animate more than **~18** visible orbs in this effect.
  - If more, either:
    - shorten the animation, or
    - crossfade + top-drop only (no bottom swallow), or
    - auto-pick Arc/Spiral via Auto layout (preferred)
- During swap:
  - Disable taps/pinches (or ignore) to avoid accidental launches
  - Keep the constellation “center orb” fixed at center (the anchor)

---

## Implementation Strategy (SwiftUI)
### State you need
In `OrbSceneState`:
- `isSwapping: Bool`
- `swapPhase: SwapPhase` (idle, exitingOld, enteringNew)
- `swapFromConstellationID`, `swapToConstellationID`
- `renderedConstellationID` (what the UI is currently drawing)
- `pendingConstellationID` (what the user selected)

### Swap phases
1. **exitingOld**
   - show bottom portal
   - animate old orbs → translate down + scale down + opacity to 0
2. **enteringNew**
   - switch renderedConstellationID to the new one
   - show top portal
   - new orbs start above viewport → drop in + spring
3. return to idle
   - hide portals
   - re-enable interactions

### Visual portal elements
Use simple SwiftUI shapes initially:
- a blurred ring + inner dark hole
- mild glow (tinted by constellation theme color)

You can evolve later to a shader/texture.

---

## Recommended animation math
**Exit (old orbs):**
- y: `+180…+320` (depending on stack height)
- scale: `1.0 → 0.2`
- opacity: `1.0 → 0.0`
- blur: `0 → 6`

**Enter (new orbs):**
- initial y: `-220` (above)
- final y: their layout position
- scale: `0.7 → 1.0`
- opacity: `0.0 → 1.0`

Use `.spring(response:dampingFraction:blendDuration:)` for settle.

---

## Rendering approach
In `OrbFieldView`:
- keep a ZStack:
  - bottom portal (conditionally visible)
  - old orbs layer (only during exitingOld)
  - top portal (conditionally visible)
  - new orbs layer (during enteringNew and idle)

This is easiest if you maintain **two arrays** during swap:
- `oldVisibleNodes`
- `newVisibleNodes`

---

## Notes on naming (avoid confusion)
Call the effect internally:
- **WormholeSwap**
Call the UI affordance:
- no explicit naming, it just happens.

---

## Definition of Done
- Switching constellations in Linear layout triggers WormholeSwap
- Old orbs exit cleanly, new orbs enter cleanly
- No accidental launches mid-animation
- Works with global pinned (pinned appear at top of new stack)
