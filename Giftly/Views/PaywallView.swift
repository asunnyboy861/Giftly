import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseService: PurchaseService
    @Environment(AppViewModel.self) private var appViewModel

    @State private var purchasing = false
    @State private var purchaseError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HeaderSection
                    FeaturesSection
                    PurchaseCards
                    LegalLinks
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var HeaderSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "gift.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color("GiftlyPurple").gradient)
            Text("Unlock the Full Giftly")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
            Text("One-time purchases. No subscriptions. Ever.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var FeaturesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            FeatureRow(icon: "person.2.fill", text: "Unlimited people tracking")
            FeatureRow(icon: "bell.badge.fill", text: "Yearly reminders for every birthday")
            FeatureRow(icon: "gift.fill", text: "Gift idea lists with status tracking")
            FeatureRow(icon: "square.and.arrow.up.fill", text: "Export & import backup data")
            FeatureRow(icon: "wand.and.stars", text: "AI gift suggestions (AI Add-on)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var PurchaseCards: some View {
        VStack(spacing: 12) {
            if let product = purchaseService.proProduct {
                PurchaseCard(
                    product: product,
                    title: "Giftly Pro",
                    subtitle: "Unlock unlimited tracking & reminders",
                    icon: "star.fill",
                    color: "GiftlyPurple",
                    isPurchased: purchaseService.isProUnlocked,
                    isPrimary: true,
                    isPurchasing: $purchasing,
                    action: { Task { await buy(product) } }
                )
            }
            if let product = purchaseService.aiProduct {
                PurchaseCard(
                    product: product,
                    title: "AI Add-on",
                    subtitle: "Unlock AI gift suggestions forever",
                    icon: "wand.and.stars",
                    color: "GiftlyCoral",
                    isPurchased: purchaseService.isAIUnlocked,
                    isPrimary: false,
                    isPurchasing: $purchasing,
                    action: { Task { await buy(product) } }
                )
            }
            if purchaseService.proProduct == nil && purchaseService.aiProduct == nil {
                ProgressView("Loading products...")
                    .frame(maxWidth: .infinity)
                    .padding()
                if let error = purchaseService.loadError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            Button {
                Task {
                    await purchaseService.restorePurchases()
                }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundStyle(Color("GiftlyPurple"))
            }
            .padding(.top, 4)
        }
    }

    private var LegalLinks: some View {
        HStack(spacing: 16) {
            if let url = appViewModel.privacyPolicyURL() {
                Link("Privacy Policy", destination: url)
                    .font(.caption)
            }
            if let url = appViewModel.termsOfUseURL() {
                Link("Terms of Use", destination: url)
                    .font(.caption)
            }
        }
        .foregroundStyle(Color("GiftlyPurple"))
        .padding(.top, 8)
    }

    private func buy(_ product: Product) async {
        purchasing = true
        purchaseError = nil
        _ = await purchaseService.purchase(product)
        purchasing = false
        if (product.id == "com.zzoutuo.Giftly.prounlock" && purchaseService.isProUnlocked)
            || (product.id == "com.zzoutuo.Giftly.aiunlock" && purchaseService.isAIUnlocked) {
            dismiss()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color("GiftlyPurple"))
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color("GiftlyMint"))
        }
    }
}

struct PurchaseCard: View {
    let product: Product
    let title: String
    let subtitle: String
    let icon: String
    let color: String
    let isPurchased: Bool
    let isPrimary: Bool
    @Binding var isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(Color(color))
                    Text(title)
                        .font(.headline)
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isPurchased {
                Label("Owned", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("GiftlyMint"))
            } else {
                Button(action: action) {
                    HStack {
                        if isPurchasing {
                            ProgressView().tint(.white)
                        }
                        Text(product.displayPrice)
                            .font(.headline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(color))
                .disabled(isPurchasing)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isPrimary ? Color(color).opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
        )
    }
}

#Preview {
    PaywallView()
        .environment(AppViewModel())
        .environmentObject(PurchaseService.shared)
}
