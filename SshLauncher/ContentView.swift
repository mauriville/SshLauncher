import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var windowWidth: CGFloat = 900

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SavedHostsPane(
                entries: viewModel.entries,
                selectedEntryID: viewModel.selectedEntryID,
                onNew: viewModel.clearDraft,
                onDelete: viewModel.delete,
                onSelect: viewModel.select
            )
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    terminalStatusCard

                    ConnectionEditorCard(
                        sshUser: $viewModel.sshUser,
                        sshHost: $viewModel.sshHost,
                        canSave: viewModel.canSave,
                        hasSelection: viewModel.selectedEntry != nil,
                        onSave: viewModel.saveEntry,
                        onLaunch: viewModel.launchTerminal,
                        onDelete: deleteSelectedEntry
                    )

                    CommandPreviewCard(command: viewModel.draftCommand)

                    if let launchErrorMessage = viewModel.launchErrorMessage {
                        Text(launchErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear(perform: viewModel.loadEntries)
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResizeNotification)) { notification in
            guard let window = notification.object as? NSWindow else { return }
            let newWidth = window.frame.width
            if newWidth < 600 && windowWidth >= 600 {
                columnVisibility = .detailOnly
            } else if newWidth >= 600 && windowWidth < 600 {
                columnVisibility = .all
            }
            windowWidth = newWidth
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SSH Launcher")
                    .font(.system(size: 28, weight: .semibold))
                Text("Keep a few connections handy and send the command to Terminal when you need it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.bottom, 4)
    }

    private var terminalStatusCard: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(viewModel.terminalPermission == .granted ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            if viewModel.terminalPermission == .granted {
                Text("Terminal Access: Ready")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Terminal Not Found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Open System Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.general") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            if viewModel.terminalPermission == .granted {
                Spacer()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private func deleteSelectedEntry() {
        guard let selectedEntry = viewModel.selectedEntry else { return }
        viewModel.delete(selectedEntry)
    }
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}