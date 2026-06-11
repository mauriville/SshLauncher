import Foundation

@MainActor
struct TerminalLauncher {
    enum PermissionStatus: String {
        case unknown
        case granted
        case denied
    }

    func checkPermission() -> PermissionStatus {
        let result = runAppleScript("tell application \"Terminal\" to id")
        if result == nil {
            return .granted
        }
        return .denied
    }

    func requestPermission() -> PermissionStatus {
        let result = runAppleScript("tell application \"Terminal\" to id")
        if result == nil {
            return .granted
        }
        return .denied
    }

    func launch(command: String) -> (error: String?, permissionDenied: Bool) {
        let escapedCommand = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application \"Terminal\"
            activate
            do script \"\(escapedCommand)\"
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

        guard let appleScript = NSAppleScript(source: script) else {
            return "Could not prepare the script."
        }

        _ = appleScript.executeAndReturnError(&error)

        guard let error else { return nil }

        let errorNumber = error[NSAppleScript.errorNumber] as? Int
        if errorNumber == -1743 {
            return "permission_denied"
        }

        return error[NSAppleScript.errorMessage] as? String ?? "Script error"
    }
}