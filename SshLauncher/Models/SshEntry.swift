import Foundation

struct SshEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let user: String
    let host: String
}
