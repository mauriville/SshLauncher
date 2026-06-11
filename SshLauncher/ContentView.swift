import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationSplitView {
            SavedHostsPane(
                entries: viewModel.entries,
                selectedEntryID: viewModel.selectedEntryID,
                onNew: viewModel.clearDraft,
                onDelete: viewModel.delete,
                onSelect: viewModel.select
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        } detail: {
            VStack(alignment: .leading, spacing: 18) {
                header

                if viewModel.showsPermissionNotice {
                    permissionNotice
                }

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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .onAppear(perform: viewModel.loadEntries)
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

    private var permissionNotice: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lock.shield")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Terminal Permission Needed")
                    .font(.headline)
                Text("SshLauncher needs permission to control Terminal before it can prepare your SSH command. You can trigger the macOS prompt now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button("Allow Terminal Access") {
                        viewModel.requestTerminalPermission()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Later") {
                        viewModel.dismissPermissionNotice()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
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
