# Waypoint - Ruthless MVP Roadmap

**Created:** December 27, 2024  
**Philosophy:** 2 seconds to anywhere. Everything else is secondary.  
**Goal:** Ship a working app that solves a real problem, not a feature-complete masterpiece.

---

## Core Truth

**If it doesn't help you get anywhere in 2 seconds, it doesn't belong in the MVP.**

---

## Ruthless MVP Focus

### Phase 1-3: Just Make It Work

**Goal:** Functional app that solves the core problem

1. ✅ **Portals** (add, edit, delete, open)
2. ✅ **Share Extension** (save from anywhere)
3. ✅ **Constellations** (batch launch)

**Stop here and ship if it works well.**

**Success Criteria:**
- Can save any URL from any app
- Can organize portals into constellations
- Can launch entire workflow with one click
- Data persists reliably
- No critical bugs

**Time Estimate:** 2-3 hours of focused building

---

### Phase 4-5: Make It Effortless

**Goal:** Eliminate friction, add intelligence

4. ✅ **Drag & drop** (natural interaction)
5. ✅ **Auto-fill names/favicons** (zero manual work)

**This is 90% of the value.**

**Success Criteria:**
- Dragging URL/file creates portal automatically
- Names auto-extract from URLs
- Favicons auto-fetch (async, non-blocking)
- User does minimal manual work

**Time Estimate:** 1.5-2 hours

---

### Phase 6: Extended Access

**Goal:** Launch without opening app

6. ✅ **Widgets** (home screen quick launch)

**Nice to have, not critical.**

**Success Criteria:**
- Small widget: Launch single portal
- Medium widget: Launch constellation
- Tapping widget works reliably

**Time Estimate:** 1 hour

---

### Phase 7: Delight

**Goal:** Make it feel native and wonderful

7. 🎨 **Polish** (animations, gestures, beauty)

**Only if you have time and energy.**

**Success Criteria:**
- Smooth animations
- Hand gesture support (optional)
- Beautiful visual design
- Delightful to use

**Time Estimate:** Flexible (1-4 hours depending on scope)

---

## What Makes This Insanely Useful

### Must Have ⭐⭐⭐

**These three things MUST work perfectly:**

1. **Share Extension works 100% of the time**
   - No bugs
   - No freezes
   - No weird blank windows
   - Every share saves the portal

2. **Opens URLs instantly**
   - No lag
   - No loading screens
   - Click → Opens in <1 second
   - Works for all URL types (web, file, iCloud)

3. **Persists data reliably**
   - Never lose portals
   - Survives app restart
   - Survives device restart
   - Data integrity guaranteed

**If these three work perfectly, you have a useful app.**

---

### Should Have ⭐⭐

**These make it effortless, not just functional:**

4. **Smart auto-fill**
   - Names auto-extract from URLs
   - Favicons auto-fetch
   - User types nothing (just confirms)

5. **Constellations**
   - Group related portals
   - Launch entire workflow at once
   - Organize by context (morning, work, research)

6. **Drag & drop**
   - Drag file → Creates portal
   - Drag link → Creates portal
   - Natural visionOS interaction

**These separate "useful" from "indispensable".**

---

### Nice to Have ⭐

**These are polish, not core functionality:**

7. **Widgets** (launch without opening app)
8. **Gestures** (pinch to summon Waypoint)
9. **Spatial anchors** (constellation at your desk)
10. **Siri** ("Open my morning constellation")

**Ship without these. Add later if users want them.**

---

## The "Everyone Else" Validation

### Universal Problem

Everyone with Vision Pro has the same issue:
- Tons of apps, documents, websites, boards
- No quick way to access them spatially
- Safari bookmarks are flat and boring
- Files app is clunky for web links
- No way to batch-launch workflows

### Your Solution

- Works with EVERYTHING (not just Freeform)
- Spatial organization (constellations)
- Instant access (2 seconds)
- Share from anywhere (universal)
- Batch launching (workflows)

### Who Needs This

**Knowledge Workers:**
- Launch research constellation (10 tabs + 3 PDFs + Freeform board)
- Client work constellation (email + docs + calendar)
- Daily standup constellation (Slack + Jira + team docs)

**Creatives:**
- Design project constellation (Figma + references + mood boards)
- Writing constellation (notes + research + drafts)
- 3D work constellation (USDZ files + tutorials + forums)

**Students:**
- Course constellation (lectures + textbook + notes + homework)
- Study group constellation (shared docs + meeting link + calendar)
- Research constellation (papers + citations + writing doc)

**Developers:**
- Project constellation (GitHub + docs + Stack Overflow + tests)
- Learning constellation (tutorial + practice files + notes)
- Debug constellation (logs + documentation + related issues)

**Everyone:**
- Morning routine (email + calendar + news + todos)
- Evening wind-down (reading + podcasts + relaxation)
- Weekend projects (hobby links + tutorials + supplies)

**If it solves YOUR problem, it solves everyone's problem.**

---

## Simplified Roadmap

### Week 1-2: Build MVP

**Focus:** Phases 1-3 only

**Tasks:**
- [ ] Create new Xcode project
- [ ] Build Portal data model + manager
- [ ] Build basic list view
- [ ] Build add/edit portal view
- [ ] Implement Share Extension
- [ ] Build Constellation grouping
- [ ] Test with real usage (your actual workflows)

**Deliverable:** Working app you use daily

**Success Metric:** "I saved 10 minutes today using Waypoint"

---

### Week 3: Polish Core Features

**Focus:** Make Phases 1-3 bulletproof

**Tasks:**
- [ ] Fix all bugs discovered in Week 1-2
- [ ] Smooth rough edges in UX
- [ ] Ensure data persistence is rock-solid
- [ ] Test Share Extension from 10+ apps
- [ ] Verify all URL types open correctly
- [ ] Test constellation launching (5+ portals)

**Deliverable:** Reliable, bug-free core app

**Success Metric:** "No crashes, no data loss, no weird behavior"

---

### Week 4: TestFlight Beta

**Focus:** Real-world validation

**Tasks:**
- [ ] Invite 10-20 beta testers
- [ ] Gather feedback on core functionality
- [ ] Watch for common pain points
- [ ] Iterate on critical issues only
- [ ] Prepare App Store materials (screenshots, description)

**Deliverable:** Validated product with real users

**Success Metric:** "5+ testers say 'I need this app'"

---

### Week 5-6: App Store Launch

**Focus:** Clean launch with core features

**Tasks:**
- [ ] Final bug fixes from beta
- [ ] Polish UI/UX
- [ ] Write App Store description (focus on "2 seconds to anywhere")
- [ ] Create 5 screenshots showing core value
- [ ] Submit to App Store
- [ ] Market as simple, focused solution

**Deliverable:** Live app on App Store

**Success Metric:** "First 100 downloads, positive reviews"

---

## Post-Launch Iteration

### v1.1 (If People Love It)

**Month 2:**

**Add based on feedback:**
- Drag & drop (if users request it)
- Smart auto-fill (if manual work is pain point)
- Improved Share Extension (if reliability issues)

**Don't add:** Features users didn't ask for

---

### v1.2 (If Momentum Builds)

**Month 3:**

**Enhance experience:**
- Widgets (if users want home screen access)
- Basic gestures (if natural interaction is valued)
- Polish animations (if users care about beauty)

**Don't add:** Complex features that complicate core promise

---

### v2.0 (If It Takes Off)

**Month 4-6:**

**Go advanced (only if justified by usage):**
- Spatial anchors (room-based constellations)
- Siri support ("Open my morning constellation")
- Universal Links (constellation sharing)
- iCloud sync (multi-device)
- Pro features? (team collaboration, advanced organization)

**Don't add:** Features for the sake of features

---

## Launch Strategy

### Positioning

**Tagline:** "Navigate your digital universe"

**Pitch:** "2 seconds to anywhere. Save any link from any app. Group them into constellations. Launch entire workflows with one click."

**Target Audience:** Vision Pro power users who juggle multiple apps/docs/websites daily

### App Store Presence

**Name:** Waypoint

**Subtitle:** Universal Link Manager for Vision Pro

**Description Focus:**
1. Problem: "Managing dozens of links across apps is chaos"
2. Solution: "Waypoint organizes everything spatially"
3. Benefit: "2 seconds to anywhere in your digital universe"
4. Features: Portals, Constellations, Share Extension

**Screenshots:**
1. Hero shot (beautiful spatial view with portals)
2. Share Extension in action
3. Constellation launching
4. Use case example (morning routine)
5. Grid/list views

### Marketing Channels

**Week 1:**
- Post on r/VisionPro
- Share on X (formerly Twitter)
- Post on Hacker News (Show HN)
- Vision Pro Discord communities

**Week 2-4:**
- Direct outreach to Vision Pro YouTubers/reviewers
- Product Hunt launch
- Vision Pro Facebook groups
- LinkedIn (target knowledge workers)

**Ongoing:**
- User testimonials
- Use case highlights
- Constellation templates (share popular setups)

---

## Success Metrics

### MVP Success (Week 1-4)

**Qualitative:**
- [ ] You use it daily
- [ ] Saves you 5+ minutes per day
- [ ] Solves your "2 seconds to anywhere" problem
- [ ] Friends/colleagues say "I want this"

**Quantitative:**
- [ ] Zero critical bugs
- [ ] Zero data loss incidents
- [ ] Share Extension works 95%+ of the time
- [ ] Average launch time <1 second

---

### Launch Success (Week 5-8)

**Qualitative:**
- [ ] Users say "I need this"
- [ ] Positive App Store reviews (4+ stars)
- [ ] Users share use cases organically
- [ ] Feature requests indicate engagement

**Quantitative:**
- [ ] 100+ downloads in first month
- [ ] 50%+ retention after 1 week
- [ ] 10+ App Store reviews
- [ ] <5% crash rate

---

### Growth Success (Month 2-3)

**Qualitative:**
- [ ] Users create their own constellations
- [ ] Word-of-mouth referrals
- [ ] Users post about it on social media
- [ ] Requested in "must-have apps" lists

**Quantitative:**
- [ ] 500+ downloads
- [ ] 60%+ retention after 1 month
- [ ] 4+ star average rating
- [ ] 20+ reviews

---

## What NOT to Do

### Don't Over-Engineer

**Bad:**
- "Let me add 3D immersive constellation view before launch"
- "I need perfect animations for every interaction"
- "Let me implement AI-suggested constellations"

**Good:**
- "Does it save links reliably?"
- "Can I launch workflows in 2 seconds?"
- "Does Share Extension work?"

### Don't Feature Creep

**Bad:**
- "What if users could share constellations with teams?"
- "Should I add a constellation marketplace?"
- "Maybe users want to schedule portal launches?"

**Good:**
- "Did any user ask for this?"
- "Does it serve the core promise?"
- "Can it wait for v2.0?"

### Don't Obsess Over Perfection

**Bad:**
- "The favicon sometimes takes 3 seconds to load, I can't ship"
- "The animation curve isn't quite right"
- "I need to support 50 URL edge cases"

**Good:**
- "Does it work for 90% of use cases?"
- "Is it better than the current solution (Safari bookmarks)?"
- "Can I ship and iterate?"

### Don't Ignore User Feedback

**Bad:**
- "I know better than users"
- "My vision is more important than their needs"
- "They'll understand once they use it more"

**Good:**
- "What are users actually doing with the app?"
- "What pain points are they reporting?"
- "What features do they keep requesting?"

---

## Decision Framework

When considering any feature/change, ask:

### 1. Does it serve "2 seconds to anywhere"?
- **Yes:** Consider it
- **No:** Skip it

### 2. Did a user ask for it?
- **Yes:** Probably valuable
- **No:** Probably vanity

### 3. Is it core functionality or enhancement?
- **Core:** Prioritize
- **Enhancement:** Defer

### 4. Can it be added later?
- **Yes:** Ship without it
- **No:** Include in MVP

### 5. Does it complicate the core experience?
- **Yes:** Strongly reconsider
- **No:** Safe to explore

---

## The North Star

**Every decision comes back to this:**

> "If I'm in Safari and want to save this link for later, can I do it in 2 seconds?"
> 
> "If I want to open my morning workflow, can I do it in 2 seconds?"

**If yes → You have a useful app.**

**If no → Keep building.**

Everything else is noise.

---

## Quick Start Checklist

When you're ready to build:

### Day 1: Setup
- [ ] Create new Xcode project (visionOS App)
- [ ] Name: Waypoint
- [ ] Enable App Groups capability
- [ ] Commit initial project to GitHub

### Day 2-3: Core Portals (Phase 1)
- [ ] Create Portal data model
- [ ] Create PortalManager
- [ ] Build list view
- [ ] Build add/edit view
- [ ] Test: Can add/edit/delete portals
- [ ] Test: Portals persist after restart

### Day 4-5: Share Extension (Phase 2)
- [ ] Add Share Extension target
- [ ] Configure to accept URLs
- [ ] Implement URL passing to main app
- [ ] Test: Share from Safari works
- [ ] Test: Share from Notes works
- [ ] Test: Share from Messages works

### Day 6-7: Constellations (Phase 3)
- [ ] Create Constellation data model
- [ ] Create ConstellationManager
- [ ] Implement grouping UI
- [ ] Implement batch launch
- [ ] Test: Create constellation with 5 portals
- [ ] Test: Launch all portals works

### Week 2: Polish & Test
- [ ] Fix all discovered bugs
- [ ] Test with real workflows
- [ ] Ensure data never corrupts
- [ ] Smooth all rough edges
- [ ] Use it yourself daily

### Week 3-4: Beta & Launch
- [ ] Invite beta testers
- [ ] Gather feedback
- [ ] Fix critical issues
- [ ] Prepare App Store materials
- [ ] Submit to App Store

---

## Remember

**You're not building a product empire.**

**You're solving a problem: 2 seconds to anywhere.**

**Ship the solution. Iterate based on reality.**

**Everything else is overthinking.**

---

**End of Ruthless MVP Roadmap**

*Build what works. Ship what helps. Listen to users. Iterate ruthlessly.*

🚀
