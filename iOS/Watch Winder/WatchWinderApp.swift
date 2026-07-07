import SwiftUI

@main
struct WatchWinderApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .task {
                    await purchases.refreshEntitlements()
                    store.isPro = purchases.isPro
                }
                .onChange(of: purchases.isPro) { _, newValue in
                    store.isPro = newValue
                }
        }
    }
}
