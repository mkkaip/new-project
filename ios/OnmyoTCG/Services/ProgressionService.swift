import Foundation

final class ProgressionService {
    private let milestones: [ProgressionMilestone]

    init(milestones: [ProgressionMilestone]) {
        self.milestones = milestones.sorted { $0.level < $1.level }
    }

    func applyXP(state: inout PlayerState, gained xp: Int) {
        state.xp += xp
        while let next = milestones.first(where: { $0.level == state.level + 1 }), state.xp >= next.xpRequired {
            state.level += 1
        }
    }

    func freePacksPerDay(for level: Int) -> Int {
        milestones.filter { $0.level <= level }.last?.freePacksPerDay ?? 0
    }
}
