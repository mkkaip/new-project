import XCTest
@testable import OnmyoTCGCore

final class CoreLogicTests: XCTestCase {
    private func fixtureData(levelGate: Int = 1) -> GameData {
        let card = Card(id: "c", name: "c", rarity: .common, type: .unit, cost: 1, attack: 1, health: 1, params: [:])
        let sr = Card(id: "sr", name: "sr", rarity: .superRare, type: .unit, cost: 2, attack: 2, health: 2, params: [:])
        let ur = Card(id: "ur", name: "ur", rarity: .ultraRare, type: .unit, cost: 3, attack: 3, health: 3, params: [:])
        let table = GachaTable(
            id: "standard",
            rates: ["C": 1.0, "SR": 0, "UR": 0],
            poolByRarity: ["C": ["c"], "SR": ["sr"], "UR": ["ur"]],
            levelGate: levelGate
        )
        let progression = [
            ProgressionMilestone(level: 1, xpRequired: 0, freePacksPerDay: 1),
            ProgressionMilestone(level: 2, xpRequired: 100, freePacksPerDay: 2)
        ]
        return GameData(
            cards: [card, sr, ur],
            gachaTables: [table],
            progression: progression,
            stages: [],
            starterDecks: [],
            storeProducts: [],
            cosmetics: []
        )
    }

    func testGachaPityGuaranteesSRAtTen() throws {
        let service = GachaService(rng: { 0.1 })
        var state = PlayerState.default
        state.reishi = 10_000
        let data = fixtureData()

        _ = try service.draw(tableID: "standard", count: 10, gameData: data, state: &state)

        XCTAssertEqual(state.ownedCounts["sr"], 1)
    }

    func testGachaGateByLevel() {
        let service = GachaService(rng: { 0.1 })
        var state = PlayerState.default
        state.level = 1
        let data = fixtureData(levelGate: 2)

        XCTAssertThrowsError(try service.draw(tableID: "standard", count: 1, gameData: data, state: &state))
    }

    func testDailyResetAddsTicketsWithMonthlyPassBonus() {
        let progression = ProgressionService(milestones: [
            ProgressionMilestone(level: 1, xpRequired: 0, freePacksPerDay: 1),
            ProgressionMilestone(level: 3, xpRequired: 200, freePacksPerDay: 2)
        ])
        let reset = DailyResetService(
            progressionService: progression,
            nowProvider: { Date(timeIntervalSince1970: 1_700_000_000) }
        )
        var state = PlayerState.default
        state.level = 3
        state.monthlyPass = MonthlyPass(tier: .gold)

        reset.refreshIfNeeded(state: &state)

        XCTAssertEqual(state.freePackTickets, 4)
    }

    func testDeckRuleMaxThreeCopiesAndMinimumTwenty() {
        let service = DeckService()
        let valid = Deck(id: UUID(), name: "valid", cardIDs: Array(repeating: "a", count: 3) + Array(repeating: "b", count: 3) + Array(repeating: "c", count: 3) + Array(repeating: "d", count: 3) + Array(repeating: "e", count: 3) + Array(repeating: "f", count: 3) + ["g", "h"])
        XCTAssertNoThrow(try service.validate(deck: valid))

        let invalid = Deck(id: UUID(), name: "invalid", cardIDs: Array(repeating: "a", count: 4) + Array(repeating: "b", count: 16))
        XCTAssertThrowsError(try service.validate(deck: invalid))
    }

    func testUnitCombatTauntPriorityAndCounterAttack() {
        let combat = CombatService()
        var attacker = BattleSideState(hand: [], deck: [], field: [UnitState(id: UUID(), cardID: "atk", attack: 4, health: 5, shield: 0, taunt: false, guardUnit: false)], leaderHP: 20, barrier: 0, maxMana: 0, mana: 0, fieldParams: [:])
        var defender = BattleSideState(hand: [], deck: [], field: [
            UnitState(id: UUID(), cardID: "normal", attack: 1, health: 6, shield: 0, taunt: false, guardUnit: false),
            UnitState(id: UUID(), cardID: "taunt", attack: 2, health: 3, shield: 0, taunt: true, guardUnit: false)
        ], leaderHP: 20, barrier: 0, maxMana: 0, mana: 0, fieldParams: [:])

        combat.attack(attackerIndex: 0, attackerSide: &attacker, defenderSide: &defender)

        XCTAssertEqual(defender.field.count, 1)
        XCTAssertEqual(defender.field.first?.cardID, "normal")
        XCTAssertEqual(attacker.field.first?.health, 3)
    }
}
