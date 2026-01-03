# visionOS Interaction Patterns Reference
**Purpose:** Comprehensive reference for visionOS UI patterns, interactions, and design guidelines for future Waypoint enhancements.
**Last Updated:** 2026-01-03

---

## Essential Resources

### Top Developer Resources
1. **[Step Into Vision](https://stepinto.vision)** - Premier visionOS development resource, tutorials, and news
2. **[Apple visionOS Developer](https://developer.apple.com/visionos/)** - Official documentation and HIG
3. **[Swift with Majid](https://swiftwithmajid.com)** - Excellent SwiftUI/visionOS tutorials
4. **[Create with Swift](https://www.createwithswift.com)** - Practical visionOS implementation guides

### Key WWDC Sessions
- [WWDC25 - Set the scene with SwiftUI in visionOS](https://developer.apple.com/videos/play/wwdc2025/290/)
- [WWDC25 - What's new in visionOS 26](https://developer.apple.com/videos/play/wwdc2025/317/)
- [WWDC25 - Design hover interactions for visionOS](https://developer.apple.com/videos/play/wwdc2025/303/)
- [WWDC24 - Create custom hover effects](https://developer.apple.com/videos/play/wwdc2024/10152/)
- [WWDC24 - Work with windows in SwiftUI](https://developer.apple.com/videos/play/wwdc2024/10149/)
- [WWDC23 - Inspectors in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10161/)

---

## 1. Presentation Types

### Overview Table

| Type | Modifier | Use Case | visionOS Behavior |
|------|----------|----------|-------------------|
| **Tooltip** | `.help("text")` | Quick hints | Appears on gaze hover |
| **Popover** | `.popover()` | Rich floating content | Extends beyond window, centered |
| **Sheet** | `.sheet()` | Modal forms | Liquid Glass, morphs from buttons |
| **Alert** | `.alert()` | Critical notifications | Center-focused, requires action |
| **Confirmation Dialog** | `.confirmationDialog()` | Destructive confirmations | Slide-up, dismissible outside |
| **Context Menu** | `.contextMenu()` | Long-press actions | Can include previews |
| **Inspector** | `.inspector()` | Side panel details | Liquid Glass, selection-aware |
| **Menu** | `.menu()` | Dropdown actions | Standard dropdown |

### visionOS 26 Enhancements
- **Presentations from Volumes/Attachments** - Show modals from 3D content
- **Nested presentations** - Popovers from sheets, context menus from ornaments
- **`presentationBreakthroughEffect`** - Keeps presentations visible over 3D content

### Code Examples

```swift
// Tooltip
Button("Action") { }
    .help("Performs the action")

// Popover
.popover(isPresented: $showPopover) {
    PopoverContent()
        .frame(width: 300)
}

// Context Menu with Preview (iOS 16+)
.contextMenu {
    Button("Edit") { }
    Button("Delete", role: .destructive) { }
} preview: {
    PreviewCard(item: item)
        .frame(width: 280, height: 180)
}

// Inspector
.inspector(isPresented: $showInspector) {
    DetailView(selection: selectedItem)
}
.inspectorColumnWidth(min: 200, ideal: 280, max: 350)

// Confirmation Dialog
.confirmationDialog("Delete Portal?", isPresented: $showDelete) {
    Button("Delete", role: .destructive) { delete() }
    Button("Cancel", role: .cancel) { }
}
```

---

## 2. Hover Effects

### Built-in Effects

| Effect | Behavior | Use Case |
|--------|----------|----------|
| `.automatic` | System default (highlight) | Most buttons |
| `.highlight` | Brightens element | Interactive elements |
| `.lift` | Lifts toward user + shadow | Cards, tiles |

### Custom Hover Effects (visionOS 2+)

```swift
.hoverEffect { effect, isActive, proxy in
    effect
        .scaleEffect(isActive ? 1.1 : 1.0)
        .opacity(isActive ? 1.0 : 0.85)
        .animation(.spring(response: 0.3), value: isActive)
}
```

### System App Inspirations
- **Tab bars** - Pop open to show names on hover
- **Back buttons** - Grow to show previous page title
- **Sliders** - Reveal knob on hover
- **Safari nav** - Expands to show browser tabs
- **Home View** - Environment icons reveal landscape previews

### Limitations
- No 3D transforms (`rotation3DEffect`, `offset(z:)`)
- No `CustomAnimation` types
- No `shadow` modifier
- Privacy-protected, applied outside app process

### Accessibility
- Provide alternative effects for motion-sensitive users
- Avoid overusing custom effects
- Test with reduced motion settings

---

## 3. Gestures

### Standard Gestures

| Gesture | visionOS Input | Code |
|---------|----------------|------|
| Tap | Pinch fingers | `TapGesture()` |
| Long Press | Extended pinch | `LongPressGesture(minimumDuration: 0.5)` |
| Drag | Pinch + move | `DragGesture()` |
| Magnify | Two-hand spread | `MagnifyGesture()` |
| Rotate | Two-hand rotation | `RotateGesture()` |

### Combining Gestures

```swift
// Sequential: Long press then drag
.gesture(
    LongPressGesture(minimumDuration: 0.3)
        .sequenced(before: DragGesture())
        .onEnded { value in
            switch value {
            case .second(true, let drag):
                // Handle drag after long press
            default: break
            }
        }
)

// Simultaneous: Drag + Magnify + Rotate
.gesture(
    DragGesture()
        .simultaneously(with: MagnifyGesture())
        .simultaneously(with: RotateGesture())
)
```

### ManipulationComponent (visionOS 26)
Standardizes complex 3D interactions:
- Pinch + hold to grab
- Telescope along z-axis
- Hand rotation = object rotation
- Hand-off between hands

```swift
entity.components[ManipulationComponent.self] = ManipulationComponent()
```

### GestureComponent (visionOS 26)
Apply SwiftUI gestures directly to RealityKit entities:
```swift
entity.components[GestureComponent.self] = GestureComponent(
    canDrag: true,
    canRotate: true,
    canScale: true
)
```

---

## 4. Windows & Multi-Window

### WindowGroup Basics

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }

        WindowGroup(id: "editor", for: UUID.self) { $itemId in
            EditorView(itemId: itemId)
        }
    }
}
```

### Opening Windows

```swift
@Environment(\.openWindow) var openWindow
@Environment(\.dismissWindow) var dismissWindow

Button("Open Editor") {
    openWindow(id: "editor", value: item.id)
}
```

### Window Placement

```swift
// Side-by-side (trailing)
WindowGroup(id: "auxiliary") {
    AuxiliaryView()
}
.defaultWindowPlacement { context in
    WindowPlacement(.trailing(context.windows.last!))
}

// Utility panel (below)
.defaultWindowPlacement { _ in
    WindowPlacement(.utilityPanel)
}
```

### Window Sizing

```swift
.defaultSize(width: 400, height: 600)
.windowResizability(.contentSize) // or .automatic
```

### Fake Multi-Window Trick
Create visual side panels within one window:
```swift
WindowGroup {
    HStack(spacing: 0) {
        MainPanel()
            .glassBackgroundEffect()

        if showSidePanel {
            SidePanel()
                .glassBackgroundEffect()
                .transition(.move(edge: .trailing))
        }
    }
}
.windowStyle(.plain)
```

---

## 5. Ornaments

### Placement Options

| Anchor | Position |
|--------|----------|
| `.scene(.leading)` | Left of window |
| `.scene(.trailing)` | Right of window |
| `.scene(.top)` | Above window |
| `.scene(.bottom)` | Below window |
| `.scene(.front)` | In front (z-axis) |
| `.scene(.back)` | Behind (z-axis) |

### Custom Ornament

```swift
.ornament(
    visibility: .visible,
    attachmentAnchor: .scene(.bottom),
    contentAlignment: .top
) {
    HStack {
        // Controls
    }
    .padding()
    .glassBackgroundEffect()
}
```

### Toolbar Ornament

```swift
.toolbar {
    ToolbarItem(placement: .bottomOrnament) {
        Button("Action") { }
    }
}
```

### visionOS 26: Nested Ornaments
```swift
.ornament(attachmentAnchor: .parent(.trailing)) {
    // Ornament attached to parent ornament
}
```

---

## 6. Context Menus

### Basic Context Menu

```swift
.contextMenu {
    Button("Edit", systemImage: "pencil") { edit() }
    Button("Duplicate", systemImage: "doc.on.doc") { duplicate() }
    Divider()
    Button("Delete", systemImage: "trash", role: .destructive) { delete() }
}
```

### With Custom Preview (iOS 16+)

```swift
.contextMenu {
    // Actions
} preview: {
    VStack {
        AsyncImage(url: item.imageURL)
            .frame(width: 280, height: 180)
        Text(item.title)
            .font(.headline)
    }
}
```

### Sectioned Menu

```swift
.contextMenu {
    Section("Open") {
        Button("Open in Safari") { }
        Button("Open in New Window") { }
    }
    Section("Edit") {
        Button("Rename") { }
        Button("Change Icon") { }
    }
    Section {
        Button("Delete", role: .destructive) { }
    }
}
```

---

## 7. RealityKit Integration (visionOS 26)

### ViewAttachmentComponent
Attach SwiftUI views to entities:
```swift
entity.components[ViewAttachmentComponent.self] = ViewAttachmentComponent {
    ActionButtons(for: entity)
}
```

### PresentationComponent
Enable modals on 3D entities:
```swift
entity.components[PresentationComponent.self] = PresentationComponent()
// Then use standard .popover(), .sheet(), etc.
```

### Spatial Anchoring
Lock content to surfaces:
```swift
.spatialAnchor(.wall)
.spatialAnchor(.table)
```

---

## 8. Radial/Arc Menu Implementation

No native API exists. Custom implementation approach:

### RadialLayout

```swift
struct RadialLayout: Layout {
    var radius: CGFloat = 100
    var startAngle: Angle = .degrees(-90)
    var arcSpan: Angle = .degrees(180)

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: radius * 2 + 60, height: radius * 2 + 60)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        let angleStep = arcSpan.radians / Double(max(subviews.count - 1, 1))

        for (index, subview) in subviews.enumerated() {
            let angle = startAngle.radians + angleStep * Double(index)
            let x = bounds.midX + cos(angle) * radius
            let y = bounds.midY + sin(angle) * radius
            subview.place(at: CGPoint(x: x, y: y), anchor: .center, proposal: .unspecified)
        }
    }
}
```

### Current Waypoint Implementation
Uses arc positioning in `PortalOrbView.swift` with calculated angles for action buttons.

---

## 9. Design Guidelines Summary

### Eye Targeting
- **60pt minimum** touch target for precise interactions
- **Rounded shapes** preferred (circles, pills, rounded rects)
- **Test on device** - simulator insufficient for hover testing

### Depth & Layering
- Use **z-offset** for active/selected states
- **Glass materials** for floating UI
- Start in **window**, don't force immersion

### Animation
- **Spring animations** for natural feel
- **0.2-0.3s** duration for most transitions
- **Respect reduced motion** preference

### Spatial Layout
- **60pt spacing** between interactive elements
- **Ornaments** for persistent controls
- **Popovers** for contextual actions

---

## 10. Ideas for Waypoint Enhancement

### Priority 1: Orb Micro-Actions Menu
**Current:** Radial arc menu on long-press
**Options to explore:**
- Native popover with sections
- Context menu with portal preview
- Custom hover expansion (actions appear on gaze)
- Hybrid: hover shows preview, long-press shows full menu

### Priority 2: Enhanced Hover States
- Orb glow/lift on gaze
- Label expansion on hover
- Constellation color pulse

### Priority 3: Quick Start Portal Groups
- Auxiliary window side-by-side
- Inspector panel for editing
- Live preview while editing

### Priority 4: Constellation Bulk Editing
- Multi-select with inspector
- Batch rename patterns
- Drag reordering

### Future Considerations
- 3D orb attachments (RealityKit)
- Spatial anchoring to surfaces
- Multi-window workflows
- **Curved Layout Mode** - Toggle between linear and curved orb arrangements
  - Inspired by visionOS curved dock aesthetic
  - Would work well in focus mode with Mac Virtual Display
  - Orbs arranged in an arc that wraps around user's field of view
  - Could apply to both narrow (vertical arc) and wide (horizontal arc) layouts
  - Implementation approach: Custom `Layout` protocol with arc positioning math
  - See RadialLayout example in Section 8 for similar positioning logic

---

## 11. Waypoint Implemented Patterns

### Trailing Popover from Ornament
A popover that appears to the trailing side of a left ornament button, staying visible and accessible.

**Implementation:**
```swift
Button { showPopover.toggle() }
    .popover(isPresented: $showPopover, arrowEdge: .trailing) {
        PopoverContent()
    }
```

**Key Points:**
- Use `arrowEdge: .trailing` for popovers from left ornaments
- Use `.toggle()` instead of setting to `true` for reliable reopening
- Wrap content in `.ultraThinMaterial` for visionOS glass look
- Width: 200-230pt works well for list popovers

**Use Cases:**
- Constellation quick picker
- Portal filters/sorts
- Quick settings panels
- Multi-select options
- Appearance controls (Aesthetic Popover)

**Known Limitations:**
- Popovers cannot be tilted or rotated in 3D space - they are system-managed presentations
- No control over popover z-position or perspective angle
- Offset is controlled by `arrowEdge` but actual positioning is handled by visionOS
- For truly custom 3D-positioned UI, would need RealityKit attachments instead

### Drag and Drop Reordering in Popovers
Reorder list items using SwiftUI's `.draggable()` and `.dropDestination()`.

**Implementation:**
```swift
ForEach(items) { item in
    ItemRow(item: item)
        .draggable(item.id.uuidString) {
            // Drag preview view
            DragPreview(item: item)
        }
        .dropDestination(for: String.self) { droppedItems, _ in
            guard let sourceID = UUID(uuidString: droppedItems.first ?? ""),
                  sourceID != item.id else { return false }
            onReorder(sourceID, item.id)
            return true
        }
}
```

**Key Points:**
- Use UUID strings for transferable data (simple, works reliably)
- Provide visual drag preview with glass material
- Add drag handle indicator (`line.3.horizontal`) for discoverability
- Reduce opacity of dragged item for visual feedback
- Manager's `@Observable` ensures auto-update of other views (bottom ornament)

---

## Changelog

| Date | Changes |
|------|---------|
| 2026-01-03 | Added popover limitations, curved layout future feature |
| 2026-01-03 | Added trailing popover and drag-drop patterns |
| 2026-01-03 | Initial document creation |
