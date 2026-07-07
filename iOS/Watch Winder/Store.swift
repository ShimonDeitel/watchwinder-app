import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Watch] = []
    @Published var isPro: Bool = false

    static let freeLimit = 25

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("watchwinder", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Watch) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Watch) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Watch) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Watch].self, from: data) {
            items = decoded
        } else {
            items = Store.seedData
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static var seedData: [Watch] {
        [
        Watch(id: UUID(), title: "Seiko 5", reference: "SNK809", lastWorn: ISO8601DateFormatter().date(from: "2026-06-01T00:00:00Z") ?? Date(), notes: "Daily beater"),
        Watch(id: UUID(), title: "Speedmaster", reference: "311.30", lastWorn: ISO8601DateFormatter().date(from: "2026-05-15T00:00:00Z") ?? Date(), notes: "Weekend"),
        Watch(id: UUID(), title: "Datejust", reference: "126200", lastWorn: ISO8601DateFormatter().date(from: "2026-04-01T00:00:00Z") ?? Date(), notes: "Formal")
        ]
    }
}
