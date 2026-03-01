import Foundation

final class PvEService {
    private let combat = CombatService()
    private let progression: ProgressionService

    init(progression: ProgressionService) {
        self.progression = progression
    }

    @discardableResult
    func clearStage(_ stage: PvEStage, state: inout PlayerState) -> Bool {
        // MVP: deterministic simplified auto-battle result.
        var battle = BattleState(
            player: BattleSideState(hand: [], deck: [], field: [], leaderHP: 20, barrier: 0, maxMana: 0, mana: 0, fieldParams: [:]),
            enemy: BattleSideState(hand: [], deck: [], field: [], leaderHP: 18, barrier: 0, maxMana: 0, mana: 0, fieldParams: [:])
        )
        combat.startTurn(forPlayer: true, state: &battle)

        guard battle.player.leaderHP > 0 else { return false }
        state.reishi += stage.rewardReishi
        state.ofuda += stage.rewardOfuda
        progression.applyXP(state: &state, gained: stage.rewardXP)
        return true
    }
}
