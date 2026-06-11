import Foundation
import AppKit

@MainActor
struct TerminalLauncher {
    enum PermissionStatus {
        case unknown
        case granted
        case denied
    }

    func checkPermission() -> PermissionStatus {
        let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")
        return terminalURL != nil ? .granted : .denied
    }

    func requestPermission() -> PermissionStatus {
        let result = runAppleScript("tell application \"Terminal\" to id")
        return result == nil ? .granted : .denied
    }

    func launch(command: String) -> (error: String?, permissionDenied: Bool) {
        let escapedCommand = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Terminal"
            activate
            do script "\(escapedCommand)"
        end tell
        """

        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            return (error: "Could not prepare the Terminal automation script.", permissionDenied: false)
        }

        _ = appleScript.executeAndReturnError(&error)

        guard let error else {
            return (error: nil, permissionDenied: false)
        }

        let errorNumber = error[NSAppleScript.errorNumber] as? Int
        let isPermissionDenied = errorNumber == -1743

        if isPermissionDenied {
            return (error: "Automation permission is required. In System Settings > Privacy & Security > Automation, allow SshLauncher to control Terminal.", permissionDenied: true)
        }

        let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Could not control Terminal."
        return (error: errorMessage, permissionDenied: false)
    }

    private func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return "Could not prepare script." }
        _ = appleScript.executeAndReturnError(&error)

        guard let error else { return nil }
        return error[NSAppleScript.errorMessage] as? String ?? "Script error"
    }
}