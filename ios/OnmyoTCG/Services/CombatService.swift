import Foundation

struct UnitState: Equatable {
    let id: UUID
    let cardID: String
    var attack: Int
    var health: Int
    var shield: Int
    var taunt: Bool
    var guardUnit: Bool
}

struct BattleSideState {
    var hand: [String]
    var deck: [String]
    var field: [UnitState]
    var leaderHP: Int
    var barrier: Int
    var maxMana: Int
    var mana: Int
    var fieldParams: [String: Int]
}

struct BattleState {
    var player: BattleSideState
    var enemy: BattleSideState
}

final class CombatService {
    func startTurn(forPlayer: Bool, state: inout BattleState) {
        if forPlayer {
            applyStartTurn(to: &state.player, enemy: &state.enemy)
        } else {
            applyStartTurn(to: &state.enemy, enemy: &state.player)
        }
    }

    func playCard(card: Card, side: inout BattleSideState) {
        guard side.mana >= card.cost else { return }
        side.mana -= card.cost
        switch card.type {
        case .unit:
            let tokenBoost = side.fieldParams["on_play_summon_add_token", default: 0]
            side.field.append(
                UnitState(
                    id: UUID(),
                    cardID: card.id,
                    attack: (card.attack ?? 0) + tokenBoost,
                    health: card.health ?? 1,
                    shield: 0,
                    taunt: card.params?["taunt"] == 1,
                    guardUnit: card.params?["guard"] == 1
                )
            )
        case .spell, .field:
            break
        }
    }

    func attack(attackerIndex: Int, attackerSide: inout BattleSideState, defenderSide: inout BattleSideState) {
        guard attackerSide.field.indices.contains(attackerIndex) else { return }
        var attacker = attackerSide.field[attackerIndex]
        let targetIndex = chooseTargetIndex(from: defenderSide.field)

        if let idx = targetIndex {
            var defender = defenderSide.field[idx]
            defender.health -= attacker.attack
            attacker.health -= defender.attack
            defenderSide.field[idx] = defender
            attackerSide.field[attackerIndex] = attacker
            defenderSide.field.removeAll { $0.health <= 0 }
            attackerSide.field.removeAll { $0.health <= 0 }
        } else {
            let bonus = attackerSide.fieldParams["attack_card_damage_barrier_bonus", default: 0]
            defenderSide.barrier -= max(0, attacker.attack + bonus)
            if defenderSide.barrier < 0 {
                defenderSide.leaderHP += defenderSide.barrier
                defenderSide.barrier = 0
            }
        }
    }

    private func chooseTargetIndex(from field: [UnitState]) -> Int? {
        if let idx = field.firstIndex(where: { $0.taunt }) { return idx }
        if let idx = field.firstIndex(where: { $0.guardUnit }) { return idx }
        return field.indices.randomElement()
    }

    private func applyStartTurn(to side: inout BattleSideState, enemy: inout BattleSideState) {
        side.maxMana = min(10, side.maxMana + 1)
        side.mana = side.maxMana
        side.barrier += side.fieldParams["start_of_turn_add_shield", default: 0]
        side.barrier += side.fieldParams["start_of_turn_heal_barrier", default: 0]

        let draws = 1 + side.fieldParams["self_bonus_draw_each_turn", default: 0]
        for _ in 0..<max(0, draws) {
            if let top = side.deck.first {
                side.hand.append(top)
                side.deck.removeFirst()
            }
        }

        if side.fieldParams["start_of_turn_seal_random_enemy_hand", default: 0] > 0, !enemy.hand.isEmpty {
            enemy.hand.removeLast()
        }

        let healBonus = side.fieldParams["heal_bonus", default: 0]
        side.leaderHP += healBonus

        let enemyHealingModifier = side.fieldParams["enemy_healing_modifier", default: 0]
        enemy.leaderHP -= enemyHealingModifier
    }
}
