import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: Watch?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(Theme.headlineFont)
                                    .foregroundStyle(Theme.textPrimary)
                                Text(subtitle(for: item))
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Theme.card)
                        .accessibilityIdentifier("row_\(item.title)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Theme.background)
            }
            .navigationTitle("Watch Winder")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ItemFormView(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $editingItem) { item in
                ItemFormView(mode: .edit(item))
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(purchases)
            }
        }
        .tint(Theme.accent)
    }

    private func subtitle(for item: Watch) -> String {
        var parts: [String] = []
        
        parts.append("Reference: " + describeField(item.reference))
        parts.append("LastWorn: " + describeField(item.lastWorn))
        parts.append("Notes: " + describeField(item.notes))
        return parts.joined(separator: " · ")
    }

    private func describeField<T>(_ value: T) -> String {
        if let d = value as? Date {
            let f = DateFormatter()
            f.dateStyle = .medium
            return f.string(from: d)
        }
        return "\(value)"
    }
}

enum FormMode: Identifiable {
    case add
    case edit(Watch)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct ItemFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let mode: FormMode
    @State private var draft: Watch

    init(mode: FormMode) {
        self.mode = mode
        switch mode {
        case .add:
            _draft = State(initialValue: Watch(id: UUID(), title: String = "", reference: String = "", lastWorn: Date = Date(), notes: String = ""))
        case .edit(let item):
            _draft = State(initialValue: item)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $draft.title)
                    .accessibilityIdentifier("field_title")
                TextField("Reference", text: $draft.reference)
                    .accessibilityIdentifier("field_reference")
                DatePicker("LastWorn", selection: $draft.lastWorn, displayedComponents: .date)
                    .accessibilityIdentifier("field_lastWorn")
                TextField("Notes", text: $draft.notes)
                    .accessibilityIdentifier("field_notes")
            }
            .navigationTitle(isEditing ? "Edit Watch" : "New Watch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if isEditing {
                            store.update(draft)
                        } else {
                            store.add(draft)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
