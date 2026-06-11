import SwiftUI

struct SavedHostsPane: View {
    let entries: [SshEntry]
    let selectedEntryID: UUID?
    let onNew: () -> Void
    let onDelete: (SshEntry) -> Void
    let onSelect: (SshEntry) -> Void
    @State private var hoveredEntryID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Saved Hosts")
                .font(.headline)
                .padding(.horizontal, 4)

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
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(backgroundColor(for: entry.id))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(borderColor(for: entry.id))
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
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
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
        }
        .padding(18)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.thinMaterial)
    }

    private func backgroundColor(for entryID: UUID) -> Color {
        if selectedEntryID == entryID {
            return Color.accentColor.opacity(0.16)
        }

        if hoveredEntryID == entryID {
            return Color.white.opacity(0.08)
        }

        return .clear
    }

    private func borderColor(for entryID: UUID) -> Color {
        if selectedEntryID == entryID {
            return Color.white.opacity(0.16)
        }

        return .clear
    }
}
