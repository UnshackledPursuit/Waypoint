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
    @Environment(NavigationState.self) private var navigationState

    // Onboarding toast state
    @State private var showFirstPortalToast = false
    @State private var showDragHintToast = false
    @State private var showConstellationHint = false
    @State private var newConstellationName = ""

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

    // Sorting uses shared NavigationState (navigationState.filterOption and sortOrder)

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
    
    // SortOrder and FilterOption are now in NavigationState.swift

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
                #if os(visionOS)
                .toolbar(.hidden, for: .navigationBar)
                #endif
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
                // Onboarding toast - first portal
                .overlay(alignment: .top) {
                    if showFirstPortalToast {
                        OnboardingToastView(
                            message: "Portal created!",
                            submessage: "Tap to open • Drag more links to add"
                        ) {
                            showFirstPortalToast = false
                        }
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                // Onboarding hint - first constellation
                .overlay(alignment: .top) {
                    if showConstellationHint {
                        ConstellationHintView(constellationName: newConstellationName) {
                            showConstellationHint = false
                        }
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                // Watch for new portals added via AddPortalView
                .onChange(of: portalManager.portals.count) { oldCount, newCount in
                    if newCount > oldCount {
                        handlePortalAdded()
                    }
                }
                // Watch for new constellations created
                .onChange(of: constellationManager.constellations.count) { oldCount, newCount in
                    if newCount > oldCount {
                        handleConstellationAdded()
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
            if case .constellation(let constellationID) = navigationState.filterOption,
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

            // Trigger favicon fetch if existing portal doesn't have one
            if existingPortal.thumbnailData == nil {
                Task {
                    await portalManager.fetchFavicon(for: existingPortal.id)
                }
            }

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
            registerCreatedPortal(newPortals.last, viaDrag: true)

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

            // Trigger favicon fetch for duplicate if it doesn't have one
            if let existingPortal = portalManager.portal(withID: duplicateID),
               existingPortal.thumbnailData == nil {
                Task {
                    await portalManager.fetchFavicon(for: duplicateID)
                }
            }

            print("🔁 Summoned existing portal from drop")
        }
    }

    // MARK: - Portal List

    private var portalListView: some View {
        GeometryReader { geometry in
            let layout = calculateListLayout(size: geometry.size)

            ScrollViewReader { proxy in
                ScrollView {
                    if layout.columns == 1 {
                        // Single column - vertical list style
                        LazyVStack(spacing: 2) {
                            ForEach(filteredAndSortedPortals) { portal in
                                portalListItem(portal: portal)
                                    .id(portal.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    } else {
                        // Multi-column grid
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: layout.columns),
                            spacing: 12
                        ) {
                            ForEach(filteredAndSortedPortals) { portal in
                                portalGridItem(portal: portal)
                                    .id(portal.id)
                            }
                        }
                        .padding(16)
                    }
                }
                .onChange(of: focusRequestPortalID) { _, portalID in
                    guard let portalID else { return }
                    withAnimation(.easeInOut(duration: 0.25)) {
                        proxy.scrollTo(portalID, anchor: .top)
                    }
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
    }

    // MARK: - Layout Calculation

    private struct ListLayout {
        let columns: Int
        let isCompact: Bool
    }

    private func calculateListLayout(size: CGSize) -> ListLayout {
        let width = size.width

        // Flexible 1-4 columns based on width
        // Each column needs ~220pt minimum for comfortable reading
        if width > 880 {
            return ListLayout(columns: 4, isCompact: false)
        } else if width > 660 {
            return ListLayout(columns: 3, isCompact: false)
        } else if width > 440 {
            return ListLayout(columns: 2, isCompact: false)
        }

        // Single column for narrow views
        return ListLayout(columns: 1, isCompact: width < 350)
    }

    // MARK: - Single Column List Item

    @ViewBuilder
    private func portalListItem(portal: Portal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PortalRow(portal: portal)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let currentID = microActionsPortalID {
                        dismissMicroActions(for: currentID)
                    } else {
                        openPortal(portal)
                    }
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                expandedConstellationPortalID = nil
                                microActionsPortalID = portal.id
                            }
                            scheduleMicroActionsDismiss(for: portal.id)
                        }
                )

            if microActionsPortalID == portal.id {
                microActionsView(for: portal)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        #if os(visionOS)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        #else
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        #endif
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: microActionsPortalID)
    }

    // MARK: - Grid Item (Multi-column)

    @ViewBuilder
    private func portalGridItem(portal: Portal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            PortalRow(portal: portal)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let currentID = microActionsPortalID {
                        dismissMicroActions(for: currentID)
                    } else {
                        openPortal(portal)
                    }
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                expandedConstellationPortalID = nil
                                microActionsPortalID = portal.id
                            }
                            scheduleMicroActionsDismiss(for: portal.id)
                        }
                )

            if microActionsPortalID == portal.id {
                microActionsView(for: portal)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        #if os(visionOS)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        #else
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        #endif
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: microActionsPortalID)
    }
    
    // MARK: - Filtered & Sorted Portals

    private var filteredAndSortedPortals: [Portal] {
        // First filter
        var filtered: [Portal]
        switch navigationState.filterOption {
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
            switch navigationState.sortOrder {
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
            case .constellation:
                // Sort by constellation order (first constellation a portal belongs to)
                let index1 = constellationIndex(for: portal1)
                let index2 = constellationIndex(for: portal2)
                if index1 != index2 {
                    return index1 < index2
                }
                // Within same constellation, sort by name
                return portal1.name.localizedCaseInsensitiveCompare(portal2.name) == .orderedAscending
            }
        }
    }

    /// Returns the index of the first constellation containing this portal, or Int.max if none
    private func constellationIndex(for portal: Portal) -> Int {
        for (index, constellation) in constellationManager.constellations.enumerated() {
            if constellation.portalIDs.contains(portal.id) {
                return index
            }
        }
        return Int.max // Portals not in any constellation go last
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

    private func registerCreatedPortal(_ portal: Portal?, viaDrag: Bool = false) {
        guard let portal else { return }
        lastCreatedPortalID = portal.id
        requestFocus(on: portal.id)
    }

    /// Called when a portal is added (via onChange of portals.count)
    private func handlePortalAdded() {
        // Show onboarding toast for first few portals
        let count = portalManager.portals.count

        if count <= 3 && !OnboardingState.hasShownFirstPortalHint {
            OnboardingState.hasShownFirstPortalHint = true
            // Small delay to let the sheet dismiss first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showFirstPortalToast = true
                }
            }
            print("🎉 Showing first portal toast (count: \(count))")
        }
    }

    /// Called when a constellation is added (via onChange of constellations.count)
    private func handleConstellationAdded() {
        // Show onboarding hint for first constellation
        guard let newest = constellationManager.constellations.last else { return }

        if !OnboardingState.hasShownFirstConstellationHint {
            OnboardingState.hasShownFirstConstellationHint = true
            newConstellationName = newest.name

            // Small delay to let the sheet dismiss first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showConstellationHint = true
                }
            }
            print("✨ Showing first constellation hint: \(newest.name)")
        }
    }

    private func existingPortal(for url: URL) -> Portal? {
        portalManager.portals.first { URLNormalizer.matches($0.url, url.absoluteString) }
    }

    private func createPortalIfNeeded(from url: URL) -> Portal? {
        if let existingPortal = existingPortal(for: url) {
            // If filtering by constellation, add existing portal to that constellation
            if case .constellation(let constellationID) = navigationState.filterOption,
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
        if case .constellation(let constellationID) = navigationState.filterOption,
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

    /// Global orb intensity from user preferences
    @AppStorage("orbIntensity") private var orbIntensity: Double = 0.7

    /// Global orb color mode
    @AppStorage("orbColorMode") private var orbColorModeRaw: String = OrbColorMode.defaultStyle.rawValue

    /// Global orb size preference
    @AppStorage("orbSizePreference") private var orbSizeRaw: String = "medium"

    private var orbColorMode: OrbColorMode {
        OrbColorMode(rawValue: orbColorModeRaw) ?? .defaultStyle
    }

    /// Icon size based on orb size preference
    private var iconSize: CGFloat {
        switch orbSizeRaw {
        case "small": return 28    // compact
        case "large": return 44    // original-ish
        default: return 36         // medium (default)
        }
    }

    /// Opacity multiplier based on intensity
    private var colorOpacity: Double {
        if orbColorMode == .frost || orbColorMode == .mono {
            return 0.4 // Frosted/mono look
        }
        return 0.3 + (orbIntensity * 0.7)
    }

    private var portalConstellations: [Constellation] {
        constellationManager.constellationsContaining(portalID: portal.id)
    }

    /// Whether to use gradient for multi-constellation portals (list view only)
    private var useGradient: Bool {
        orbColorMode == .constellation && portalConstellations.count > 1
    }

    /// Whether to desaturate favicons (mono mode)
    private var shouldDesaturateContent: Bool {
        orbColorMode == .mono
    }

    /// Get the effective orb color based on color mode
    private func effectiveColor(_ baseColor: Color) -> Color {
        switch orbColorMode {
        case .constellation:
            // For list view with multi-constellation, we'll use gradient (handled separately)
            // For single constellation, use that color
            return portalConstellations.first?.color ?? baseColor
        case .defaultStyle:
            return baseColor
        case .frost, .mono:
            return Color.gray
        }
    }

    /// Get gradient colors for multi-constellation portals
    private var gradientColors: [Color] {
        if portalConstellations.count > 1 {
            return portalConstellations.prefix(3).map { $0.color }
        }
        return []
    }

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail or placeholder
            thumbnailView
                .frame(width: iconSize, height: iconSize)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.2))

            // Portal info
            VStack(alignment: .leading, spacing: 2) {
                Text(portal.name)
                    .font(.headline)
                    .lineLimit(1)
            }

            Spacer()

            // Constellation icons (grayscale in mono mode)
            if !portalConstellations.isEmpty {
                HStack(spacing: 4) {
                    ForEach(portalConstellations.prefix(3)) { constellation in
                        Image(systemName: constellation.icon)
                            .foregroundColor(shouldDesaturateContent ? Color.secondary : Color(hex: constellation.colorHex))
                            .font(.caption)
                    }
                    if portalConstellations.count > 3 {
                        Text("+\(portalConstellations.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Pin indicator (grayscale in mono mode)
            if portal.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(shouldDesaturateContent ? Color.secondary : Color.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Thumbnail

    @ViewBuilder
    private var thumbnailView: some View {
        // Determine the base glow color based on custom style settings
        let baseColor: Color = {
            if portal.useCustomStyle {
                return portal.displayColor
            } else if portal.displayThumbnail != nil {
                return Color.gray
            } else if portal.type != .web {
                return portal.displayColor
            } else {
                return portal.fallbackColor
            }
        }()

        // Apply color mode (constellation/default/frost)
        let color = effectiveColor(baseColor)

        ZStack {
            // Outer glow (intensity-affected, gradient for multi-constellation)
            if useGradient && gradientColors.count > 1 {
                // Multi-constellation gradient glow
                Circle()
                    .fill(
                        AngularGradient(
                            colors: gradientColors.map { $0.opacity(0.4 * colorOpacity) } + [gradientColors[0].opacity(0.4 * colorOpacity)],
                            center: .center
                        )
                    )
                    .frame(width: iconSize * 1.25, height: iconSize * 1.25)
                    .blur(radius: iconSize * 0.2)
            } else {
                // Single color glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.4 * colorOpacity),
                                color.opacity(0.15 * colorOpacity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: iconSize * 0.3,
                            endRadius: iconSize * 0.7
                        )
                    )
                    .frame(width: iconSize * 1.25, height: iconSize * 1.25)
            }

            // Main orb content
            ZStack {
                if portal.useCustomStyle && portal.keepFaviconWithCustomStyle,
                   let thumbnailData = portal.displayThumbnail,
                   let uiImage = UIImage(data: thumbnailData) {
                    // Custom style with kept favicon - use custom color glow but show favicon
                    Circle()
                        .fill(.ultraThinMaterial)

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding(5)
                        .saturation(shouldDesaturateContent ? 0 : 1)
                } else if portal.useCustomStyle {
                    // Custom style - colored orb with icon/initials (intensity-affected)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.5 * colorOpacity),
                                    color.opacity(0.7 * colorOpacity),
                                    color.opacity(0.85 * colorOpacity)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.25),
                                startRadius: 0,
                                endRadius: 20
                            )
                        )

                    // Show icon or initials based on toggle
                    if portal.useIconInsteadOfInitials {
                        Image(systemName: portal.displayIcon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                    } else {
                        Text(portal.displayInitials)
                            .font(.system(size: portal.displayInitials.count > 1 ? 12 : 16, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                    }
                } else if let thumbnailData = portal.displayThumbnail,
                   let uiImage = UIImage(data: thumbnailData) {
                    // Favicon with glass background
                    Circle()
                        .fill(.ultraThinMaterial)

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding(5)
                        .saturation(shouldDesaturateContent ? 0 : 1)
                } else if portal.type != .web {
                    // Non-web portals - colored orb with type icon (intensity-affected)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.5 * colorOpacity),
                                    color.opacity(0.7 * colorOpacity),
                                    color.opacity(0.85 * colorOpacity)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.25),
                                startRadius: 0,
                                endRadius: 20
                            )
                        )

                    Image(systemName: portal.type.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                } else {
                    // Web portals without favicon - colored orb with initial (intensity-affected)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.5 * colorOpacity),
                                    color.opacity(0.7 * colorOpacity),
                                    color.opacity(0.85 * colorOpacity)
                                ],
                                center: UnitPoint(x: 0.3, y: 0.25),
                                startRadius: 0,
                                endRadius: 20
                            )
                        )

                    Text(portal.avatarInitial)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                }

                // Glass specular highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            center: UnitPoint(x: 0.25, y: 0.2),
                            startRadius: 0,
                            endRadius: 14
                        )
                    )

                // Rim light
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .frame(width: iconSize, height: iconSize)
            .shadow(color: color.opacity(0.4 * colorOpacity), radius: iconSize * 0.15, y: iconSize * 0.075)

            // Source badge for non-web portals
            if portal.type.showSourceBadge {
                Circle()
                    .fill(.ultraThickMaterial)
                    .frame(width: iconSize * 0.4, height: iconSize * 0.4)
                    .overlay(
                        Image(systemName: portal.type.iconName)
                            .font(.system(size: iconSize * 0.22, weight: .bold))
                            .foregroundStyle(portal.displayColor)
                    )
                    .offset(x: iconSize * 0.4, y: iconSize * 0.4)
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
    @Environment(PortalManager.self) private var portalManager

    let initialURL: String
    let onCancel: () -> Void
    let onSubmit: (String) -> Void

    @State private var urlText: String
    @State private var expandedPack: UUID?

    init(initialURL: String, onCancel: @escaping () -> Void, onSubmit: @escaping (String) -> Void) {
        self.initialURL = initialURL
        self.onCancel = onCancel
        self.onSubmit = onSubmit
        _urlText = State(initialValue: initialURL)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        // URL Input Section
                        VStack(spacing: 8) {
                            TextField("Enter URL or site name...", text: $urlText)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.URL)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    if !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        onSubmit(urlText)
                                        dismiss()
                                    }
                                }

                            Text("Enter a URL like \"youtube.com\" or \"https://github.com\"")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)

                        Divider()
                            .padding(.horizontal)

                        // Quick Start Packs Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Start")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            ForEach(PortalPack.allPacks) { pack in
                                quickStartPackRow(pack, scrollProxy: proxy)
                                    .id(pack.id)
                            }
                        }
                    }
                    .padding(.vertical)
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

    @ViewBuilder
    private func quickStartPackRow(_ pack: PortalPack, scrollProxy: ScrollViewProxy) -> some View {
        let isExpanded = expandedPack == pack.id

        VStack(spacing: 0) {
            // Pack header - tap to expand/collapse
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded {
                        expandedPack = nil
                    } else {
                        expandedPack = pack.id
                        // Auto-scroll to show expanded content
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                scrollProxy.scrollTo(pack.id, anchor: .top)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    // Pack icon orb
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [packColor(for: pack.name).opacity(0.5), packColor(for: pack.name).opacity(0.8)],
                                    center: UnitPoint(x: 0.3, y: 0.3),
                                    startRadius: 0,
                                    endRadius: 14
                                )
                            )
                            .frame(width: 28, height: 28)

                        Image(systemName: pack.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Text(pack.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(pack.portals.count) portals")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            // Expanded portal list
            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(pack.portals) { template in
                        quickStartPortalButton(template)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    @ViewBuilder
    private func quickStartPortalButton(_ template: PortalTemplate) -> some View {
        let color = colorForURL(template.url)

        Button {
            // Add this portal directly
            let portal = Portal(name: template.name, url: template.url)
            portalManager.add(portal)
            Task {
                await portalManager.fetchFavicon(for: portal.id)
            }
            dismiss()
        } label: {
            HStack(spacing: 12) {
                // Glassy orb with favicon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.3),
                                    color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 18
                            )
                        )
                        .frame(width: 32, height: 32)

                    // Glass orb background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 26, height: 26)

                    // Favicon or fallback
                    AsyncImage(url: faviconURL(for: template.url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .clipShape(Circle())
                        case .failure, .empty:
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [color.opacity(0.6), color.opacity(0.85)],
                                            center: UnitPoint(x: 0.3, y: 0.25),
                                            startRadius: 0,
                                            endRadius: 9
                                        )
                                    )
                                    .frame(width: 18, height: 18)
                                Text(String(template.name.prefix(1)).uppercased())
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }

                    // Glass highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                center: UnitPoint(x: 0.25, y: 0.2),
                                startRadius: 0,
                                endRadius: 10
                            )
                        )
                        .frame(width: 26, height: 26)

                    // Rim light
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                        .frame(width: 26, height: 26)
                }
                .shadow(color: color.opacity(0.3), radius: 4, y: 2)

                Text(template.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
                    .font(.body)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func faviconURL(for urlString: String) -> URL? {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return nil
        }
        return URL(string: "https://icons.duckduckgo.com/ip3/\(host).ico")
    }

    private func colorForURL(_ urlString: String) -> Color {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return .blue
        }
        return Color.fromHost(host)
    }

    private func packColor(for packName: String) -> Color {
        switch packName {
        case "AI": return Color(red: 0.4, green: 0.6, blue: 1.0)  // Blue
        case "Pulse": return Color(red: 1.0, green: 0.4, blue: 0.6)  // Pink
        case "Launchpad": return Color(red: 1.0, green: 0.7, blue: 0.2)  // Orange
        case "AI Artists": return Color(red: 0.8, green: 0.4, blue: 0.9)  // Purple
        case "Indie": return Color(red: 0.95, green: 0.6, blue: 0.1)  // Gold/Amber
        case "Social": return Color(red: 0.3, green: 0.8, blue: 0.7)  // Teal
        case "Developer": return Color(red: 0.3, green: 0.7, blue: 0.4)  // Green
        case "Productivity": return Color(red: 0.9, green: 0.5, blue: 0.2)  // Deep Orange
        case "Creative": return Color(red: 0.9, green: 0.3, blue: 0.5)  // Magenta
        default: return Color.blue
        }
    }
}
