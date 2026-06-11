import Foundation
import Combine

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var entries: [SshEntry] = []
    @Published var selectedEntryID: UUID?
    @Published var sshUser = ""
    @Published var sshHost = ""
    @Published var launchErrorMessage: String?
    @Published var terminalPermission: TerminalLauncher.PermissionStatus = .unknown

    private var hasLoadedEntries = false

    private let entryStore: SshEntryStore
    private let terminalLauncher: TerminalLauncher

    init() {
        self.entryStore = SshEntryStore()
        self.terminalLauncher = TerminalLauncher()
    }

    init(
        entryStore: SshEntryStore,
        terminalLauncher: TerminalLauncher
    ) {
        self.entryStore = entryStore
        self.terminalLauncher = terminalLauncher
    }

    var draftCommand: String {
        guard !trimmedUser.isEmpty, !trimmedHost.isEmpty else {
            return "ssh user@example-host"
        }

        return "ssh \(trimmedUser)@\(trimmedHost)"
    }

    var canSave: Bool {
        !trimmedUser.isEmpty && !trimmedHost.isEmpty
    }

    var selectedEntry: SshEntry? {
        guard let selectedEntryID else { return nil }
        return entries.first(where: { $0.id == selectedEntryID })
    }

    func loadEntries() {
        guard !hasLoadedEntries else { return }

        entries = entryStore.loadEntries()
        checkTerminalPermission()
        hasLoadedEntries = true
    }

    func checkTerminalPermission() {
        terminalPermission = terminalLauncher.checkPermission()
    }

    func requestTerminalPermission() {
        terminalPermission = terminalLauncher.requestPermission()
    }

    func launchTerminal() {
        let result = terminalLauncher.launch(command: draftCommand)
        launchErrorMessage = result.error

        if result.permissionDenied {
            terminalPermission = .denied
        } else if result.error == nil {
            terminalPermission = .granted
        }
    }

    func handleSelectionChange() {
        guard let selectedEntryID,
              let entry = entries.first(where: { $0.id == selectedEntryID }) else {
            return
        }

        select(entry)
    }

    func saveEntry() {
        let entry = SshEntry(id: selectedEntryID ?? UUID(), user: trimmedUser, host: trimmedHost)

        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }

        entries.sort { $0.host.localizedCaseInsensitiveCompare($1.host) == .orderedAscending }
        selectedEntryID = entry.id
        entryStore.saveEntries(entries)
    }

    func select(_ entry: SshEntry) {
        selectedEntryID = entry.id
        sshUser = entry.user
        sshHost = entry.host
    }

    func delete(_ entry: SshEntry) {
        entries.removeAll { $0.id == entry.id }

        if selectedEntryID == entry.id {
            clearDraft()
        }

        entryStore.saveEntries(entries)
    }

    func clearDraft() {
        sshUser = ""
        sshHost = ""
        selectedEntryID = nil
        launchErrorMessage = nil
    }

    private var trimmedUser: String {
        sshUser.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedHost: String {
        sshHost.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}