import Foundation

struct Watch: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var reference: String
    var lastWorn: Date
    var notes: String
}
