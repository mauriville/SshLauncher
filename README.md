# SshLauncher

A macOS app that lets you save SSH connection details and launch them directly in Terminal with one click.

## Features

- **Save connections** — Store user@host pairs for quick access
- **One-click launch** — Sends the `ssh` command straight to macOS Terminal
- **Command preview** — See the exact command before you run it
- **Sorted sidebar** — Saved hosts listed alphabetically for fast lookup
- **Responsive layout** — Sidebar collapses automatically on narrow windows

## Requirements

- macOS 13.0+ (Ventura)
- Xcode 15+
- Swift 5.9+

## Building

1. Clone the repo
2. Open `SshLauncher.xcodeproj` in Xcode
3. Build and run (⌘R)

## Permissions

On first launch, macOS will ask you to grant **Automation** permission so SshLauncher can control Terminal. If you deny it, the app will show a prompt with a link to System Settings where you can re-enable it.

Go to **System Settings → Privacy & Security → Automation** and enable SshLauncher's access to Terminal.

## Project Structure

```
SshLauncher/
├── SshLauncherApp.swift          # App entry point & main window
├── ContentView.swift             # Root layout (NavigationSplitView + responsive sidebar)
├── Models/
│   └── SshEntry.swift            # Codable model (id, user, host)
├── Services/
│   ├── SshEntryStore.swift       # Persistence via UserDefaults + JSON
│   └── TerminalLauncher.swift    # AppleScript bridge to macOS Terminal
├── ViewModels/
│   └── ContentViewModel.swift    # State management, CRUD, launch logic
└── Views/
    ├── ConnectionEditorCard.swift # User/host fields & action buttons
    ├── CommandPreviewCard.swift  # Live command preview
    └── SavedHostsPane.swift      # Sidebar list of saved hosts
```

## Architecture

SshLauncher follows the **MVVM** pattern:

- **Model** — `SshEntry` is a simple `Codable` value type with `id`, `user`, and `host`.
- **ViewModel** — `ContentViewModel` owns all published state, delegates persistence to `SshEntryStore`, and Terminal communication to `TerminalLauncher`.
- **Views** — Pure SwiftUI views receive bindings and callbacks from the ViewModel; no business logic lives in views.

Persistence uses `UserDefaults` with JSON-encoded arrays. Terminal integration uses `NSAppleScript` to run `do script` commands in the Terminal app.

## License

This project is provided as-is. See individual files for copyright information.