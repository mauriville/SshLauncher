import Foundation

@MainActor
struct TerminalLauncher {
    func launch(command: String) -> String? {
        let escapedCommand = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application \"Terminal\"
            activate
            if (count of windows) = 0 then
                do script ""
            end if
            do script \"printf \\\"%s\\\" \\\"\(escapedCommand)\\\"\" in front window
        end tell
        """

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
