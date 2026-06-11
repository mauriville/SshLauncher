import SwiftUI

struct TopBar: View {
    let isCompact: Bool
    let canSave: Bool
    let showsSidebarToggle: Bool
    let onToggleSidebar: () -> Void
    let onNew: () -> Void
    let onSave: () -> Void
    let onLaunch: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if showsSidebarToggle {
                Button(action: onToggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
                .buttonStyle(.borderless)
                .help("Show saved hosts")
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("SSH Launcher")
                    .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                Text("Keep a few connections handy and send the command to Terminal when you need it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(isCompact ? 2 : 1)
            }

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                Button("New") {
                    onNew()
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.bordered)
                .disabled(!canSave)

                Button("Launch") {
                    onLaunch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
            .labelStyle(.titleOnly)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18))
        )
    }
}
