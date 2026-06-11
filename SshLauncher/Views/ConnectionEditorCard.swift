import SwiftUI

struct ConnectionEditorCard: View {
    @Binding var sshUser: String
    @Binding var sshHost: String
    let canSave: Bool
    let hasSelection: Bool
    let onSave: () -> Void
    let onLaunch: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Connection")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                Text("User")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField("ubuntu", text: $sshUser)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Host")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField("server.example.com", text: $sshHost)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button(hasSelection ? "Update Host" : "Save Host") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)

                Button("Launch in Terminal") {
                    onLaunch()
                }
                .buttonStyle(.bordered)
                .disabled(!canSave)

                Spacer()

                if hasSelection {
                    Button("Delete") {
                        onDelete()
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.red)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(nsColor: .controlBackgroundColor),
                            Color(nsColor: .underPageBackgroundColor)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}
