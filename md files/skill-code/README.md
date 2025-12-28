# Code Development Skill

A principles-based framework for AI-assisted software development that emphasizes incremental progression, clear structure, and hands-on learning.

## What This Skill Does

Teaches software development with:
- **Section markers** for rapid code navigation
- **Phase-gate progression** for building working features incrementally
- **One-feature-at-a-time** completion workflow
- Support for both **collaborative** (step-by-step) and **automated** (complete delivery) modes

## Installation

### For Claude.ai

1. Go to your Claude.ai settings
2. Navigate to the "Skills" section
3. Click "Upload Custom Skill"
4. Upload the entire `skill-code` folder (or zip it first)
5. Enable the skill in your settings

### For Claude Code

```bash
# Copy the skill to your Claude Code skills directory
cp -r skill-code ~/.claude/skills/

# Or for project-specific use
cp -r skill-code /path/to/your/project/.claude/skills/
```

### For API Use

See the [Skills API documentation](https://platform.claude.com/docs/en/build-with-claude/skills-guide) for uploading custom skills via the API.

## Usage

Once installed, Claude will automatically use this skill when you:
- Ask for help implementing features
- Request debugging assistance
- Want code organization guidance
- Need step-by-step coding instruction

### Triggering Collaborative Mode
- "Let's build [feature]"
- "Help me implement [feature]"
- "Walk me through building [feature]"

### Triggering Automated Mode
- "Give me a complete implementation of [feature]"
- "I need [feature] fully built"
- "Provide the full code for [feature]"

## What Makes This Skill Different

This skill uses **principles over prescriptions** - it gives Claude guidance on your learning style and preferences rather than rigid templates to follow. This allows for:
- Natural, adaptive responses
- Creative problem-solving within your preferences
- Focus on substance over formatting
- Flow that matches the specific situation

## Core Principles

- Break complex features into testable phases
- Use section markers for rapid navigation
- Complete one feature before starting another
- Explain architectural "why" contextually
- Provide verification points at each step
- Trust developer capability

## Structure

```
skill-code/
├── SKILL.md          # Main skill file with YAML frontmatter
└── README.md         # This file
```

## Customization

Feel free to edit `SKILL.md` to match your specific:
- Preferred section marker style
- Typical tech stack
- Code commenting preferences
- Debugging approaches

The skill is designed to be a living document that evolves with your workflow.

## License

This skill is provided as-is for personal use. Modify freely to match your needs.
