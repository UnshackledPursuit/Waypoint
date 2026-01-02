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
    @State private var constellationToEdit: Constellation?

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

    // Open failure feedback
    @State private var showOpenFailed = false
    @State private var openFailedMessage = "Couldn't open. Check iCloud share permissions."

    // Micro-actions feedback
    @State private var lastCreatedPortalID: UUID?
    @State private var focusRequestPortalID: UUID?
    @State private var microActionsPortalID: UUID?
    @State private var microActionsWorkItem: DispatchWorkItem?
    @State private var dismissMicroActionsPortalID: UUID?
    @State private var expandedConstellationPortalID: UUID?

    // Edit mode for drag/drop reordering
    @State private var editMode: EditMode = .inactive
    
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
        ZStack {
            NavigationStack {
                Group {
                    if portalManager.portals.isEmpty {
                        emptyStateView
                    } else {
                        portalListView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
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

                        // Constellation filters - tap to filter, edit via submenu
                        if !constellationManager.constellations.isEmpty {
                            Section("Constellations") {
                                // Direct tap-to-filter for each constellation
                                ForEach(constellationManager.constellations) { constellation in
                                    Button {
                                        filterOption = .constellation(constellation.id)
                                    } label: {
                                        Label {
                                            Text(constellation.name)
                                        } icon: {
                                            Image(systemName: filterOption == .constellation(constellation.id) ? "checkmark" : constellation.icon)
                                        }
                                    }
                                }
                            }

                            // Manage constellations section
                            Section("Manage") {
                                // Edit constellation - opens directly, picker inside
                                Button {
                                    if let first = constellationManager.constellations.first {
                                        constellationToEdit = first
                                    }
                                } label: {
                                    Label("Edit Constellations", systemImage: "pencil")
                                }

                                // Create new constellation
                                Button {
                                    portalForNewConstellation = nil
                                    showCreateConstellation = true
                                } label: {
                                    Label("New Constellation", systemImage: "plus.circle")
                                }
                            }
                        } else {
                            // No constellations yet - show create option
                            Section("Constellations") {
                                Button {
                                    portalForNewConstellation = nil
                                    showCreateConstellation = true
                                } label: {
                                    Label("Create Constellation...", systemImage: "plus.circle")
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
                            constellationManager.loadSampleData()
                        }

                        Button("Clear Portals", role: .destructive) {
                            portalManager.clearAll()
                        }

                        Button("Clear Constellations", role: .destructive) {
                            constellationManager.clearAll()
                        }

                        Button("Clear All", role: .destructive) {
                            portalManager.clearAll()
                            constellationManager.clearAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showAddPortal) {
                AddPortalView(
                    focusRequestPortalID: $focusRequestPortalID,
                    dismissMicroActionsPortalID: $dismissMicroActionsPortalID
                )
            }
            .sheet(item: $portalToEdit) { portal in
                AddPortalView(
                    editingPortal: portal,
                    focusRequestPortalID: $focusRequestPortalID,
                    dismissMicroActionsPortalID: $dismissMicroActionsPortalID
                )
            }
            .sheet(isPresented: $showQuickStart) {
                QuickStartPortalsView(isFirstTime: true)
            }
            .sheet(isPresented: $showQuickAdd) {
                QuickAddPortalView(
                    initialURL: quickAddURL,
                    onCancel: { quickAddURL = "" },
                    onSubmit: { urlString in
                        quickAddURL = urlString
                        quickAddFromURL()
                    }
                )
            }
            .sheet(isPresented: $showBatchConfirmation) {
                batchConfirmationView
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
                // Edit constellation sheet
                .sheet(item: $constellationToEdit) { constellation in
                    EditConstellationView(constellation: constellation)
                }
                // Quick Paste success toast
                .overlay(alignment: .bottom) {
                    if showQuickPasteSuccess {
                        quickPasteSuccessToast
                    }
                }
                // Open failed toast
                .overlay(alignment: .bottom) {
                    if showOpenFailed {
                        openFailedToast
                    }
                }
            }

            DropInteractionView(
                allowedTypeIdentifiers: [
                    UTType.url.identifier,
                    UTType.fileURL.identifier,
                    UTType.text.identifier,
                    UTType.pdf.identifier,
                    UTType.item.identifier
                ],
                onTargetedChange: { targeted in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isDropTargeted = targeted
                    }
                },
                onDrop: { providers in
                    Task {
                        let urls = await DropParser.extractURLs(from: providers)
                        await MainActor.run {
                            handleDroppedURLs(urls)
                        }
                    }
                }
            )
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    // MARK: - Open Failed Toast

    private var openFailedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)

            Text(openFailedMessage)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
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

        // Check if portal already exists
        if let existingPortal = existingPortal(for: validURL) {
            // If filtering by constellation, add existing portal to that constellation
            if case .constellation(let constellationID) = filterOption,
               let constellation = constellationManager.constellation(withID: constellationID) {
                if !constellation.portalIDs.contains(existingPortal.id) {
                    constellationManager.addPortal(existingPortal.id, to: constellation)
                    showAssignmentFeedback(constellation.name)
                }
            }

            // Show feedback for existing portal
            quickPastePortalName = "Found: \(existingPortal.name)"
            withAnimation {
                showQuickPasteSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showQuickPasteSuccess = false
                }
            }

            // Scroll to and highlight the existing portal
            requestFocus(on: existingPortal.id)
            print("📋 Quick Paste found existing: \(existingPortal.name)")
        } else if let portal = createPortalIfNeeded(from: validURL) {
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
        }
        #endif
    }

    private func quickAddFromURL() {
        let input = quickAddURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedInput = input.lowercased()
        guard !input.isEmpty else {
            quickAddURL = ""
            return
        }

        // Build URL from input
        var urlString: String

        if lowercasedInput.hasPrefix("http://") || lowercasedInput.hasPrefix("https://") {
            // Already has scheme
            urlString = input
        } else if lowercasedInput.contains(".") {
            // Has domain extension (e.g., "youtube.com")
            urlString = "https://" + input
        } else {
            // Bare name (e.g., "youtube") - add .com
            urlString = "https://www.\(input).com"
        }

        // Auto-add www for sites that need it for login persistence
        let sitesNeedingWWW = ["youtube.com", "instagram.com", "reddit.com", "wikipedia.org"]
        for site in sitesNeedingWWW {
            if urlString.contains("://\(site)") && !urlString.contains("://www.\(site)") {
                urlString = urlString.replacingOccurrences(of: "://\(site)", with: "://www.\(site)")
                break
            }
        }

        guard let validURL = URL(string: urlString) else {
            print("⚠️ Invalid URL: \(urlString)")
            quickAddURL = ""
            return
        }

        if let portal = createPortalIfNeeded(from: validURL) {
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
        }
        quickAddURL = ""
    }

    // MARK: - Drop Handling

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
        var newPortals: [Portal] = []
        var duplicateIDs: [UUID] = []

        for url in urls {
            if let existingPortal = existingPortal(for: url) {
                duplicateIDs.append(existingPortal.id)
            } else {
                newPortals.append(DropService.createPortal(from: url))
            }
        }

        if !newPortals.isEmpty {
            portalManager.addMultiple(newPortals)
            registerCreatedPortal(newPortals.last)

            lastDropCount = newPortals.count
            withAnimation {
                showDropSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showDropSuccess = false
                }
            }

            print("🎯 Created \(newPortals.count) portals via drag & drop")
        }

        if newPortals.isEmpty, let duplicateID = duplicateIDs.first {
            requestFocus(on: duplicateID)
            print("🔁 Summoned existing portal from drop")
        }
    }

    // MARK: - Portal List

    private var portalListView: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(filteredAndSortedPortals) { portal in
                    VStack(alignment: .leading, spacing: 8) {
                        // Portal row wrapped in Button for reliable tap, with long-press gesture
                        Button {
                            // Tap action
                            if let currentID = microActionsPortalID {
                                dismissMicroActions(for: currentID)
                            } else {
                                openPortal(portal)
                            }
                        } label: {
                            PortalRow(portal: portal)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    // Long press - show micro-actions
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        expandedConstellationPortalID = nil
                                        microActionsPortalID = portal.id
                                    }
                                    scheduleMicroActionsDismiss(for: portal.id)
                                }
                        )

                        // Micro-actions - NO parent gestures interfere
                        if microActionsPortalID == portal.id {
                            microActionsView(for: portal)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: microActionsPortalID)
                    .id(portal.id)
                }
                // TEMPORARILY DISABLED: onMove conflicts with long-press gesture
                // .onMove { source, destination in
                //     // Allow move in custom sort mode for any filter
                //     if sortOrder == .custom {
                //         portalManager.movePortals(from: source, to: destination, in: filteredAndSortedPortals)
                //     }
                // }
            }
            // TEMPORARILY DISABLED: Edit mode conflicts with long-press gesture
            // .environment(\.editMode, $editMode)
            // .onChange(of: sortOrder) { _, newValue in
            //     withAnimation {
            //         editMode = newValue == .custom ? .active : .inactive
            //     }
            // }
            // .onAppear {
            //     editMode = sortOrder == .custom ? .active : .inactive
            // }
            .onChange(of: focusRequestPortalID) { _, portalID in
                guard let portalID else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(portalID, anchor: .center)
                }
                // Delay micro actions until scroll animation settles
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showMicroActions(for: portalID)
                }
            }
            .onChange(of: dismissMicroActionsPortalID) { _, portalID in
                guard let portalID else { return }
                dismissMicroActions(for: portalID)
                dismissMicroActionsPortalID = nil
            }
        }
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
    

    // MARK: - Feedback

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

        // Open URL - system handles window placement
        #if os(visionOS) || os(iOS)
        UIApplication.shared.open(url) { success in
            if success {
                // Update last opened timestamp
                portalManager.updateLastOpened(portal)
                print("🚀 Opened portal: \(portal.name)")
            } else {
                print("❌ Failed to open portal: \(portal.name)")
                showOpenFailedToast()
            }
        }
        #else
        let success = NSWorkspace.shared.open(url)
        if success {
            portalManager.updateLastOpened(portal)
            print("🚀 Opened portal: \(portal.name)")
        } else {
            print("❌ Failed to open portal: \(portal.name)")
            showOpenFailedToast()
        }
        #endif
    }

    private func showOpenFailedToast(message: String = "Couldn't open. Check iCloud share permissions.") {
        openFailedMessage = message
        withAnimation {
            showOpenFailed = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showOpenFailed = false
            }
        }
    }

    // MARK: - Micro-Actions

    private func requestFocus(on portalID: UUID) {
        focusRequestPortalID = portalID
    }

    private func showMicroActions(for portalID: UUID) {
        // Clean up any stale state first
        expandedConstellationPortalID = nil
        microActionsWorkItem?.cancel()
        microActionsWorkItem = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            microActionsPortalID = portalID
        }
        scheduleMicroActionsDismiss(for: portalID)
    }

    private func pauseAutoDismiss() {
        // Completely pause timer while orbital picker is open
        microActionsWorkItem?.cancel()
        microActionsWorkItem = nil
    }

    private func resumeAutoDismiss(for portalID: UUID) {
        // Resume timer when orbital picker closes
        guard microActionsPortalID == portalID else { return }
        scheduleMicroActionsDismiss(for: portalID, after: 6.0)
    }

    private func dismissMicroActions(for portalID: UUID) {
        guard microActionsPortalID == portalID else { return }
        microActionsWorkItem?.cancel()
        microActionsWorkItem = nil
        expandedConstellationPortalID = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            microActionsPortalID = nil
        }
        if focusRequestPortalID == portalID {
            focusRequestPortalID = nil
        }
    }

    private func scheduleMicroActionsDismiss(for portalID: UUID, after delay: TimeInterval = 6.0) {
        microActionsWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            dismissMicroActions(for: portalID)
        }
        microActionsWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func registerCreatedPortal(_ portal: Portal?) {
        guard let portal else { return }
        lastCreatedPortalID = portal.id
        requestFocus(on: portal.id)
    }

    private func existingPortal(for url: URL) -> Portal? {
        portalManager.portals.first { URLNormalizer.matches($0.url, url.absoluteString) }
    }

    private func createPortalIfNeeded(from url: URL) -> Portal? {
        if let existingPortal = existingPortal(for: url) {
            // If filtering by constellation, add existing portal to that constellation
            if case .constellation(let constellationID) = filterOption,
               let constellation = constellationManager.constellation(withID: constellationID) {
                if !constellation.portalIDs.contains(existingPortal.id) {
                    constellationManager.addPortal(existingPortal.id, to: constellation)
                    showAssignmentFeedback(constellation.name)
                    print("🔁 Added existing portal to constellation: \(constellation.name)")
                }
            }
            requestFocus(on: existingPortal.id)
            print("🔁 Summoned existing portal")
            return nil
        }

        let portal = DropService.createPortal(from: url)
        portalManager.add(portal)

        // If filtering by constellation, add new portal to that constellation
        if case .constellation(let constellationID) = filterOption,
           let constellation = constellationManager.constellation(withID: constellationID) {
            constellationManager.addPortal(portal.id, to: constellation)
            print("✨ Added new portal to constellation: \(constellation.name)")
        }

        registerCreatedPortal(portal)
        return portal
    }

    @ViewBuilder
    private func microActionsView(for portal: Portal) -> some View {
        VStack(spacing: 8) {
            // Constellation orbital picker (shows when expanded)
            if expandedConstellationPortalID == portal.id {
                constellationOrbitalPicker(for: portal)
                    .transition(.scale.combined(with: .opacity))
            }

            // Main action buttons
            HStack(spacing: 12) {
                // Constellation toggle button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        if expandedConstellationPortalID == portal.id {
                            // Closing picker - resume auto-dismiss
                            expandedConstellationPortalID = nil
                            resumeAutoDismiss(for: portal.id)
                        } else {
                            // Opening picker - pause auto-dismiss
                            pauseAutoDismiss()
                            expandedConstellationPortalID = portal.id
                        }
                    }
                } label: {
                    let assignedCount = constellationManager.constellations.filter { $0.portalIDs.contains(portal.id) }.count
                    Image(systemName: assignedCount > 0 ? "sparkles" : "sparkle")
                        .font(.title2)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)

                // Pin button
                Button {
                    portalManager.togglePin(portal)
                    // Reset timer on interaction
                    scheduleMicroActionsDismiss(for: portal.id)
                } label: {
                    Image(systemName: portal.isPinned ? "mappin.slash" : "mappin")
                        .font(.title2)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)

                // Edit button
                Button {
                    dismissMicroActions(for: portal.id)
                    portalToEdit = portal
                } label: {
                    Image(systemName: "pencil")
                        .font(.title2)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)

                // Delete button (neutral color)
                Button {
                    dismissMicroActions(for: portal.id)
                    portalManager.delete(portal)
                } label: {
                    Image(systemName: "trash")
                        .font(.title2)
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)

                // Done button (green checkmark)
                Button {
                    dismissMicroActions(for: portal.id)
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .symbolVariant(.circle.fill)
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            #if os(visionOS)
            .glassBackgroundEffect(in: Capsule())
            #else
            .background(.regularMaterial, in: Capsule())
            #endif
        }
    }

    @ViewBuilder
    private func constellationOrbitalPicker(for portal: Portal) -> some View {
        HStack(spacing: 16) {
            ForEach(constellationManager.constellations) { constellation in
                let isAssigned = constellation.portalIDs.contains(portal.id)
                Button {
                    // Just toggle - don't dismiss, don't reset timer
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                        if isAssigned {
                            constellationManager.removePortal(portal.id, from: constellation)
                        } else {
                            constellationManager.addPortal(portal.id, to: constellation)
                            showAssignmentFeedback(constellation.name)
                        }
                    }
                } label: {
                    ZStack {
                        // Vibrant colored circle with icon
                        Circle()
                            .fill(constellation.color.opacity(isAssigned ? 1.0 : 0.75))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(isAssigned ? Color.white : Color.clear, lineWidth: 2)
                            )
                            .shadow(color: constellation.color.opacity(isAssigned ? 0.6 : 0.3), radius: isAssigned ? 4 : 2)

                        Image(systemName: constellation.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)

                        // Small checkmark badge when assigned (inside orb area)
                        if isAssigned {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 14, height: 14)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .offset(x: 12, y: 12)
                        }
                    }
                    .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        constellationToEdit = constellation
                    } label: {
                        Label("Edit \(constellation.name)", systemImage: "pencil")
                    }
                }
            }

            // Add new constellation button
            Button {
                dismissMicroActions(for: portal.id)
                portalForNewConstellation = portal
                showCreateConstellation = true
            } label: {
                Circle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        #if os(visionOS)
        .glassBackgroundEffect(in: Capsule())
        #else
        .background(.regularMaterial, in: Capsule())
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

// MARK: - Quick Add Portal View

private struct QuickAddPortalView: View {
    @Environment(\.dismiss) private var dismiss

    let initialURL: String
    let onCancel: () -> Void
    let onSubmit: (String) -> Void

    @State private var urlText: String

    init(initialURL: String, onCancel: @escaping () -> Void, onSubmit: @escaping (String) -> Void) {
        self.initialURL = initialURL
        self.onCancel = onCancel
        self.onSubmit = onSubmit
        _urlText = State(initialValue: initialURL)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("URL", text: $urlText)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSubmit(urlText)
                        dismiss()
                    }
                    .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
