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
                .frame(minWidth: 380, minHeight: 300)
                .toolbar {
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
    }
}
