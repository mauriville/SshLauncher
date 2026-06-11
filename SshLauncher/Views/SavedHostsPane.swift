import SwiftUI

struct SavedHostsPane: View {
    let entries: [SshEntry]
    let selectedEntryID: UUID?
    let onNew: () -> Void
    let onDelete: (SshEntry) -> Void
    let onSelect: (SshEntry) -> Void
    @State private var hoveredEntryID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Saved Hosts")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 6)

            if entries.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No saved connections yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Add a user and host, then save it here.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                List(entries, id: \.id) { entry in
                    Button {
                        onSelect(entry)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "terminal")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .frame(width: 16)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(entry.user)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.primary)
                                Text(entry.host)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(backgroundColor(for: entry.id))
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onHover { isHovering in
                        hoveredEntryID = isHovering ? entry.id : nil
                    }
                    .contextMenu {
                        Button("Delete") {
                            onDelete(entry)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func backgroundColor(for entryID: UUID) -> Color {
        if selectedEntryID == entryID {
            return Color.accentColor.opacity(0.18)
        }

        if hoveredEntryID == entryID {
            return Color.primary.opacity(0.06)
        }

        return .clear
    }
}
