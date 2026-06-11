import Foundation

@MainActor
struct SshEntryStore {
    private let defaults: UserDefaults
    private let storageKey = "savedEntries"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadEntries() -> [SshEntry] {
        guard let dataString = defaults.string(forKey: storageKey),
              let data = dataString.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([SshEntry].self, from: data) else {
            return []
        }

        return decoded
    }

    func saveEntries(_ entries: [SshEntry]) {
        guard let data = try? JSONEncoder().encode(entries),
              let encoded = String(data: data, encoding: .utf8) else {
            return
        }

        defaults.set(encoded, forKey: storageKey)
    }
}
