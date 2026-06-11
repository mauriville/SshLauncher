import SwiftUI

struct SavedHostsPane: View {
    let entries: [SshEntry]
    let selectedEntryID: UUID?
    let onNew: () -> Void
    let onDelete: (SshEntry) -> Void
    let onSelect: (SshEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Saved Hosts")
                .font(.headline)

            if entries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No saved connections yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Add a user and host, then save it here.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                List(entries, id: \.id) { entry in
                    Button {
                        onSelect(entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.user)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(entry.host)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedEntryID == entry.id ? Color.accentColor.opacity(0.18) : .clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Delete") {
                            onDelete(entry)
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .padding(18)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
