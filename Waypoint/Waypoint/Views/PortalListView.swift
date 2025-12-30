//
//  PortalListView.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct PortalListView: View {

    // MARK: - Properties

    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager
    @State private var showAddPortal = false
    @State private var portalToEdit: Portal?
    @State private var showQuickStart = false
    @State private var showCreateConstellation = false
    @State private var portalForNewConstellation: Portal?

    // Quick Add state
    @State private var showQuickAdd = false
    @State private var quickAddURL = ""
    @State private var showQuickPasteSuccess = false
    @State private var quickPastePortalName = ""

    // Drag & Drop state
    @State private var isDropTargeted = false
    @State private var pendingDropURLs: [URL] = []
    @State private var showBatchConfirmation = false
    @State private var showDropSuccess = false
    @State private var lastDropCount = 0

    // Constellation assignment feedback
    @State private var showConstellationAssigned = false
    @State private var assignedConstellationName = ""

    // Sorting and filtering
    @State private var sortOrder: SortOrder = .dateAdded
    @State private var filterOption: FilterOption = .all
    
    enum SortOrder: String, CaseIterable {
        case custom = "Custom"
        case dateAdded = "Date Added"
        case recent = "Recently Used"
        case name = "Name"
    }
    
    enum FilterOption: Hashable {
        case all
        case pinned
        case constellation(UUID)

        var displayName: String {
            switch self {
            case .all: return "All"
            case .pinned: return "Pinned"
            case .constellation: return "Constellation"
            }
        }
    }
    
    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if portalManager.portals.isEmpty {
                    emptyStateView
                        .dropDestination(for: String.self) { items, location in
                            handleDroppedStrings(items)
                            return true
                        } isTargeted: { targeted in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isDropTargeted = targeted
                            }
                        }
                } else {
                    portalListView
                        .dropDestination(for: String.self) { items, location in
                            handleDroppedStrings(items)
                            return true
                        } isTargeted: { targeted in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isDropTargeted = targeted
                            }
                        }
                }
            }
            .navigationTitle("")
            .toolbar {
                // Quick Add URL (first)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showQuickAdd = true
                    } label: {
                        Image(systemName: "link.badge.plus")
                    }
                    .help("Quick Add URL")
                }

                // Quick Paste from clipboard (second)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        quickPasteFromClipboard()
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .help("Quick Paste from Clipboard")
                }

                // Consolidated View Options menu (Sort + Filter)
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        // Filter section
                        Section("Filter") {
                            Button {
                                filterOption = .all
                            } label: {
                                Label("All", systemImage: filterOption == .all ? "checkmark" : "circle")
                            }

                            Button {
                                filterOption = .pinned
                            } label: {
                                Label("Pinned", systemImage: filterOption == .pinned ? "checkmark" : "pin")
                            }
                        }

                        // Constellation filters
                        if !constellationManager.constellations.isEmpty {
                            Section("Constellations") {
                                ForEach(constellationManager.constellations) { constellation in
                                    Button {
                                        filterOption = .constellation(constellation.id)
                                    } label: {
                                        Label(
                                            constellation.name,
                                            systemImage: filterOption == .constellation(constellation.id) ? "checkmark" : constellation.icon
                                        )
                                    }
                                }
                            }
                        }

                        // Sort section
                        Section("Sort By") {
                            Picker("Sort By", selection: $sortOrder) {
                                ForEach(SortOrder.allCases, id: \.self) { order in
                                    Text(order.rawValue).tag(order)
                                }
                            }
                        }
                    } label: {
                        Label("View Options", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                // Debug menu for testing
                #if DEBUG
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Button("Load Sample Data") {
                            portalManager.loadSampleData()
                        }
                        
                        Button("Clear All", role: .destructive) {
                            portalManager.clearAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showAddPortal) {
                AddPortalView()
            }
            .sheet(item: $portalToEdit) { portal in
                AddPortalView(editingPortal: portal)
            }
            .sheet(isPresented: $showQuickStart) {
                QuickStartPortalsView(isFirstTime: true)
            }
            .sheet(isPresented: $showBatchConfirmation) {
                batchConfirmationView
            }
            // Drop zone visual overlay
            .overlay {
                if isDropTargeted {
                    dropZoneOverlay
                }
            }
            // Success toast overlay
            .overlay(alignment: .bottom) {
                if showDropSuccess {
                    dropSuccessToast
                }
            }
            // Constellation assignment toast
            .overlay(alignment: .bottom) {
                if showConstellationAssigned {
                    constellationAssignedToast
                }
            }
            // Create constellation sheet
            .sheet(isPresented: $showCreateConstellation) {
                CreateConstellationView(initialPortal: portalForNewConstellation)
            }
            // Quick Add alert
            .alert("Quick Add", isPresented: $showQuickAdd) {
                TextField("URL", text: $quickAddURL)
                    .textContentType(.URL)
                Button("Add") {
                    quickAddFromURL()
                }
                Button("Cancel", role: .cancel) {
                    quickAddURL = ""
                }
            } message: {
                Text("Enter a URL to create a portal")
            }
            // Quick Paste success toast
            .overlay(alignment: .bottom) {
                if showQuickPasteSuccess {
                    quickPasteSuccessToast
                }
            }
        }
    }

    // MARK: - Quick Paste Success Toast

    private var quickPasteSuccessToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text("Created: \(quickPastePortalName)")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Constellation Assigned Toast

    private var constellationAssignedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.circle.fill")
                .foregroundStyle(.blue)

            Text("Added to \(assignedConstellationName)")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Drop Zone Overlay

    private var dropZoneOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [10]))
                .foregroundStyle(.blue)

            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Drop to Create Portals")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    // MARK: - Drop Success Toast

    private var dropSuccessToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text("\(lastDropCount) portal\(lastDropCount == 1 ? "" : "s") created")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Batch Confirmation View

    private var batchConfirmationView: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "tray.and.arrow.down.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Create \(pendingDropURLs.count) Portals?")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(DropService.batchSummaryText(for: pendingDropURLs))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Preview list (first 5)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(pendingDropURLs.prefix(5), id: \.self) { url in
                        HStack {
                            Image(systemName: PortalType.detect(from: url).iconName)
                                .foregroundStyle(.secondary)
                                .frame(width: 24)

                            Text(DropService.extractSmartName(from: url))
                                .lineLimit(1)

                            Spacer()
                        }
                        .font(.subheadline)
                    }

                    if pendingDropURLs.count > 5 {
                        Text("+ \(pendingDropURLs.count - 5) more...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 32)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
            .navigationTitle("Batch Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        pendingDropURLs = []
                        showBatchConfirmation = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create All") {
                        confirmBatchDrop()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    // MARK: - Quick Actions

    private func quickPasteFromClipboard() {
        #if os(visionOS) || os(iOS)
        guard let clipboardString = UIPasteboard.general.string else {
            print("⚠️ No text in clipboard")
            return
        }

        let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try to create URL
        var url: URL?
        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            url = directURL
        } else if trimmed.contains(".") && !trimmed.contains(" ") {
            url = URL(string: "https://" + trimmed)
        }

        guard let validURL = url else {
            print("⚠️ Clipboard doesn't contain valid URL: \(trimmed)")
            return
        }

        // Check if already exists
        if portalManager.portals.contains(where: { $0.url == validURL.absoluteString }) {
            print("⚠️ Portal already exists for this URL")
            return
        }

        // Create portal
        let portal = DropService.createPortal(from: validURL)
        portalManager.add(portal)

        // Show success toast
        quickPastePortalName = portal.name
        withAnimation {
            showQuickPasteSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showQuickPasteSuccess = false
            }
        }

        print("📋 Quick Paste created: \(portal.name)")
        #endif
    }

    private func quickAddFromURL() {
        let input = quickAddURL.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !input.isEmpty else {
            quickAddURL = ""
            return
        }

        // Build URL from input
        var urlString: String

        if input.hasPrefix("http://") || input.hasPrefix("https://") {
            // Already has scheme
            urlString = input
        } else if input.contains(".") {
            // Has domain extension (e.g., "youtube.com")
            urlString = "https://" + input
        } else {
            // Bare name (e.g., "youtube") - add .com
            urlString = "https://www.\(input).com"
        }

        guard let validURL = URL(string: urlString) else {
            print("⚠️ Invalid URL: \(urlString)")
            quickAddURL = ""
            return
        }

        // Create portal
        let portal = DropService.createPortal(from: validURL)
        portalManager.add(portal)

        // Show success toast
        quickPastePortalName = portal.name
        withAnimation {
            showQuickPasteSuccess = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showQuickPasteSuccess = false
            }
        }

        print("⌨️ Quick Add created: \(portal.name)")
        quickAddURL = ""
    }

    // MARK: - Drop Handling

    private func handleDroppedStrings(_ strings: [String]) {
        // Convert strings to URLs
        let urls = strings.compactMap { string -> URL? in
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)

            // Try as direct URL
            if let url = URL(string: trimmed) {
                return url
            }

            // Try with https prefix
            if !trimmed.contains("://") && trimmed.contains(".") {
                return URL(string: "https://" + trimmed)
            }

            return nil
        }

        guard !urls.isEmpty else {
            print("⚠️ No valid URLs found in dropped strings")
            return
        }

        handleDroppedURLs(urls)
    }

    private func handleDroppedURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }

        // Check if batch confirmation is needed
        if DropService.shouldShowBatchConfirmation(itemCount: urls.count) {
            pendingDropURLs = urls
            showBatchConfirmation = true
        } else {
            // Direct creation for small batches
            createPortals(from: urls)
        }
    }

    private func confirmBatchDrop() {
        createPortals(from: pendingDropURLs)
        pendingDropURLs = []
        showBatchConfirmation = false
    }

    private func createPortals(from urls: [URL]) {
        let newPortals = DropService.createPortals(from: urls)
        portalManager.addMultiple(newPortals)

        // Show success toast
        lastDropCount = newPortals.count
        withAnimation {
            showDropSuccess = true
        }

        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showDropSuccess = false
            }
        }

        print("🎯 Created \(newPortals.count) portals via drag & drop")
    }
    
    // MARK: - Portal List

    private var portalListView: some View {
        List {
            ForEach(filteredAndSortedPortals) { portal in
                PortalRow(portal: portal)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        openPortal(portal)
                    }
                    .contextMenu {
                        portalContextMenu(for: portal)
                    }
            }
            .onMove { source, destination in
                // Only allow move in custom sort mode
                if sortOrder == .custom && filterOption == .all {
                    portalManager.movePortals(from: source, to: destination, in: filteredAndSortedPortals)
                }
            }
        }
        .environment(\.editMode, sortOrder == .custom && filterOption == .all ? .constant(.active) : .constant(.inactive))
    }
    
    // MARK: - Filtered & Sorted Portals

    private var filteredAndSortedPortals: [Portal] {
        // First filter
        var filtered: [Portal]
        switch filterOption {
        case .all:
            filtered = portalManager.portals
        case .pinned:
            filtered = portalManager.pinnedPortals
        case .constellation(let constellationID):
            if let constellation = constellationManager.constellation(withID: constellationID) {
                filtered = portalManager.portals.filter { constellation.portalIDs.contains($0.id) }
            } else {
                filtered = portalManager.portals
            }
        }

        // Then sort
        return filtered.sorted { portal1, portal2 in
            // Pinned always comes first regardless of sort
            if portal1.isPinned != portal2.isPinned {
                return portal1.isPinned
            }

            // Then apply selected sort
            switch sortOrder {
            case .custom:
                // Sort by sortIndex (manual order)
                return portal1.sortIndex < portal2.sortIndex
            case .dateAdded:
                return portal1.dateAdded > portal2.dateAdded
            case .recent:
                let date1 = portal1.lastOpened ?? portal1.dateAdded
                let date2 = portal2.lastOpened ?? portal2.dateAdded
                return date1 > date2
            case .name:
                return portal1.name.localizedCaseInsensitiveCompare(portal2.name) == .orderedAscending
            }
        }
    }
    
    private var emptyStateView: some View {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    Text("Welcome to Waypoint")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Your digital universe awaits.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                Button {
                    showAddPortal = true
                } label: {
                    Label("Create Portal", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
                
                Button {
                    showQuickStart = true
                } label: {
                    Text("Quick start portals →")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .padding(.top, 24)
                
                Spacer()
            }
        }
    
    
    
    // MARK: - Context Menu

    @ViewBuilder
    private func portalContextMenu(for portal: Portal) -> some View {
        Button {
            openPortal(portal)
        } label: {
            Label("Open", systemImage: "arrow.up.forward.app")
        }

        Button {
            portalToEdit = portal
        } label: {
            Label("Edit", systemImage: "pencil")
        }

        // Constellation submenu
        Menu {
            if constellationManager.constellations.isEmpty {
                Text("No constellations yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(constellationManager.constellations) { constellation in
                    let isInConstellation = constellation.portalIDs.contains(portal.id)
                    Button {
                        if isInConstellation {
                            constellationManager.removePortal(portal.id, from: constellation)
                        } else {
                            constellationManager.addPortal(portal.id, to: constellation)
                            showAssignmentFeedback(constellation.name)
                        }
                    } label: {
                        Label(
                            constellation.name,
                            systemImage: isInConstellation ? "checkmark.circle.fill" : constellation.icon
                        )
                    }
                }
            }

            Divider()

            Button {
                portalForNewConstellation = portal
                showCreateConstellation = true
            } label: {
                Label("Create New...", systemImage: "plus.circle")
            }
        } label: {
            Label("Add to Constellation", systemImage: "star.circle")
        }

        Divider()

        Button {
            portalManager.togglePin(portal)
        } label: {
            Label(
                portal.isPinned ? "Unpin" : "Pin to Top",
                systemImage: portal.isPinned ? "mappin.slash.circle" : "mappin.circle.fill"
            )
        }

        Divider()

        Button(role: .destructive) {
            portalManager.delete(portal)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func showAssignmentFeedback(_ constellationName: String) {
        assignedConstellationName = constellationName
        withAnimation {
            showConstellationAssigned = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showConstellationAssigned = false
            }
        }
    }
    
    // MARK: - Actions
    
    private func openPortal(_ portal: Portal) {
        guard let url = URL(string: portal.url) else {
            print("❌ Invalid URL: \(portal.url)")
            return
        }
        
        // Update last opened timestamp
        portalManager.updateLastOpened(portal)
        
        // Open URL - system handles window placement
        #if os(visionOS)
        UIApplication.shared.open(url) { success in
            if success {
                print("🚀 Opened portal: \(portal.name)")
            } else {
                print("❌ Failed to open portal: \(portal.name)")
            }
        }
        #else
        NSWorkspace.shared.open(url)
        print("🚀 Opened portal: \(portal.name)")
        #endif
    }
}

// MARK: - Portal Row

struct PortalRow: View {
    let portal: Portal
    @Environment(ConstellationManager.self) private var constellationManager

    private var portalConstellations: [Constellation] {
        constellationManager.constellationsContaining(portalID: portal.id)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail or placeholder
            thumbnailView
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Portal info
            VStack(alignment: .leading, spacing: 4) {
                Text(portal.name)
                    .font(.headline)

                if let lastOpened = portal.lastOpened {
                    Text("Last opened: \(lastOpened, formatter: relativeFormatter)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Added \(portal.dateAdded, formatter: relativeFormatter)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Constellation icons
            if !portalConstellations.isEmpty {
                HStack(spacing: 4) {
                    ForEach(portalConstellations.prefix(3)) { constellation in
                        Image(systemName: constellation.icon)
                            .foregroundStyle(Color(hex: constellation.colorHex))
                            .font(.caption)
                    }
                    if portalConstellations.count > 3 {
                        Text("+\(portalConstellations.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Pin indicator
            if portal.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Thumbnail
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let thumbnailData = portal.displayThumbnail,
           let uiImage = UIImage(data: thumbnailData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            // Placeholder with first letter
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                
                Text(portal.name.prefix(1).uppercased())
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Formatters

private let relativeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter
}()

// MARK: - Preview

#Preview {
    PortalListView()
        .environment(PortalManager())
}
