import Foundation

@MainActor
final class AIUsageTracker {
    static let shared = AIUsageTracker()

    private let defaults = UserDefaults.standard
    private let usageCountKey = "ai_usage_count"
    private let resetDateKey = "ai_usage_reset_date"
    private let freeTierLimit = 3

    private init() {}

    var currentMonthUsage: Int {
        ensureMonthReset()
        return defaults.integer(forKey: usageCountKey)
    }

    var remainingFreeUses: Int {
        max(0, freeTierLimit - currentMonthUsage)
    }

    var freeTierLimitValue: Int {
        freeTierLimit
    }

    var isFreeTierExhausted: Bool {
        currentMonthUsage >= freeTierLimit
    }

    func canUseFreeTier(isAIUnlocked: Bool) -> Bool {
        if isAIUnlocked { return true }
        return !isFreeTierExhausted
    }

    func incrementUsage() {
        ensureMonthReset()
        let count = defaults.integer(forKey: usageCountKey)
        defaults.set(count + 1, forKey: usageCountKey)
    }

    func resetUsage() {
        defaults.set(0, forKey: usageCountKey)
        defaults.set(currentMonthStart(), forKey: resetDateKey)
    }

    private func ensureMonthReset() {
        let savedDate = defaults.object(forKey: resetDateKey) as? Date
        let monthStart = currentMonthStart()

        if savedDate == nil || savedDate!.timeIntervalSince1970 < monthStart.timeIntervalSince1970 {
            defaults.set(0, forKey: usageCountKey)
            defaults.set(monthStart, forKey: resetDateKey)
        }
    }

    private func currentMonthStart() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        return calendar.date(from: components)!
    }
}
