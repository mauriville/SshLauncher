# AGENTS.md — AI Context for SshLauncher

## Overview

SshLauncher is a native macOS SwiftUI app that saves SSH connection details and launches `ssh` commands in macOS Terminal via AppleScript automation.

## Tech Stack

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (AppKit interop where needed)
- **Minimum macOS**: 13.0 (Ventura)
- **Build system**: Xcode project (no SPM/Package.swift)
- **Persistence**: UserDefaults + JSON encoding (no CoreData or files)
- **Terminal integration**: NSAppleScript — sends `do script` commands to com.apple.Terminal

## Architecture

**MVVM** — no third-party dependencies.

| Layer | Key files | Responsibility |
|-------|-----------|----------------|
| Model | `Models/SshEntry.swift` | `Codable` struct: `{id: UUID, user: String, host: String}` |
| ViewModel | `ViewModels/ContentViewModel.swift` | All `@Published` state, CRUD ops, delegates to services |
| Views | `Views/*.swift`, `ContentView.swift` | Pure SwiftUI; receive bindings & closures, no business logic |
| Services | `Services/SshEntryStore.swift`, `Services/TerminalLauncher.swift` | Persistence & AppleScript Terminal control |

## Key Conventions

- ViewModels are `@MainActor` and `ObservableObject`; injected via `@StateObject`/`@ObservedObject`.
- Services (`SshEntryStore`, `TerminalLauncher`) are value-type structs marked `@MainActor`.
- Views communicate with the ViewModel through closures and `@Binding` — no view-internal state for domain data.
- Sidebar auto-collapses when window width < 560, reappears at ≥ 620 (see `WindowSizeReader` in `ContentView.swift`).
- Entries are sorted alphabetically by `host` on every save.
- No external dependencies or package manager.

## Build & Run

```
# Open in Xcode
open SshLauncher.xcodeproj

# Or build from CLI
xcodebuild -project SshLauncher.xcodeproj -scheme SshLauncher build
```

There are no tests configured yet.

## Important Behaviors

- **Automation permission**: On first Terminal launch, macOS prompts for Automation access. Error `-1743` means permission denied — the app shows a link to System Settings.
- **Sandboxing is disabled** (`com.apple.security.app-sandbox` = `false` in entitlements) because AppleScript control of Terminal is not possible in a sandboxed app.
- **Terminal detection**: `TerminalLauncher.checkPermission()` looks for `com.apple.Terminal` via `NSWorkspace`; if missing, a "Terminal Not Found" status is shown with a button to open System Settings.
- Command escaping: backslashes and quotes in user/host fields are escaped before being passed to the AppleScript string.