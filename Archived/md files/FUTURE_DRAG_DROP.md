# Future: Revisit Drag & Drop

**Status:** Deferred
**Priority:** Medium
**Created:** December 29, 2024

---

## The Problem

Safari drag & drop to Waypoint doesn't work reliably on visionOS. When dragging a URL from Safari to our app's drop destination, the drop either doesn't register or fails silently.

**What we tried:**
- `dropDestination(for: URL.self)` - didn't work
- `dropDestination(for: String.self)` - didn't work
- Various modifier combinations

**Current solution:** Quick Paste and Quick Add toolbar buttons work perfectly and provide fast UX.

---

## Ideas to Explore

### 1. Test Other Sources
Safari may be the specific issue. Try dragging from:
- Files app
- Photos app
- Notes app
- Third-party browsers (if available)
- Other visionOS apps

### 2. NSItemProvider Approach
Instead of typed drop destinations, try raw NSItemProvider handling:
```swift
.onDrop(of: [.url, .text, .plainText], isTargeted: $isTargeted) { providers in
    for provider in providers {
        provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, error in
            // Handle item
        }
    }
    return true
}
```

### 3. Different UTTypes
Try accepting multiple types simultaneously:
- `.url`
- `.plainText`
- `.text`
- `.fileURL`
- `"public.url"`

### 4. Universal Links
Different approach entirely - register Waypoint to handle certain URL patterns:
- User taps special link anywhere
- iOS/visionOS opens Waypoint directly
- We already have `waypoint://add?url=...` scheme working

Could create a simple web tool that converts URLs to waypoint:// links.

### 5. Shortcuts Integration
Build a Shortcut action that:
- Accepts shared URL from share sheet
- Calls our URL scheme
- Works around drag & drop entirely

### 6. visionOS Updates
Monitor Apple's visionOS release notes for:
- Drag & drop improvements
- Safari interaction changes
- New drop destination APIs

---

## What's Working Now

| Method | Status | Notes |
|--------|--------|-------|
| Quick Paste | Working | One tap, reads clipboard |
| Quick Add | Working | Type URL/site name |
| Paste button in form | Working | Auto-fills name + URL |
| URL scheme | Working | `waypoint://add?url=...` |
| Drag reorder | Working | Within app, Custom sort |

---

## Technical Context

**Commit where we pivoted:** 0e46db9
**Files involved:**
- `PortalListView.swift` - has commented drop destination code
- `DropService.swift` - smart name extraction (still used by Quick Paste)

**The dropDestination code (for reference):**
```swift
.dropDestination(for: URL.self) { urls, location in
    handleDrop(urls)
    return true
} isTargeted: { isTargeted in
    self.isDropTargeted = isTargeted
}
```

---

## When to Revisit

- After visionOS 2.1+ release
- If users specifically request it
- During Phase 8 (visionOS Polish) if time allows
- If we discover other apps have solved this

---

## Success Criteria

When revisiting, consider it solved if:
- Drag from Safari works 90%+ of the time
- Visual feedback shows drop zone
- Auto-fill (name + favicon) triggers on drop
- Works with single and multiple URLs

---

*This is a "nice to have" - Quick Paste/Quick Add provide excellent UX in the meantime.*
