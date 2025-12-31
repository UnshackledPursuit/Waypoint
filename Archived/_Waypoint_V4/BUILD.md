# BUILD.md — Waypoint Build/Run Notes (fill in as you confirm)
**Purpose:** Give CLI agents an unambiguous way to validate compilation.

## Xcode (manual)
- Open the project/workspace in Xcode
- Select the visionOS target/scheme
- Build + Run

## CLI (recommended once confirmed)
> Update these commands to match your actual workspace/scheme names.

### Build (visionOS Simulator)
```bash
xcodebuild \
  -scheme Waypoint \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  build
```

### Clean build
```bash
xcodebuild \
  -scheme Waypoint \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  clean build
```

## Testing checklist (Phase 1 Drag & Drop)
- Drag a link from Safari into the app → portal created
- Drag a PDF from Files into the app → portal created (file URL)
- Drag multiple links → batch confirmation triggers
