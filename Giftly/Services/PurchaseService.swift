import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    @Published var isProUnlocked: Bool = false
    @Published var isAIUnlocked: Bool = false
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var loadError: String?

    private let proProductId = "com.zzoutuo.Giftly.prounlock"
    private let aiProductId = "com.zzoutuo.Giftly.aiunlock"
    private var productIds: Set<String> {
        [proProductId, aiProductId]
    }
    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await checkPurchased()
        }
    }

    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIds)
            isLoading = false
        } catch {
            loadError = "Unable to load purchase options."
            isLoading = false
        }
    }

    var proProduct: Product? {
        products.first { $0.id == proProductId }
    }

    var aiProduct: Product? {
        products.first { $0.id == aiProductId }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await checkPurchased()
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            loadError = "Purchase failed: \(error.localizedDescription)"
        }
        return false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchased()
        } catch {
            loadError = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func checkPurchased() async {
        if let proResult = await Transaction.currentEntitlement(for: proProductId) {
            if case .verified(let transaction) = proResult {
                isProUnlocked = transaction.revocationDate == nil
            } else {
                isProUnlocked = false
            }
        } else {
            isProUnlocked = false
        }

        if let aiResult = await Transaction.currentEntitlement(for: aiProductId) {
            if case .verified(let transaction) = aiResult {
                isAIUnlocked = transaction.revocationDate == nil
            } else {
                isAIUnlocked = false
            }
        } else {
            isAIUnlocked = false
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    Task { @MainActor [weak self] in
                        await self?.checkPurchased()
                    }
                }
            }
        }
    }

    deinit {
        transactionListener?.cancel()
    }
}
