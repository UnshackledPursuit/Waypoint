//
//  OrbLinearField.swift
//  Waypoint
//
//  Created on January 2, 2026.
//

import SwiftUI

// MARK: - Constellation Section

/// A group of portals belonging to a constellation (for sectioned layout)
struct ConstellationSection: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let color: Color
    let portals: [Portal]

    /// Section for portals not in any constellation
    static func ungrouped(portals: [Portal]) -> ConstellationSection {
        ConstellationSection(
            id: UUID(),
            name: "Ungrouped",
            icon: "questionmark.circle",
            color: .secondary,
            portals: portals
        )
    }
}

// MARK: - Orb Linear Field

/// Adaptive orb layout that automatically uses grid when space allows.
/// - Single row/column for narrow containers
/// - Multiple rows/columns (up to 3) when space permits
/// - Each row/column scrolls independently
/// - Subtle scroll indicators show when content overflows
struct OrbLinearField: View {

    // MARK: - Properties

    let portals: [Portal]
    /// The active constellation's color (used when a single constellation is selected)
    var constellationColor: Color? = nil
    /// Lookup function for per-portal constellation color (used in All view with constellation color mode)
    var constellationColorForPortal: ((Portal) -> Color?)? = nil
    /// Constellation sections for grouped layout (when sorted by constellation)
    var constellationSections: [ConstellationSection]? = nil
    let onOpen: (Portal) -> Void

    // MARK: - Micro-Action Callbacks

    var onEdit: ((Portal) -> Void)? = nil
    var onDelete: ((Portal) -> Void)? = nil
    var onTogglePin: ((Portal) -> Void)? = nil
    var onToggleConstellation: ((Portal, Constellation) -> Void)? = nil
    var allConstellations: [Constellation] = []
    var constellationIDsForPortal: ((Portal) -> Set<UUID>)? = nil
    var onCreateConstellation: ((Portal) -> Void)? = nil

    // MARK: - Layout Constants

    /// Orb size preference from user settings
    @AppStorage("orbSizePreference") private var orbSizeRaw: String = "medium"

    /// Size of each orb based on user preference
    private var orbSize: CGFloat {
        switch orbSizeRaw {
        case "small": return 64 * 0.55     // ~35pt - compact
        case "large": return 64 * 1.0      // 64pt - original
        default: return 64 * 0.7           // medium = ~45pt (default)
        }
    }
    /// Spacing between orbs within a row/column
    private let orbSpacing: CGFloat = 16
    /// Spacing between rows (landscape) or columns (portrait)
    private let rowColumnSpacing: CGFloat = 8
    /// Padding around the content
    private let contentPadding: CGFloat = 24
    /// Maximum number of rows/columns (high limit to allow filling space)
    private let maxRowsColumns: Int = 10

    /// Approximate height of an orb item (orb + label + glow)
    private var orbItemHeight: CGFloat { orbSize * 1.8 + 20 } // ~135pt
    /// Approximate width of an orb item
    private var orbItemWidth: CGFloat { orbSize * 1.7 + 8 } // ~117pt

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    private var isConstellationColorMode: Bool {
        OrbColorMode(rawValue: orbColorModeRaw) == .constellation
    }

    // MARK: - Helper: Create Portal Orb View

    @ViewBuilder
    private func makePortalOrbView(portal: Portal, colorOverride: Color? = nil) -> some View {
        let portalColor = colorOverride ?? constellationColorForPortal?(portal) ?? constellationColor

        PortalOrbView(
            portal: portal,
            constellationColor: portalColor,
            size: orbSize,
            onOpen: { onOpen(portal) },
            onEdit: onEdit != nil ? { onEdit?(portal) } : nil,
            onDelete: onDelete != nil ? { onDelete?(portal) } : nil,
            onTogglePin: onTogglePin != nil ? { onTogglePin?(portal) } : nil,
            onToggleConstellation: onToggleConstellation != nil ? { constellation in
                onToggleConstellation?(portal, constellation)
            } : nil,
            constellations: allConstellations,
            portalConstellationIDs: constellationIDsForPortal?(portal) ?? [],
            onCreateConstellation: onCreateConstellation != nil ? { onCreateConstellation?(portal) } : nil
        )
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            let isLandscape = proxy.size.width > proxy.size.height * 1.3
            let isNarrow = proxy.size.width < 200
            let effectivePadding = isNarrow ? 12.0 : contentPadding

            Group {
                if portals.isEmpty {
                    emptyState
                } else if let sections = constellationSections, !sections.isEmpty {
                    // Sectioned layout for constellation grouping
                    sectionedLayout(containerSize: proxy.size, sections: sections, isLandscape: isLandscape, padding: effectivePadding)
                } else {
                    // Standard grid layout
                    let gridInfo = calculateGridInfo(size: proxy.size, isLandscape: isLandscape, padding: effectivePadding)
                    if isLandscape {
                        horizontalGridLayout(containerSize: proxy.size, rowCount: gridInfo.count, padding: effectivePadding)
                    } else {
                        verticalGridLayout(containerSize: proxy.size, columnCount: gridInfo.count, padding: effectivePadding)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: isNarrow ? 16 : 24))
        }
        .frame(minHeight: 150) // Reduced minimum height for compact views
    }

    // MARK: - Grid Calculation

    private struct GridInfo {
        let count: Int // Number of rows (landscape) or columns (portrait)
        let itemsPerRow: Int // For distribution
    }

    private func calculateGridInfo(size: CGSize, isLandscape: Bool, padding: CGFloat) -> GridInfo {
        if isLandscape {
            // Calculate how many rows fit
            let availableHeight = size.height - (padding * 2)
            let rowCapacity = Int((availableHeight + rowColumnSpacing) / (orbItemHeight + rowColumnSpacing))
            let rows = max(1, min(rowCapacity, maxRowsColumns))
            let itemsPerRow = portals.count > 0 ? Int(ceil(Double(portals.count) / Double(rows))) : 0
            return GridInfo(count: rows, itemsPerRow: itemsPerRow)
        } else {
            // Calculate how many columns fit
            let availableWidth = size.width - (padding * 2)
            let columnCapacity = Int((availableWidth + rowColumnSpacing) / (orbItemWidth + rowColumnSpacing))
            let columns = max(1, min(columnCapacity, maxRowsColumns))
            let itemsPerColumn = portals.count > 0 ? Int(ceil(Double(portals.count) / Double(columns))) : 0
            return GridInfo(count: columns, itemsPerRow: itemsPerColumn)
        }
    }

    /// Distribute portals evenly across rows/columns
    private func distributePortals(into count: Int) -> [[Portal]] {
        guard count > 0, !portals.isEmpty else { return [] }

        var result: [[Portal]] = Array(repeating: [], count: count)
        for (index, portal) in portals.enumerated() {
            let bucketIndex = index % count
            result[bucketIndex].append(portal)
        }
        return result
    }

    // MARK: - Horizontal Grid Layout (Landscape - Multiple Rows)

    private func horizontalGridLayout(containerSize: CGSize, rowCount: Int, padding: CGFloat) -> some View {
        let distributed = distributePortals(into: rowCount)
        let rowHeight = (containerSize.height - padding * 2 - CGFloat(rowCount - 1) * rowColumnSpacing) / CGFloat(rowCount)

        return VStack(spacing: rowColumnSpacing) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                if rowIndex < distributed.count {
                    ScrollableOrbRow(
                        portals: distributed[rowIndex],
                        constellationColor: constellationColor,
                        constellationColorForPortal: constellationColorForPortal,
                        orbSize: orbSize,
                        orbSpacing: orbSpacing,
                        contentPadding: padding,
                        onOpen: onOpen,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onTogglePin: onTogglePin,
                        onToggleConstellation: onToggleConstellation,
                        allConstellations: allConstellations,
                        constellationIDsForPortal: constellationIDsForPortal,
                        onCreateConstellation: onCreateConstellation
                    )
                    .frame(height: rowHeight)
                }
            }
        }
        .padding(.vertical, padding)
    }

    // MARK: - Vertical Grid Layout (Portrait - Multiple Columns)

    private func verticalGridLayout(containerSize: CGSize, columnCount: Int, padding: CGFloat) -> some View {
        let distributed = distributePortals(into: columnCount)
        let columnWidth = (containerSize.width - padding * 2 - CGFloat(columnCount - 1) * rowColumnSpacing) / CGFloat(columnCount)

        return HStack(spacing: rowColumnSpacing) {
            ForEach(0..<columnCount, id: \.self) { columnIndex in
                if columnIndex < distributed.count {
                    ScrollableOrbColumn(
                        portals: distributed[columnIndex],
                        constellationColor: constellationColor,
                        constellationColorForPortal: constellationColorForPortal,
                        orbSize: orbSize,
                        orbSpacing: orbSpacing,
                        contentPadding: padding,
                        onOpen: onOpen,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onTogglePin: onTogglePin,
                        onToggleConstellation: onToggleConstellation,
                        allConstellations: allConstellations,
                        constellationIDsForPortal: constellationIDsForPortal,
                        onCreateConstellation: onCreateConstellation
                    )
                    .frame(width: columnWidth)
                }
            }
        }
        .padding(.horizontal, padding)
    }

    // MARK: - Sectioned Layout (Constellation Groups)

    private func sectionedLayout(containerSize: CGSize, sections: [ConstellationSection], isLandscape: Bool, padding: CGFloat) -> some View {
        ScrollView(isLandscape ? .horizontal : .vertical, showsIndicators: false) {
            if isLandscape {
                // Horizontal: sections flow left to right
                HStack(alignment: .top, spacing: 24) {
                    ForEach(sections) { section in
                        sectionView(section: section, isLandscape: true)
                    }
                }
                .padding(padding)
            } else {
                // Vertical: sections flow top to bottom
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(sections) { section in
                        sectionView(section: section, isLandscape: false)
                    }
                }
                .padding(padding)
            }
        }
    }

    @ViewBuilder
    private func sectionView(section: ConstellationSection, isLandscape: Bool) -> some View {
        let headerColor = isConstellationColorMode ? section.color : .secondary

        if isLandscape {
            // Vertical stack: header on top, orbs below in a scrollable column
            VStack(alignment: .center, spacing: 12) {
                sectionHeader(section: section, headerColor: headerColor, isCompact: true)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: orbSpacing) {
                        ForEach(section.portals) { portal in
                            makePortalOrbView(
                                portal: portal,
                                colorOverride: isConstellationColorMode ? section.color : nil
                            )
                        }
                    }
                }
            }
        } else {
            // Horizontal flow: header on top, orbs in a scrollable row
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(section: section, headerColor: headerColor, isCompact: false)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: orbSpacing) {
                        ForEach(section.portals) { portal in
                            makePortalOrbView(
                                portal: portal,
                                colorOverride: isConstellationColorMode ? section.color : nil
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader(section: ConstellationSection, headerColor: Color, isCompact: Bool) -> some View {
        HStack(spacing: 6) {
            // Constellation icon with color
            Image(systemName: section.icon)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundStyle(headerColor)

            // Constellation name
            Text(section.name)
                .font(.system(size: isCompact ? 12 : 14, weight: .medium))
                .foregroundStyle(isConstellationColorMode ? headerColor : .secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(headerColor.opacity(isConstellationColorMode ? 0.15 : 0.08))
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)

            Text("No portals")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Drop links here or select a constellation")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Scrollable Orb Row (Horizontal)

private struct ScrollableOrbRow: View {
    let portals: [Portal]
    let constellationColor: Color?
    let constellationColorForPortal: ((Portal) -> Color?)?
    let orbSize: CGFloat
    let orbSpacing: CGFloat
    let contentPadding: CGFloat
    let onOpen: (Portal) -> Void

    // Micro-action callbacks
    var onEdit: ((Portal) -> Void)? = nil
    var onDelete: ((Portal) -> Void)? = nil
    var onTogglePin: ((Portal) -> Void)? = nil
    var onToggleConstellation: ((Portal, Constellation) -> Void)? = nil
    var allConstellations: [Constellation] = []
    var constellationIDsForPortal: ((Portal) -> Set<UUID>)? = nil
    var onCreateConstellation: ((Portal) -> Void)? = nil

    @State private var canScrollLeft = false
    @State private var canScrollRight = false

    /// Get the constellation color for a portal (uses lookup if available, otherwise falls back to shared color)
    private func colorForPortal(_ portal: Portal) -> Color? {
        if let lookup = constellationColorForPortal {
            return lookup(portal)
        }
        return constellationColor
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: orbSpacing) {
                        ForEach(portals) { portal in
                            PortalOrbView(
                                portal: portal,
                                constellationColor: colorForPortal(portal),
                                size: orbSize,
                                onOpen: { onOpen(portal) },
                                onEdit: onEdit != nil ? { onEdit?(portal) } : nil,
                                onDelete: onDelete != nil ? { onDelete?(portal) } : nil,
                                onTogglePin: onTogglePin != nil ? { onTogglePin?(portal) } : nil,
                                onToggleConstellation: onToggleConstellation != nil ? { constellation in
                                    onToggleConstellation?(portal, constellation)
                                } : nil,
                                constellations: allConstellations,
                                portalConstellationIDs: constellationIDsForPortal?(portal) ?? [],
                                onCreateConstellation: onCreateConstellation != nil ? { onCreateConstellation?(portal) } : nil
                            )
                        }
                    }
                    .padding(.horizontal, contentPadding)
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: ScrollOffset(
                                    offset: contentGeo.frame(in: .named("scrollRow")).minX,
                                    contentWidth: contentGeo.size.width,
                                    containerWidth: geo.size.width
                                )
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scrollRow")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    updateScrollIndicators(value)
                }

                // Scroll indicators
                HStack {
                    // Left fade indicator
                    if canScrollLeft {
                        scrollIndicatorGradient(isLeading: true)
                    }
                    Spacer()
                    // Right fade indicator
                    if canScrollRight {
                        scrollIndicatorGradient(isLeading: false)
                    }
                }
                .allowsHitTesting(false)
            }
        }
    }

    private func updateScrollIndicators(_ scroll: ScrollOffset) {
        let threshold: CGFloat = 10
        canScrollLeft = scroll.offset < -threshold
        canScrollRight = scroll.contentWidth > scroll.containerWidth &&
                         scroll.offset > -(scroll.contentWidth - scroll.containerWidth - threshold)
    }

    private func scrollIndicatorGradient(isLeading: Bool) -> some View {
        HStack(spacing: 0) {
            if !isLeading { Spacer() }

            ZStack {
                // Dark edge bar
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 4)
                    .blur(radius: 2)

                // Gradient fade
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: isLeading ? .leading : .trailing,
                    endPoint: isLeading ? .trailing : .leading
                )
                .frame(width: 50)

                // Chevron with background pill
                HStack {
                    if !isLeading { Spacer() }
                    Image(systemName: isLeading ? "chevron.left" : "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.5), in: Circle())
                    if isLeading { Spacer() }
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 50)

            if isLeading { Spacer() }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Scrollable Orb Column (Vertical)

private struct ScrollableOrbColumn: View {
    let portals: [Portal]
    let constellationColor: Color?
    let constellationColorForPortal: ((Portal) -> Color?)?
    let orbSize: CGFloat
    let orbSpacing: CGFloat
    let contentPadding: CGFloat
    let onOpen: (Portal) -> Void

    // Micro-action callbacks
    var onEdit: ((Portal) -> Void)? = nil
    var onDelete: ((Portal) -> Void)? = nil
    var onTogglePin: ((Portal) -> Void)? = nil
    var onToggleConstellation: ((Portal, Constellation) -> Void)? = nil
    var allConstellations: [Constellation] = []
    var constellationIDsForPortal: ((Portal) -> Set<UUID>)? = nil
    var onCreateConstellation: ((Portal) -> Void)? = nil

    @State private var canScrollUp = false
    @State private var canScrollDown = false

    /// Get the constellation color for a portal (uses lookup if available, otherwise falls back to shared color)
    private func colorForPortal(_ portal: Portal) -> Color? {
        if let lookup = constellationColorForPortal {
            return lookup(portal)
        }
        return constellationColor
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: orbSpacing) {
                        ForEach(portals) { portal in
                            PortalOrbView(
                                portal: portal,
                                constellationColor: colorForPortal(portal),
                                size: orbSize,
                                onOpen: { onOpen(portal) },
                                onEdit: onEdit != nil ? { onEdit?(portal) } : nil,
                                onDelete: onDelete != nil ? { onDelete?(portal) } : nil,
                                onTogglePin: onTogglePin != nil ? { onTogglePin?(portal) } : nil,
                                onToggleConstellation: onToggleConstellation != nil ? { constellation in
                                    onToggleConstellation?(portal, constellation)
                                } : nil,
                                constellations: allConstellations,
                                portalConstellationIDs: constellationIDsForPortal?(portal) ?? [],
                                onCreateConstellation: onCreateConstellation != nil ? { onCreateConstellation?(portal) } : nil
                            )
                        }
                    }
                    .padding(.vertical, contentPadding)
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: ScrollOffset(
                                    offset: contentGeo.frame(in: .named("scrollColumn")).minY,
                                    contentWidth: contentGeo.size.height, // Using width field for height
                                    containerWidth: geo.size.height // Using width field for height
                                )
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scrollColumn")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    updateScrollIndicators(value)
                }

                // Scroll indicators
                VStack {
                    // Top fade indicator
                    if canScrollUp {
                        scrollIndicatorGradient(isTop: true)
                    }
                    Spacer()
                    // Bottom fade indicator
                    if canScrollDown {
                        scrollIndicatorGradient(isTop: false)
                    }
                }
                .allowsHitTesting(false)
            }
        }
    }

    private func updateScrollIndicators(_ scroll: ScrollOffset) {
        let threshold: CGFloat = 10
        canScrollUp = scroll.offset < -threshold
        canScrollDown = scroll.contentWidth > scroll.containerWidth &&
                        scroll.offset > -(scroll.contentWidth - scroll.containerWidth - threshold)
    }

    private func scrollIndicatorGradient(isTop: Bool) -> some View {
        VStack(spacing: 0) {
            if !isTop { Spacer() }

            ZStack {
                // Dark edge bar
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .frame(height: 4)
                    .blur(radius: 2)

                // Gradient fade
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: isTop ? .top : .bottom,
                    endPoint: isTop ? .bottom : .top
                )
                .frame(height: 50)

                // Chevron with background pill
                VStack {
                    if !isTop { Spacer() }
                    Image(systemName: isTop ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.5), in: Circle())
                    if isTop { Spacer() }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 50)

            if isTop { Spacer() }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Scroll Offset Tracking

private struct ScrollOffset: Equatable {
    let offset: CGFloat
    let contentWidth: CGFloat
    let containerWidth: CGFloat
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue = ScrollOffset(offset: 0, contentWidth: 0, containerWidth: 0)
    static func reduce(value: inout ScrollOffset, nextValue: () -> ScrollOffset) {
        value = nextValue()
    }
}

// MARK: - Previews

#Preview("Single Row - Landscape") {
    OrbLinearField(
        portals: Array(Portal.samples.prefix(5)),
        onOpen: { _ in }
    )
    .frame(width: 700, height: 200)
    .padding()
}

#Preview("Two Rows - Landscape") {
    OrbLinearField(
        portals: Portal.samples,
        onOpen: { _ in }
    )
    .frame(width: 700, height: 350)
    .padding()
}

#Preview("Three Rows - Landscape") {
    OrbLinearField(
        portals: Portal.samples + Portal.samples,
        onOpen: { _ in }
    )
    .frame(width: 700, height: 500)
    .padding()
}

#Preview("Single Column - Portrait") {
    OrbLinearField(
        portals: Array(Portal.samples.prefix(4)),
        onOpen: { _ in }
    )
    .frame(width: 200, height: 500)
    .padding()
}

#Preview("Two Columns - Portrait") {
    OrbLinearField(
        portals: Portal.samples,
        onOpen: { _ in }
    )
    .frame(width: 350, height: 500)
    .padding()
}

#Preview("Empty State") {
    OrbLinearField(
        portals: [],
        onOpen: { _ in }
    )
    .frame(width: 300, height: 400)
    .padding()
}
