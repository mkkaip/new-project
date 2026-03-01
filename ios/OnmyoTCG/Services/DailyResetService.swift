import Foundation

final class DailyResetService {
    private let progressionService: ProgressionService
    private let nowProvider: () -> Date

    init(progressionService: ProgressionService, nowProvider: @escaping () -> Date = Date.init) {
        self.progressionService = progressionService
        self.nowProvider = nowProvider
    }

    func refreshIfNeeded(state: inout PlayerState) {
        let current = Self.jstDateString(from: nowProvider())
        guard current != state.lastDailyResetJST else { return }
        let base = progressionService.freePacksPerDay(for: state.level)
        state.freePackTickets += base + state.monthlyPass.tier.bonusTickets
        state.lastDailyResetJST = current
    }

    static func jstDateString(from date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 9 * 3600) ?? .current
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 1970, c.month ?? 1, c.day ?? 1)
    }
}
