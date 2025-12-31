## Alignment Notes (v1)
- Terminology aligned to **Waypoint Spatial Graph Spec v1.0**
- Language reconciled with **DECISIONS.md**, **BUILD.md**, and **DEV_STANDARDS.md**
- No feature scope changes; content clarified and cross-referenced only
- Document remains implementation-focused and phase-accurate

---

# Drag & Drop Upgrade Plan (visionOS) — URLs + Files + Text
**Goal:** Make drag/drop feel “foundational” by accepting not just `String`, but also `public.url` and `public.file-url`, and routing everything into existing `DropService.createPortal(from:)`.

---

## Current State
`PortalListView` uses:
- `.dropDestination(for: String.self)`

This limits drops to plain text. Safari and Files frequently provide URL/file representations via `NSItemProvider` that never reach your handler.

---

## Target Capabilities
Accept:
- **Web URLs** (Safari, Notes, etc.)
- **Plain text** that contains a URL
- **Files** (PDFs, images, docs) as:
  - file URLs (`public.file-url`)
  - file representations where available

---

## Recommended Implementation (low risk)
### 1) Add a new drop handler using providers
Switch to `.onDrop(of:isTargeted:perform:)` so you can parse `NSItemProvider`:

Accept UTTypes:
- `UTType.url.identifier`
- `UTType.text.identifier`
- `UTType.fileURL.identifier`

### 2) Create a Drop Parsing helper (keeps views clean)
Add a new service (or extend `DropService`) with:
- `extractURLs(from providers: [NSItemProvider]) async -> [URL]`

Parsing priority:
1. URL (UTType.url)
2. fileURL (UTType.fileURL)
3. text → extract URL candidates

### 3) Route extracted URLs into your existing flow
Once you have `[URL]`:
- call `handleDroppedURLs(urls)`
- keep your batch confirmation UX exactly as-is

---

## Suggested Code Sketch
In `PortalListView` replace `.dropDestination(for: String.self)` with:

```swift
.onDrop(
  of: [UTType.url.identifier, UTType.fileURL.identifier, UTType.text.identifier],
  isTargeted: $isDropTargeted
) { providers in
  Task {
    let urls = await DropParser.extractURLs(from: providers)
    await MainActor.run {
      handleDroppedURLs(urls)
    }
  }
  return true
}
```

Create `DropParser.swift`:

```swift
import Foundation
import UniformTypeIdentifiers

enum DropParser {
  static func extractURLs(from providers: [NSItemProvider]) async -> [URL] {
    var results: [URL] = []

    // 1) URL items
    results += await loadURLs(ofType: UTType.url, from: providers)

    // 2) File URLs
    results += await loadURLs(ofType: UTType.fileURL, from: providers)

    // 3) Text → URL detection
    let texts = await loadStrings(from: providers)
    results += texts.compactMap { stringToURL($0) }

    // De-dupe
    let unique = Array(Set(results))
    return unique
  }

  private static func loadURLs(ofType type: UTType, from providers: [NSItemProvider]) async -> [URL] {
    await withTaskGroup(of: URL?.self) { group in
      for p in providers where p.hasItemConformingToTypeIdentifier(type.identifier) {
        group.addTask {
          return await withCheckedContinuation { cont in
            p.loadItem(forTypeIdentifier: type.identifier, options: nil) { item, _ in
              if let url = item as? URL { cont.resume(returning: url); return }
              if let data = item as? Data,
                 let str = String(data: data, encoding: .utf8),
                 let url = URL(string: str) { cont.resume(returning: url); return }
              cont.resume(returning: nil)
            }
          }
        }
      }
      var out: [URL] = []
      for await url in group { if let url { out.append(url) } }
      return out
    }
  }

  private static func loadStrings(from providers: [NSItemProvider]) async -> [String] {
    await withTaskGroup(of: String?.self) { group in
      for p in providers where p.canLoadObject(ofClass: NSString.self) {
        group.addTask {
          return await withCheckedContinuation { cont in
            _ = p.loadObject(ofClass: NSString.self) { obj, _ in
              cont.resume(returning: obj as String?)
            }
          }
        }
      }
      var out: [String] = []
      for await s in group { if let s { out.append(s) } }
      return out
    }
  }

  private static func stringToURL(_ s: String) -> URL? {
    let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
    if let url = URL(string: trimmed), url.scheme != nil { return url }
    if trimmed.contains(".") && !trimmed.contains(" ") {
      return URL(string: "https://" + trimmed)
    }
    return nil
  }
}
```

---

## File Support Notes
This upgrade gets you **file URLs** from Files.app drops (when provided).  
A later step can convert file URLs into either:
- security-scoped bookmarks (link to original), or
- imported copies (store in app container)

But this drop upgrade is required first either way.

---

## Definition of Done
- Dragging from Safari creates portals for URLs (reliably)
- Dragging a PDF/image from Files creates a portal (as file URL)
- Batch confirmation still works for 6+
- Drop overlay remains (isTargeted)
