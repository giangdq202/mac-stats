# AGENTS.md — MeMo (Personal Fork)

> README for all AI agents (Antigravity, Claude Code, Cursor, Codex, OpenCode, GitHub Copilot...).
> This is the single source of truth. Read this entire file before doing anything.

---

## Project Context

**MeMo** is a macOS Menu Bar Monitor app, pure Swift, no Xcode.
Personal fork from [openhoangnc/mac-stats] (now located at giangdq202/memo) (MIT License).

**Owner**: Personal user, learning Swift through practical projects.
**Remote repo**: Configured on GitHub (`origin`) with **Branch Protection** (PR required, Squash Merge, No force-push).

---

## MANDATORY WORKFLOW — THIS IS A STRICT PROCESS

**Every AI agent must follow this workflow, no exceptions:**

```
1. GRILL    -> Ask the developer until the true intent is fully understood
2. PLAN     -> Continue grilling until a specific plan is finalized
3. BRANCH   -> Create a git branch BEFORE writing any code
4. IMPLEMENT-> Implement in small steps, explain why before coding
5. BUILD    -> Automatically run `bash build.sh` after each change
6. TEST     -> Confirm the app works correctly
7. COMMIT   -> Commit using Conventional Commits format
8. MEMORY   -> Update `.agent/memory/` after every commit
9. PR & MERGE -> Push branch, open PR, and Squash Merge into main
```

> DO NOT EVER code directly on the `main` branch.
> DO NOT EVER skip the GRILL step — even if the request seems simple.

Details: [`.agent/skills/feature-planning-workflow/SKILL.md`](.agent/skills/feature-planning-workflow/SKILL.md)

---

## CRITICAL CHANGES — STOP AND ASK USER

If a change falls into any of the categories below, **the AI must stop and ask the user first**:

- Modifying `SMC.swift` (low-level IOKit, very easy to break)
- Modifying `Info.plist` (especially `LSUIElement`)
- Deleting or changing the `.app` bundle structure
- Changing the deployment target (macOS 11 is minimum)
- Changing the SDK path in `build.sh`
- Replacing AppKit with SwiftUI or adding any external dependency
- Any action affecting the filesystem outside the project folder
- Any action affecting the local machine (install, uninstall, registry)

---

## Communication

- **Explanation**: English only.
- **Code & Comments**: English only.
- **Style**: Explain `why` first, then provide the code.
- **Ambiguity**: Grill until a plan is finalized, do not make assumptions.
- **New Code**: Clean, no redundant comments — but clearly explained in the chat.
- **Language & Formatting**: All scripts, code, and markdown files in this repository MUST be in English. NO emojis or icons are allowed.

---

## Project Structure

```
memo/
├── main.swift          # Entry point: CLI flags, duplicate prevention
├── AppDelegate.swift   # App lifecycle, timer, menu, settings
├── StatsEngine.swift   # Data collection: CPU/RAM/Network/Processes
├── StatusBarView.swift # UI rendering: menu bar display
├── SMC.swift           # Temperature via IOKit/SMC — DO NOT MODIFY
├── build.sh            # Build script (no Xcode needed)
├── install.sh          # One-line install
├── uninstall.sh        # Clean uninstall
├── Info.plist          # Bundle metadata — BE CAREFUL WHEN MODIFYING
├── AGENTS.md           # <- This file
└── .agent/
    ├── rules/          # Development rules
    ├── hooks/          # Pre/post build scripts
    ├── skills/         # Instructions for implementing features
    └── memory/         # Memory across sessions
```

---

## Build & Run

```bash
# Build (arm64 binary)
bash build.sh

# Open app
open MeMo.app

# Build + install into /Applications
./install.sh

# Uninstall
./uninstall.sh
```

> **SDK**: `/Library/Developer/CommandLineTools/SDKs/MacOSX15.5.sdk` — hardcoded in `build.sh`.

---

## Coding Standards

- **Swift 5.x** (do not use Swift 6 strict concurrency)
- Prefer `guard let` over `if let`
- `// MARK: -` to organize code sections
- Variable names: `camelCase`, function names: `verb + noun`

Details: [`.agent/rules/swift-style.md`](.agent/rules/swift-style.md)

---

## Hard Rules (DO NOT DO)

- DO NOT add third-party dependencies
- DO NOT use Xcode project files (`.xcodeproj`)
- DO NOT import SwiftUI
- DO NOT modify `SMC.swift`
- DO NOT change `LSUIElement=true` in `Info.plist`
- DO NOT commit build artifacts (`MeMo.app`, `*_bin`, etc.)
- DO NOT write code blocks longer than 50 lines at once
- DO NOT code directly on the `main` branch
- DO NOT push directly to the `main` branch (all code must go through PR)
- DO NOT use emojis or icons anywhere in the project.

---

## Definition of Done

A feature is considered done when:
1. `bash build.sh` has no new errors/warnings
2. App launches, icon appears on the menu bar
3. Feature works exactly as the finalized plan
4. Settings persist after app restart
5. Dark mode and Light mode both render correctly
6. Committed with Conventional Commits message
7. Updated `.agent/memory/` after commit
8. Branch pushed to remote, PR opened, and Squash Merged into `main`

---

## Personalization Goals (Priority Order)

1. **Custom Color Thresholds** — Discrete colors (green/yellow/red) with custom thresholds
2. **Compact Display** — Use minimal pixels on the menu bar
3. **Expand later** — Notification alerts, history chart, GPU... (not needed immediately)

---

## Key Files Reference

| Target | File to Modify | Important Lines |
|---|---|---|
| Indicator colors | `StatusBarView.swift` | `colorForUsage()`, `colorForTemperature()` |
| Add settings menu | `AppDelegate.swift` | `showMenu()` ~L91 |
| Collect new data | `StatsEngine.swift` | Add `fetchXxxStats()` |
| Menu bar layout | `StatusBarView.swift` | `draw()` ~L172, section widths |
| Build configuration | `build.sh` | SDK path, flags |

---

## Skills Index

| Skill | When to use |
|---|---|
| `feature-planning-workflow` | Starting any feature |
| `git-workflow` | Branch, commit, merge |
| `swift-menubar-basics` | Questions about NSColor, UserDefaults, AppKit... |
| `custom-threshold-feature` | Implement warn/critical color levels |
| `compact-display` | Implement compact/minimal mode |
| `debug-and-fix` | Build errors or runtime crashes |

---

## Known Issues

- **SDK mismatch**: Fixed — hardcoded SDK path in `build.sh`
- **Top Processes uses subprocess**: Acceptable — only runs when opening menu
- **Network only counts "en" interfaces**: By design — VPN/utun not counted
