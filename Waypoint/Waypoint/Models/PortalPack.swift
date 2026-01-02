//
//  PortalPack.swift
//  Waypoint
//
//  Created on December 28, 2024.
//

import Foundation

// MARK: - Portal Pack

struct PortalPack: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let portals: [PortalTemplate]
}

// MARK: - Portal Template

struct PortalTemplate: Identifiable {
    let id = UUID()
    let name: String
    let url: String
}

// MARK: - Available Packs

extension PortalPack {
    
    // MARK: - All Packs
    
    static let allPacks: [PortalPack] = [
        aiPack,
        aiArtistsPack,
        indiePack,
        socialPack,
        developerPack,
        productivityPack,
        creativePack
    ]
    
    // MARK: - First-Time Packs
    
    static let firstTimePacks: [PortalPack] = [
        aiPack,
        pulsePack,
        launchpadPack
    ]
    
    // MARK: - Individual Packs
    
    static let aiPack = PortalPack(
        name: "AI",
        icon: "cpu.fill",
        portals: [
            PortalTemplate(name: "Claude", url: "https://claude.ai"),
            PortalTemplate(name: "ChatGPT", url: "https://chatgpt.com"),
            PortalTemplate(name: "Perplexity", url: "https://perplexity.ai"),
            PortalTemplate(name: "Gemini", url: "https://gemini.google.com"),
            PortalTemplate(name: "Grok", url: "https://grok.com")
        ]
    )

    static let pulsePack = PortalPack(
        name: "Pulse",
        icon: "sparkles",
        portals: [
            PortalTemplate(name: "YouTube", url: "https://www.youtube.com"),
            PortalTemplate(name: "X", url: "https://x.com"),
            PortalTemplate(name: "Instagram", url: "https://www.instagram.com"),
            PortalTemplate(name: "Discord", url: "https://discord.com"),
            PortalTemplate(name: "TikTok", url: "https://www.tiktok.com")
        ]
    )

    static let launchpadPack = PortalPack(
        name: "Launchpad",
        icon: "bolt.fill",
        portals: [
            PortalTemplate(name: "Gmail", url: "https://mail.google.com"),
            PortalTemplate(name: "Calendar", url: "https://calendar.google.com"),
            PortalTemplate(name: "Drive", url: "https://drive.google.com"),
            PortalTemplate(name: "Notion", url: "https://notion.so"),
            PortalTemplate(name: "Figma", url: "https://figma.com")
        ]
    )

    static let aiArtistsPack = PortalPack(
        name: "AI Artists",
        icon: "paintbrush.fill",
        portals: [
            PortalTemplate(name: "Midjourney", url: "https://www.midjourney.com"),
            PortalTemplate(name: "DALL-E", url: "https://openai.com/dall-e"),
            PortalTemplate(name: "Stable Diffusion", url: "https://stability.ai"),
            PortalTemplate(name: "Leonardo AI", url: "https://leonardo.ai"),
            PortalTemplate(name: "Runway", url: "https://runwayml.com"),
            PortalTemplate(name: "Higgsfield", url: "https://higgsfield.ai"),
            PortalTemplate(name: "Kling", url: "https://klingai.com")
        ]
    )

    static let indiePack = PortalPack(
        name: "Indie",
        icon: "sparkle.magnifyingglass",
        portals: [
            PortalTemplate(name: "Vibe Code", url: "https://vibe.dev"),
            PortalTemplate(name: "Thumio", url: "https://thumio.com"),
            PortalTemplate(name: "Photo AI", url: "https://photoai.com"),
            PortalTemplate(name: "Interior AI", url: "https://interiorai.com"),
            PortalTemplate(name: "Nomad List", url: "https://nomadlist.com"),
            PortalTemplate(name: "Remote OK", url: "https://remoteok.com"),
            PortalTemplate(name: "Product Hunt", url: "https://www.producthunt.com"),
            PortalTemplate(name: "Indie Hackers", url: "https://www.indiehackers.com"),
            PortalTemplate(name: "Gumroad", url: "https://gumroad.com")
        ]
    )

    static let socialPack = PortalPack(
        name: "Social",
        icon: "bubble.left.and.bubble.right.fill",
        portals: [
            PortalTemplate(name: "X", url: "https://x.com"),
            PortalTemplate(name: "Grok (X)", url: "https://x.com/i/grok"),
            PortalTemplate(name: "Discord", url: "discord://"),
            PortalTemplate(name: "Instagram", url: "https://www.instagram.com"),
            PortalTemplate(name: "TikTok", url: "https://www.tiktok.com"),
            PortalTemplate(name: "Threads", url: "https://www.threads.net")
        ]
    )

    static let developerPack = PortalPack(
        name: "Developer",
        icon: "chevron.left.forwardslash.chevron.right",
        portals: [
            PortalTemplate(name: "GitHub", url: "https://github.com"),
            PortalTemplate(name: "GitHub App", url: "github://"),
            PortalTemplate(name: "Stack Overflow", url: "https://stackoverflow.com"),
            PortalTemplate(name: "shadcn/ui", url: "https://ui.shadcn.com"),
            PortalTemplate(name: "Supabase", url: "https://supabase.com"),
            PortalTemplate(name: "Replit", url: "https://replit.com"),
            PortalTemplate(name: "VS Code Web", url: "https://vscode.dev"),
            PortalTemplate(name: "VS Code App", url: "vscode://"),
            PortalTemplate(name: "Vercel", url: "https://vercel.com")
        ]
    )

    static let productivityPack = PortalPack(
        name: "Productivity",
        icon: "square.grid.2x2.fill",
        portals: [
            PortalTemplate(name: "Gmail", url: "https://mail.google.com"),
            PortalTemplate(name: "Calendar", url: "https://calendar.google.com"),
            PortalTemplate(name: "Drive", url: "https://drive.google.com"),
            PortalTemplate(name: "Notion", url: "https://notion.so"),
            PortalTemplate(name: "Notion App", url: "notion://"),
            PortalTemplate(name: "Slack Web", url: "https://slack.com"),
            PortalTemplate(name: "Slack App", url: "slack://open")
        ]
    )

    static let creativePack = PortalPack(
        name: "Creative",
        icon: "wand.and.stars",
        portals: [
            PortalTemplate(name: "Figma Web", url: "https://figma.com"),
            PortalTemplate(name: "Figma App", url: "figma://"),
            PortalTemplate(name: "Canva", url: "https://canva.com"),
            PortalTemplate(name: "Adobe", url: "https://adobe.com"),
            PortalTemplate(name: "Dribbble", url: "https://dribbble.com"),
            PortalTemplate(name: "Behance", url: "https://behance.net")
        ]
    )
}
