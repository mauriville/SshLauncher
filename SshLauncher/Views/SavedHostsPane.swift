import SwiftUI

struct SavedHostsPane: View {
    let entries: [SshEntry]
    @Binding var selectedEntryID: UUID?
    let onNew: () -> Void
    let onDelete: (SshEntry) -> Void
    let onSelectionChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Saved Hosts")
                    .font(.headline)
                Spacer()
                Button("New") {
                    onNew()
                }
                .buttonStyle(.borderless)
            }

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
                List(selection: $selectedEntryID) {
                    ForEach(entries) { entry in
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
                        .tag(entry.id)
                        .contextMenu {
                            Button("Delete") {
                                onDelete(entry)
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .onChange(of: selectedEntryID) { _, _ in
                    onSelectionChange()
                }
            }
        }
        .padding(18)
        .frame(width: 250)
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}
