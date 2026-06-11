//
//  SshLauncherApp.swift
//  SshLauncher
//
//  Created by Mauricio Villegas on 10/6/26.
//

import SwiftUI
import AppKit

@main
struct SshLauncherApp: App {
    @StateObject private var viewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .frame(minWidth: 560, minHeight: 420)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                        } label: {
                            Label("Toggle Sidebar", systemImage: "sidebar.left")
                        }
                    }

                    ToolbarItem {
                        Button {
                            viewModel.clearDraft()
                        } label: {
                            Label("New Host", systemImage: "plus")
                        }
                    }
                }
        }
        .defaultSize(width: 900, height: 560)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Connection") {
                    viewModel.clearDraft()
                }
                .keyboardShortcut("n")
            }
        }
    }
}
