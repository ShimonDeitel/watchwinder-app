import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                    Text("Watch Winder Pro")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Unlimited watches and service-interval reminders")
                        .font(Theme.bodyFont)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.horizontal)
                    if let product = purchases.product {
                        Text("\(product.displayPrice) one-time")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text("Unlock Pro")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("unlockProButton")
                    .padding(.horizontal)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restoreButton")
                    .foregroundStyle(Theme.textSecondary)

                    Button("Not now") { dismiss() }
                        .accessibilityIdentifier("dismissPaywallButton")
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding()
            }
        }
    }
}
