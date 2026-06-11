import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showsCompactSidebar = false

    private let compactBreakpoint: CGFloat = 720

    var body: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < compactBreakpoint

            ZStack(alignment: .leading) {
                VStack(spacing: 16) {
                    TopBar(
                        isCompact: isCompact,
                        canSave: viewModel.canSave,
                        showsSidebarToggle: isCompact,
                        onToggleSidebar: toggleCompactSidebar,
                        onNew: handleNewAction,
                        onSave: viewModel.saveEntry,
                        onLaunch: viewModel.launchTerminal
                    )

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

                if isCompact && showsCompactSidebar {
                    Rectangle()
                        .fill(Color.black.opacity(0.18))
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showsCompactSidebar = false
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
            .animation(.easeInOut(duration: 0.2), value: showsCompactSidebar)
            .onChange(of: isCompact) { _, compact in
                if !compact {
                    showsCompactSidebar = false
                }
            }
            .onAppear(perform: viewModel.loadEntries)
        }
    }

    private func deleteSelectedEntry() {
        guard let selectedEntry = viewModel.selectedEntry else { return }
        viewModel.delete(selectedEntry)
    }

    private func handleNewAction() {
        showsCompactSidebar = false
        viewModel.clearDraft()
    }

    private func handleCompactSidebarSelection() {
        viewModel.handleSelectionChange()
        showsCompactSidebar = false
    }

    private func toggleCompactSidebar() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showsCompactSidebar.toggle()
        }
    }
}

#Preview {
    ContentView()
}
