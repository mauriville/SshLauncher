import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel

    private let compactBreakpoint: CGFloat = 720

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < compactBreakpoint

            ZStack(alignment: .leading) {
                VStack(spacing: 16) {
                    header(isCompact: isCompact)

                    HStack(spacing: 20) {
                        if !isCompact {
                            SavedHostsPane(
                                entries: viewModel.entries,
                                selectedEntryID: $viewModel.selectedEntryID,
                                onNew: viewModel.clearDraft,
                                onDelete: viewModel.delete,
                                onSelectionChange: viewModel.handleSelectionChange
                            )
                        }

                        VStack(alignment: .leading, spacing: 18) {
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))

                if isCompact && viewModel.showsCompactSidebar {
                    Rectangle()
                        .fill(Color.black.opacity(0.18))
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.closeCompactSidebar()
                            }
                        }

                    SavedHostsPane(
                        entries: viewModel.entries,
                        selectedEntryID: $viewModel.selectedEntryID,
                        onNew: handleNewAction,
                        onDelete: viewModel.delete,
                        onSelectionChange: handleCompactSidebarSelection
                    )
                    .frame(width: min(320, geometry.size.width * 0.78))
                    .padding(.leading, 16)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.showsCompactSidebar)
            .onChange(of: isCompact) { _, compact in
                if !compact {
                    viewModel.closeCompactSidebar()
                }
            }
            .onAppear(perform: viewModel.loadEntries)
        }
    }

    @ViewBuilder
    private func header(isCompact: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SSH Launcher")
                    .font(.system(size: isCompact ? 22 : 28, weight: .semibold))
                Text("Keep a few connections handy and send the command to Terminal when you need it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(isCompact ? 2 : 1)
            }

            Spacer()
        }
        .padding(.bottom, 4)
    }

    private func deleteSelectedEntry() {
        guard let selectedEntry = viewModel.selectedEntry else { return }
        viewModel.delete(selectedEntry)
    }

    private func handleNewAction() {
        viewModel.clearDraft()
    }

    private func handleCompactSidebarSelection() {
        viewModel.handleSelectionChange()
        viewModel.closeCompactSidebar()
    }
}

#Preview {
    ContentView(viewModel: ContentViewModel())
}
