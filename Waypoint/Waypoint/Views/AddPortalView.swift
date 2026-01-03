//
//  AddPortalView.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import SwiftUI
import UIKit

struct AddPortalView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Environment(PortalManager.self) private var portalManager
    @Environment(ConstellationManager.self) private var constellationManager
    let editingPortal: Portal?
    let focusRequestPortalID: Binding<UUID?>?
    let dismissMicroActionsPortalID: Binding<UUID?>?

    @State private var name: String = ""
    @State private var url: String = ""
    @State private var isPinned: Bool = false

    // Custom styling state
    @State private var useCustomStyle: Bool = false
    @State private var customColorHex: String = "#3B82F6"  // Default blue
    @State private var customInitials: String = ""
    @State private var customIcon: String = ""
    @State private var useIconInsteadOfInitials: Bool = true  // Toggle: icon vs initials
    @State private var keepFaviconWithCustomStyle: Bool = false  // Keep favicon with custom glow
    @State private var customColor: Color = .blue  // For ColorPicker binding

    // Predefined colors for picker
    private let colorOptions: [(name: String, hex: String)] = [
        ("Blue", "#2196F3"),
        ("Indigo", "#3F51B5"),
        ("Cyan", "#00BCD4"),
        ("Teal", "#009688"),
        ("Green", "#4CAF50"),
        ("Yellow", "#FFCC00"),
        ("Orange", "#FF9800"),
        ("Red", "#F44336"),
        ("Black", "#1C1C1E"),
    ]

    // Available icons for custom selection
    private let iconOptions: [String] = [
        "globe", "doc.fill", "doc.text.fill", "note.text", "pencil.and.scribble",
        "cube.fill", "folder.fill", "icloud.fill", "externaldrive.fill.badge.icloud",
        "tablecells.fill", "doc.richtext.fill", "play.rectangle.fill", "app.fill",
        "link", "star.fill", "heart.fill", "bolt.fill", "flame.fill",
        "book.fill", "bookmark.fill", "tag.fill", "photo.fill", "video.fill",
        "music.note", "gamecontroller.fill", "briefcase.fill", "cart.fill",
        "creditcard.fill", "house.fill", "building.2.fill", "mappin.circle.fill"
    ]

    private var isEditing: Bool {
        editingPortal != nil
    }
    
    private var isValid: Bool {
        // For create mode, only URL is required (name will be auto-derived)
        // For edit mode, both are required
        if isEditing {
            return !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !url.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return !url.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Initialization
    
    init(
        editingPortal: Portal? = nil,
        focusRequestPortalID: Binding<UUID?>? = nil,
        dismissMicroActionsPortalID: Binding<UUID?>? = nil
    ) {
        self.editingPortal = editingPortal
        self.focusRequestPortalID = focusRequestPortalID
        self.dismissMicroActionsPortalID = dismissMicroActionsPortalID
        
        // Initialize state from editing portal if provided
        if let portal = editingPortal {
            _name = State(initialValue: portal.name)
            _url = State(initialValue: portal.url)
            _isPinned = State(initialValue: portal.isPinned)
            _useCustomStyle = State(initialValue: portal.useCustomStyle)
            _customColorHex = State(initialValue: portal.customColorHex ?? "#3B82F6")
            _customInitials = State(initialValue: portal.customInitials ?? "")
            _customIcon = State(initialValue: portal.customIcon ?? portal.type.iconName)
            _useIconInsteadOfInitials = State(initialValue: portal.useIconInsteadOfInitials)
            _keepFaviconWithCustomStyle = State(initialValue: portal.keepFaviconWithCustomStyle)
            _customColor = State(initialValue: Color(hex: portal.customColorHex ?? "#3B82F6"))
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle(isEditing ? "Edit Portal" : "Create Portal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button(isEditing ? "Save" : "Create") {
                            savePortal()
                        }
                        .disabled(!isValid)
                    }
                }
        }
    }

    /// Whether the current portal has a favicon
    private var hasFavicon: Bool {
        guard let portal = editingPortal else { return false }
        return portal.displayThumbnail != nil
    }

    private var formContent: some View {
        Form {
            // Compact hero preview for edit mode
            if isEditing {
                portalHeroPreview
                    .listRowBackground(Color.clear)
            }

            // When editing with favicon: Custom Style & Constellations first, then form fields
            if isEditing && hasFavicon {
                customAvatarSection

                // Constellation toggles right after custom style
                if let portal = editingPortal, !constellationManager.constellations.isEmpty {
                    Section("Constellations") {
                        constellationToggles(for: portal)
                    }
                }

                // Form fields at the bottom for favicon portals
                Section("Portal Details") {
                    TextField("Name", text: $name, prompt: Text("YouTube"))

                    HStack {
                        TextField("URL", text: $url, prompt: Text("youtube.com"))
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        Button {
                            pasteFromClipboard()
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(.bordered)
                    }

                    Toggle("Pin to Top", isOn: $isPinned)
                }
            } else if isEditing {
                // No favicon: Custom style first, then form fields, then constellations
                customAvatarSection

                Section {
                    TextField("Name", text: $name, prompt: Text("YouTube"))

                    HStack {
                        TextField("URL", text: $url, prompt: Text("youtube.com"))
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()

                        Button {
                            pasteFromClipboard()
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(.bordered)
                    }

                    Toggle("Pin to Top", isOn: $isPinned)
                }

                // Constellation toggles
                if let portal = editingPortal, !constellationManager.constellations.isEmpty {
                    Section("Constellations") {
                        constellationToggles(for: portal)
                    }
                }
            } else {
                // Create new portal mode - simplified, URL-only
                Section {
                    HStack {
                        TextField("URL or site name", text: $url, prompt: Text("youtube.com"))
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onSubmit {
                                if isValid {
                                    savePortal()
                                }
                            }
                            .onChange(of: url) { _, newValue in
                                // Auto-derive name from URL as user types
                                autoDeriveName(from: newValue)
                            }

                        Button {
                            pasteFromClipboard()
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(.bordered)
                    }

                    // Show derived name preview (non-editable in create mode)
                    if !name.isEmpty {
                        HStack {
                            Text("Name")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(name)
                                .foregroundStyle(.primary)
                        }
                        .font(.subheadline)
                    }
                }

                // Quick Start orbs - beautiful glass spheres
                quickStartOrbsSection
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Quick Start Orbs

    private var quickStartOrbsSection: some View {
        Section {
            VStack(spacing: 16) {
                Text("Quick Start")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    ForEach(quickStartOptions, id: \.name) { option in
                        quickStartOrb(option)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
    }

    private var quickStartOptions: [(name: String, url: String, color: Color)] {
        [
            ("YouTube", "https://www.youtube.com", Color(red: 1.0, green: 0.0, blue: 0.0)),
            ("X", "https://x.com", Color(red: 0.1, green: 0.1, blue: 0.1)),
            ("ChatGPT", "https://chatgpt.com", Color(red: 0.0, green: 0.65, blue: 0.55)),
            ("Claude", "https://claude.ai", Color(red: 0.85, green: 0.55, blue: 0.35)),
            ("Gmail", "https://mail.google.com", Color(red: 0.92, green: 0.26, blue: 0.21)),
            ("Notion", "https://notion.so", Color(red: 0.2, green: 0.2, blue: 0.2))
        ]
    }

    @ViewBuilder
    private func quickStartOrb(_ option: (name: String, url: String, color: Color)) -> some View {
        Button {
            // Create portal directly
            let portal = Portal(name: option.name, url: option.url)
            portalManager.add(portal)
            Task {
                await portalManager.fetchFavicon(for: portal.id)
            }
            dismiss()
        } label: {
            VStack(spacing: 6) {
                // Beautiful glass orb with favicon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    option.color.opacity(0.4),
                                    option.color.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 12,
                                endRadius: 28
                            )
                        )
                        .frame(width: 50, height: 50)

                    // Glass orb background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)

                    // Favicon or fallback initial
                    AsyncImage(url: faviconURL(for: option.url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                        case .failure, .empty:
                            // Fallback to colored orb with initial
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                option.color.opacity(0.6),
                                                option.color.opacity(0.85)
                                            ],
                                            center: UnitPoint(x: 0.3, y: 0.25),
                                            startRadius: 0,
                                            endRadius: 13
                                        )
                                    )
                                    .frame(width: 26, height: 26)

                                Text(String(option.name.prefix(1)).uppercased())
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: Color.black.opacity(0.3), radius: 1, y: 1)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }

                    // Top-left specular highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.25, y: 0.2),
                                startRadius: 0,
                                endRadius: 14
                            )
                        )
                        .frame(width: 40, height: 40)

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
                        .frame(width: 40, height: 40)
                }
                .shadow(color: option.color.opacity(0.4), radius: 6, y: 3)

                // Label
                Text(option.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
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

    // MARK: - Custom Avatar Section

    private var customAvatarSection: some View {
        Section {
            Toggle("Use Custom Style", isOn: $useCustomStyle)

            if useCustomStyle {
                // Color picker with ColorPicker + presets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Glow Color")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Custom ColorPicker as first option
                            customColorPickerOrb

                            // Preset colors
                            ForEach(colorOptions, id: \.hex) { option in
                                colorOrbButton(for: option.hex)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)

                // Keep Favicon toggle - only show if portal has a favicon
                if hasFavicon {
                    Toggle("Keep Favicon", isOn: $keepFaviconWithCustomStyle)
                        .padding(.vertical, 2)
                }

                // Only show icon/initials picker if not keeping favicon
                if !keepFaviconWithCustomStyle || !hasFavicon {
                    // Toggle between Icon and Initials
                    Picker("Display", selection: $useIconInsteadOfInitials) {
                        Text("Icon").tag(true)
                        Text("Initials").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)

                    if useIconInsteadOfInitials {
                        // Icon picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(iconOptions, id: \.self) { icon in
                                        iconButton(for: icon)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        // Initials field
                        HStack {
                            Text("Initials")
                            Spacer()
                            TextField("1-3 chars", text: $customInitials)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: customInitials) { _, newValue in
                                    // Limit to 3 characters
                                    if newValue.count > 3 {
                                        customInitials = String(newValue.prefix(3))
                                    }
                                }
                        }
                    }
                }
            }
        } header: {
            Text(hasFavicon ? "Custom Avatar" : "Customize Appearance")
        } footer: {
            if useCustomStyle && hasFavicon && keepFaviconWithCustomStyle {
                Text("Custom glow color will be applied around the favicon.")
            } else if !hasFavicon {
                Text("No favicon found. Customize how this portal appears.")
            }
        }
    }

    // Custom ColorPicker styled as orb
    private var customColorPickerOrb: some View {
        ZStack {
            // Rainbow gradient orb
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                        center: .center
                    )
                )
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 0,
                                endRadius: 12
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.purple.opacity(0.3), radius: 3, y: 2)

            // Hidden ColorPicker overlay
            ColorPicker("", selection: $customColor, supportsOpacity: false)
                .labelsHidden()
                .opacity(0.02)  // Nearly invisible but tappable
                .onChange(of: customColor) { _, newColor in
                    if let hex = newColor.toHex() {
                        customColorHex = hex
                    }
                }
        }
        .frame(width: 44, height: 44)
    }

    private func iconButton(for icon: String) -> some View {
        let isSelected = customIcon == icon
        let color = Color(hex: customColorHex)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                customIcon = icon
            }
        } label: {
            ZStack {
                // Glow behind selected
                if isSelected {
                    Circle()
                        .fill(color.opacity(0.4))
                        .frame(width: 40, height: 40)
                        .blur(radius: 4)
                }

                // Main orb with gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(isSelected ? 0.5 : 0.2),
                                color.opacity(isSelected ? 0.8 : 0.4)
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 16
                        )
                    )
                    .frame(width: 32, height: 32)

                // Glass highlight
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.4), Color.clear],
                            center: UnitPoint(x: 0.35, y: 0.25),
                            startRadius: 0,
                            endRadius: 10
                        )
                    )
                    .frame(width: 32, height: 32)

                // Icon
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)

                // Selection ring
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }
            }
            .frame(width: 40, height: 40)
            .shadow(color: color.opacity(isSelected ? 0.4 : 0.1), radius: isSelected ? 4 : 2, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func colorOrbButton(for colorHex: String) -> some View {
        let color = Color(hex: colorHex)
        let isSelected = customColorHex == colorHex

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                customColorHex = colorHex
            }
        } label: {
            ZStack {
                // Glow behind selected
                if isSelected {
                    Circle()
                        .fill(color.opacity(0.4))
                        .frame(width: 44, height: 44)
                        .blur(radius: 5)
                }

                // Main color orb with gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.6),
                                color.opacity(0.85),
                                color
                            ],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 18
                        )
                    )
                    .frame(width: 36, height: 36)

                // Top highlight for glass effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.5), Color.clear],
                            center: UnitPoint(x: 0.35, y: 0.25),
                            startRadius: 0,
                            endRadius: 10
                        )
                    )
                    .frame(width: 36, height: 36)

                // Selection ring
                Circle()
                    .stroke(
                        isSelected ? Color.white : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2.5 : 1
                    )
                    .frame(width: 36, height: 36)
            }
            .frame(width: 44, height: 44)
            .shadow(color: color.opacity(isSelected ? 0.5 : 0.2), radius: isSelected ? 5 : 2, y: 2)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func constellationToggles(for portal: Portal) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(constellationManager.constellations) { constellation in
                    let isAssigned = constellation.portalIDs.contains(portal.id)
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            if isAssigned {
                                constellationManager.removePortal(portal.id, from: constellation)
                            } else {
                                constellationManager.addPortal(portal.id, to: constellation)
                            }
                        }
                    } label: {
                        ZStack {
                            // Use constellation orb view
                            ConstellationOrbView(
                                constellation: constellation,
                                isSelected: isAssigned,
                                size: 40,
                                showLabel: true
                            )

                            // Checkmark overlay when assigned
                            if isAssigned {
                                Circle()
                                    .fill(Color.green.opacity(0.9))
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                    .offset(x: 18, y: -20)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Hero Preview (Edit Mode)

    private var portalHeroPreview: some View {
        let orbSize: CGFloat = 72
        let color = heroDisplayColor

        // Show favicon if: not custom style, OR custom style with keepFavicon enabled
        let showFavicon = !useCustomStyle || (useCustomStyle && keepFaviconWithCustomStyle)

        return VStack(spacing: 12) {
            // Beautiful glass sphere orb (matching EditConstellationView style)
            ZStack {
                if showFavicon,
                   let portal = editingPortal,
                   let thumbnailData = portal.displayThumbnail,
                   let uiImage = UIImage(data: thumbnailData) {
                    // Show actual favicon in glass orb (with custom glow color if custom style enabled)
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
                                    startRadius: orbSize * 0.3,
                                    endRadius: orbSize * 0.9
                                )
                            )
                            .frame(width: orbSize * 1.4, height: orbSize * 1.4)

                        // Glass background
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: orbSize, height: orbSize)

                        // Favicon
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: orbSize - 16, height: orbSize - 16)

                        // Glass highlight
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.4), Color.clear],
                                    center: UnitPoint(x: 0.3, y: 0.25),
                                    startRadius: 0,
                                    endRadius: orbSize * 0.3
                                )
                            )
                            .frame(width: orbSize, height: orbSize)

                        // Rim light
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05),
                                        Color.white.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: orbSize, height: orbSize)
                    }
                } else {
                    // Custom style orb - beautiful glass sphere
                    ZStack {
                        // Outer glow - ambient light
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        color.opacity(0.4),
                                        color.opacity(0.2),
                                        color.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: orbSize * 0.3,
                                    endRadius: orbSize * 1.0
                                )
                            )
                            .frame(width: orbSize * 1.5, height: orbSize * 1.5)

                        // Main sphere body - deeper 3D gradient
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        color.opacity(0.25),
                                        color.opacity(0.45),
                                        color.opacity(0.65),
                                        color.opacity(0.8)
                                    ],
                                    center: UnitPoint(x: 0.3, y: 0.25),
                                    startRadius: orbSize * 0.05,
                                    endRadius: orbSize * 0.55
                                )
                            )
                            .frame(width: orbSize, height: orbSize)

                        // Top-left specular highlight
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.65),
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.0)
                                    ],
                                    center: UnitPoint(x: 0.25, y: 0.2),
                                    startRadius: 0,
                                    endRadius: orbSize * 0.35
                                )
                            )
                            .frame(width: orbSize, height: orbSize)

                        // Rim light
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: orbSize, height: orbSize)

                        // Bottom reflection
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.clear
                                    ],
                                    center: UnitPoint(x: 0.6, y: 0.85),
                                    startRadius: 0,
                                    endRadius: orbSize * 0.2
                                )
                            )
                            .frame(width: orbSize, height: orbSize)

                        // Icon or Initials with enhanced visibility
                        if useIconInsteadOfInitials {
                            Image(systemName: heroDisplayIcon)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(color: color.opacity(0.9), radius: 4)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                        } else {
                            Text(heroDisplayInitials)
                                .font(.system(size: heroDisplayInitials.count > 1 ? 24 : 30, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: color.opacity(0.9), radius: 4)
                                .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                        }
                    }
                }
            }
            .frame(width: orbSize * 1.5, height: orbSize * 1.5)
            .shadow(color: color.opacity(0.35), radius: 10, y: 3)

            // Name under orb
            Text(name.isEmpty ? "Portal Name" : name)
                .font(.headline)
                .foregroundStyle(name.isEmpty ? .secondary : .primary)

            Text(url.isEmpty ? "portal-url.com" : cleanURL(url))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    /// Computed fallback color based on current URL
    private var currentFallbackColor: Color {
        guard !url.isEmpty,
              let urlObj = URL(string: url) ?? URL(string: "https://" + url),
              let host = urlObj.host else {
            return .blue
        }
        return Color.fromHost(host)
    }

    /// Display color for hero - uses custom if enabled, otherwise auto
    private var heroDisplayColor: Color {
        if useCustomStyle {
            return Color(hex: customColorHex)
        }
        return currentFallbackColor
    }

    /// Display initials for hero - uses custom if enabled, otherwise first letter of name
    private var heroDisplayInitials: String {
        if useCustomStyle && !customInitials.isEmpty {
            return String(customInitials.prefix(3)).uppercased()
        }
        return name.isEmpty ? "?" : String(name.prefix(1)).uppercased()
    }

    /// Display icon for hero - uses custom if set, otherwise type default
    private var heroDisplayIcon: String {
        if useCustomStyle && !customIcon.isEmpty {
            return customIcon
        }
        // Fall back to portal type icon
        if let portal = editingPortal {
            return portal.type.iconName
        }
        return "globe"
    }

    // MARK: - Preview

    private var portalPreview: some View {
        HStack(spacing: 12) {
            // Vibrant colored thumbnail preview
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                currentFallbackColor.opacity(0.95),
                                currentFallbackColor.opacity(0.7)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: currentFallbackColor.opacity(0.4), radius: 4, y: 2)

                if !name.isEmpty {
                    Text(name.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "link.circle")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "Portal Name" : name)
                    .font(.headline)
                    .foregroundStyle(name.isEmpty ? .secondary : .primary)

                Text(url.isEmpty ? "portal-url.com" : cleanURL(url))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isPinned {
                Image(systemName: "pin.fill")
                    .foregroundStyle(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Actions

    private func pasteFromClipboard() {
        #if os(visionOS) || os(iOS)
        if let clipboardString = UIPasteboard.general.string {
            let trimmed = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
            url = trimmed
            // Name will be auto-derived via onChange
        }
        #endif
    }

    /// Auto-derives portal name from URL input
    private func autoDeriveName(from input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            name = ""
            return
        }

        // Build a URL from input (add https:// if needed)
        var urlString = trimmed
        if !urlString.contains("://") {
            if urlString.contains(".") {
                urlString = "https://" + urlString
            } else {
                // Bare name like "youtube" → "https://youtube.com"
                urlString = "https://\(urlString).com"
            }
        }

        if let urlObj = URL(string: urlString) {
            name = DropService.extractSmartName(from: urlObj)
        }
    }

    private func savePortal() {
        var cleanedName = name.trimmingCharacters(in: .whitespaces)
        var cleanedURL = url.trimmingCharacters(in: .whitespaces)

        // Auto-add https:// if missing and it looks like a domain
        if !cleanedURL.contains("://") {
            // Check if it looks like a domain (contains a dot and no spaces)
            if cleanedURL.contains(".") && !cleanedURL.contains(" ") {
                cleanedURL = "https://" + cleanedURL
                print("✨ Auto-added https:// to URL: \(cleanedURL)")
            } else if !cleanedURL.contains(".") && !cleanedURL.contains(" ") {
                // Bare name like "youtube" → "https://www.youtube.com"
                cleanedURL = "https://www.\(cleanedURL).com"
                print("✨ Auto-expanded to full URL: \(cleanedURL)")
            }
        }

        // Auto-derive name if empty (fallback for create mode)
        if cleanedName.isEmpty, let urlObj = URL(string: cleanedURL) {
            cleanedName = DropService.extractSmartName(from: urlObj)
            print("✨ Auto-derived name: \(cleanedName)")
        }
        
        // Auto-add www for common sites that need it
        if cleanedURL.hasPrefix("https://") || cleanedURL.hasPrefix("http://") {
            let commonSitesNeedingWWW = [
                "youtube.com": "www.youtube.com",
                "instagram.com": "www.instagram.com",
                "reddit.com": "www.reddit.com",
                "wikipedia.org": "www.wikipedia.org"
            ]
            
            for (bare, full) in commonSitesNeedingWWW {
                if cleanedURL.contains("://\(bare)") {
                    cleanedURL = cleanedURL.replacingOccurrences(of: "://\(bare)", with: "://\(full)")
                    print("✨ Auto-added www: \(cleanedURL)")
                    break
                }
            }
        }
        
        if let editingPortal = editingPortal {
            // Update existing portal
            var updatedPortal = editingPortal
            updatedPortal.name = cleanedName
            updatedPortal.url = cleanedURL
            updatedPortal.isPinned = isPinned

            // Update custom styling
            updatedPortal.useCustomStyle = useCustomStyle
            updatedPortal.customColorHex = useCustomStyle ? customColorHex : nil
            updatedPortal.customInitials = useCustomStyle && !customInitials.isEmpty ? customInitials : nil
            updatedPortal.customIcon = useCustomStyle && !customIcon.isEmpty ? customIcon : nil
            updatedPortal.useIconInsteadOfInitials = useIconInsteadOfInitials
            updatedPortal.keepFaviconWithCustomStyle = keepFaviconWithCustomStyle

            portalManager.update(updatedPortal)
            dismissMicroActionsPortalID?.wrappedValue = updatedPortal.id
            print("✏️ Updated portal: \(cleanedName)")
        } else {
            if let existingPortal = portalManager.portals.first(where: { URLNormalizer.matches($0.url, cleanedURL) }) {
                focusRequestPortalID?.wrappedValue = existingPortal.id
                print("🔁 Portal already exists for this URL")

                // Trigger favicon fetch if existing portal doesn't have one
                if existingPortal.thumbnailData == nil {
                    Task {
                        await portalManager.fetchFavicon(for: existingPortal.id)
                    }
                }

                dismiss()
                return
            }

            // Create new portal
            let newPortal = Portal(
                name: cleanedName,
                url: cleanedURL,
                isPinned: isPinned
            )
            
            portalManager.add(newPortal)
            focusRequestPortalID?.wrappedValue = newPortal.id
            print("➕ Created portal: \(cleanedName)")
        }
        
        dismiss()
    }
    
    // MARK: - Utilities
    
    private func cleanURL(_ url: String) -> String {
        var cleaned = url
        
        // Remove common prefixes for display
        if cleaned.hasPrefix("https://") {
            cleaned = String(cleaned.dropFirst(8))
        } else if cleaned.hasPrefix("http://") {
            cleaned = String(cleaned.dropFirst(7))
        }
        
        // Remove trailing slash
        if cleaned.hasSuffix("/") {
            cleaned = String(cleaned.dropLast())
        }
        
        return cleaned
    }

}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String? {
        #if os(visionOS) || os(iOS)
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
        #endif
    }
}

// MARK: - Preview

#Preview("Create") {
    AddPortalView()
        .environment(PortalManager())
        .environment(ConstellationManager())
}

#Preview("Edit") {
    AddPortalView(editingPortal: Portal.sample)
        .environment(PortalManager())
        .environment(ConstellationManager())
}
