import Foundation

enum GachaError: Error {
    case levelGate(levelRequired: Int)
    case notEnoughCurrency
    case tableMissing
}

struct GachaResult {
    let obtainedCardIDs: [String]
    let spentReishi: Int
    let spentTickets: Int
}

final class GachaService {
    private let rng: () -> Double

    init(rng: @escaping () -> Double = { Double.random(in: 0..<1) }) {
        self.rng = rng
    }

    func draw(
        tableID: String,
        count: Int,
        gameData: GameData,
        state: inout PlayerState
    ) throws -> GachaResult {
        guard let table = gameData.gachaTables.first(where: { $0.id == tableID }) else {
            throw GachaError.tableMissing
        }
        guard state.level >= table.levelGate else {
            throw GachaError.levelGate(levelRequired: table.levelGate)
        }

        let reishiCost = calculateReishiCost(count: count, tickets: state.freePackTickets)
        let neededTickets = min(count, state.freePackTickets)
        guard state.reishi >= reishiCost else {
            throw GachaError.notEnoughCurrency
        }

        state.reishi -= reishiCost
        state.freePackTickets -= neededTickets

        var obtained: [String] = []
        for _ in 0..<count {
            let rarity = rollRarity(table: table, pity: &state.pity)
            let key = rarity.rawValue
            if let pool = table.poolByRarity[key], let picked = pool.randomElement() {
                obtained.append(picked)
                state.ownedCounts[picked, default: 0] += 1
            }
        }

        return GachaResult(obtainedCardIDs: obtained, spentReishi: reishiCost, spentTickets: neededTickets)
    }

    private func calculateReishiCost(count: Int, tickets: Int) -> Int {
        if count == 10 {
            if tickets >= 10 { return 0 }
            return 980
        }
        let paidSingles = max(0, count - tickets)
        return paidSingles * 160
    }

    private func rollRarity(table: GachaTable, pity: inout PityState) -> CardRarity {
        pity.pullsSinceSR += 1
        pity.pullsSinceUR += 1

        if pity.pullsSinceUR >= 90 {
            pity.pullsSinceUR = 0
            pity.pullsSinceSR = 0
            return .ultraRare
        }

        if pity.pullsSinceSR >= 10 {
            pity.pullsSinceSR = 0
            return .superRare
        }

        let roll = rng()
        var cumulative = 0.0
        for rarity in CardRarity.allCases {
            cumulative += table.rates[rarity.rawValue] ?? 0
            if roll <= cumulative {
                if rarity == .ultraRare {
                    pity.pullsSinceUR = 0
                    pity.pullsSinceSR = 0
                } else if rarity == .superRare {
                    pity.pullsSinceSR = 0
                }
                return rarity
            }
        }
        return .common
    }
}
