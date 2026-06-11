import SwiftUI

struct CommandPreviewCard: View {
    let command: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Command Preview")
                .font(.headline)
            Text(command)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.85))
                )
                .foregroundStyle(Color.green.opacity(0.95))
            Text("Terminal opens with the SSH command inserted and ready to edit or run.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}
