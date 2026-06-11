import Foundation

@MainActor
struct TerminalLauncher {
    private let permissionPromptKey = "terminalAutomationPermissionPromptShown"

    func shouldShowPermissionNotice() -> Bool {
        !UserDefaults.standard.bool(forKey: permissionPromptKey)
    }

    func requestAutomationPermissionIfNeeded() -> String? {
        guard shouldShowPermissionNotice() else {
            return nil
        }

        UserDefaults.standard.set(true, forKey: permissionPromptKey)
        return runAppleScript("""
        tell application \"Terminal\"
            activate
        end tell
        """)
    }

    func launch(command: String) -> String? {
        let escapedCommand = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        return runAppleScript("""
        tell application \"Terminal\"
            activate
            do script \"\(escapedCommand)\"
        end tell
        """)
    }

    private func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?

        guard let appleScript = NSAppleScript(source: script) else {
            return "Could not prepare the Terminal automation script."
        }

        _ = appleScript.executeAndReturnError(&error)
        return terminalAutomationErrorMessage(from: error)
    }

    private func terminalAutomationErrorMessage(from error: NSDictionary?) -> String? {
        guard let error else { return nil }

        let errorNumber = error[NSAppleScript.errorNumber] as? Int
        let errorMessage = error[NSAppleScript.errorMessage] as? String

        if errorNumber == -1743 {
            return "Automation permission is required. In System Settings > Privacy & Security > Automation, allow SshLauncher or Xcode to control Terminal."
        }

        return errorMessage ?? "Could not control Terminal."
    }
}
