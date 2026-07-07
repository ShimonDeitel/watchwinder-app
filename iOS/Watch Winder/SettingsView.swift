import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("notify_enabled") private var notifyEnabled = true
    @AppStorage("compact_view") private var compactView = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable Reminders", isOn: $notifyEnabled)
                        .accessibilityIdentifier("toggleReminders")
                    Toggle("Compact List View", isOn: $compactView)
                        .accessibilityIdentifier("toggleCompact")
                }
                Section("Pro") {
                    if purchases.isPro {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Text("Free tier: up to \(Store.freeLimit) items")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("settingsRestoreButton")
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/watchwinder-app/privacy.html")!)
                        .accessibilityIdentifier("privacyPolicyLink")
                    Text("Contact: s0533495227@gmail.com")
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
