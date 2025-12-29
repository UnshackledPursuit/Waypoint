//
//  PortalListView.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI

struct PortalListView: View {
    
    // MARK: - Properties
    
    @Environment(PortalManager.self) private var portalManager
    @State private var showAddPortal = false
    @State private var portalToEdit: Portal?
    @State private var showQuickStart = false
    
    // Sorting and filtering
    @State private var sortOrder: SortOrder = .dateAdded
    @State private var filterOption: FilterOption = .all
    
    enum SortOrder: String, CaseIterable {
        case dateAdded = "Date Added"
        case recent = "Recently Used"
        case name = "Name"
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case pinned = "Pinned"
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if portalManager.portals.isEmpty {
                    emptyStateView
                } else {
                    portalListView
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddPortal = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                // Consolidated View Options menu (Sort + Filter)
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        // Filter section
                        Section {
                            Picker("Show", selection: $filterOption) {
                                ForEach(FilterOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        }
                        
                        // Sort section
                        Section {
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
        }
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
        }
    }
    
    // MARK: - Filtered & Sorted Portals
    
    private var filteredAndSortedPortals: [Portal] {
        // First filter
        var filtered: [Portal]
        switch filterOption {
        case .all:
            filtered = portalManager.portals
        case .favorites:
            filtered = portalManager.favoritePortals
        case .pinned:
            filtered = portalManager.pinnedPortals
        }
        
        // Then sort
        return filtered.sorted { portal1, portal2 in
            // Pinned always comes first regardless of sort
            if portal1.isPinned != portal2.isPinned {
                return portal1.isPinned
            }
            
            // Then apply selected sort
            switch sortOrder {
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
        
        Button {
            portalManager.togglePin(portal)
        } label: {
            Label(
                portal.isPinned ? "Unpin" : "Pin to Top",
                systemImage: portal.isPinned ? "mappin.slash.circle" : "mappin.circle.fill"
            )
        }
        
        Button {
            portalManager.toggleFavorite(portal)
        } label: {
            Label(
                portal.isFavorite ? "Unfavorite" : "Favorite",
                systemImage: portal.isFavorite ? "star.slash.circle" : "star.circle.fill"
            )
        }
        
        Divider()
        
        Button(role: .destructive) {
            portalManager.delete(portal)
        } label: {
            Label("Delete", systemImage: "trash")
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
            
            // Pin indicator
            if portal.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
            
            // Favorite indicator
            if portal.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
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
