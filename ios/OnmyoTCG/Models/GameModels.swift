import Foundation

enum CardRarity: String, Codable, CaseIterable {
    case common = "C"
    case rare = "R"
    case superRare = "SR"
    case ultraRare = "UR"
}

enum CardType: String, Codable {
    case unit
    case spell
    case field
}

struct Card: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let rarity: CardRarity
    let type: CardType
    let cost: Int
    let attack: Int?
    let health: Int?
    let params: [String: Int]?
}

struct GachaTable: Codable {
    let id: String
    let rates: [String: Double]
    let poolByRarity: [String: [String]]
    let levelGate: Int
}

struct ProgressionMilestone: Codable {
    let level: Int
    let xpRequired: Int
    let freePacksPerDay: Int
}

struct PvEStage: Codable, Identifiable {
    let id: String
    let name: String
    let rewardReishi: Int
    let rewardOfuda: Int
    let rewardXP: Int
    let enemyDeckId: String
}

struct StarterDeck: Codable, Identifiable {
    let id: String
    let title: String
    let cards: [String]
}

struct StoreProduct: Codable, Identifiable {
    let id: String
    let title: String
    let kind: String
    let cost: Int
}

struct Cosmetic: Codable, Identifiable {
    let id: String
    let title: String
    let ofudaCost: Int
}

struct MonthlyPass: Codable, Equatable {
    enum Tier: String, Codable {
        case none
        case silver
        case gold

        var bonusTickets: Int {
            switch self {
            case .none: return 0
            case .silver: return 1
            case .gold: return 2
            }
        }
    }

    let tier: Tier
}

struct PityState: Codable, Equatable {
    var pullsSinceSR: Int
    var pullsSinceUR: Int

    static let `default` = PityState(pullsSinceSR: 0, pullsSinceUR: 0)
}

struct Deck: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var cardIDs: [String]
}

struct PlayerState: Codable, Equatable {
    var reishi: Int
    var ofuda: Int
    var ownedCounts: [String: Int]
    var decks: [Deck]
    var activeDeck: UUID?
    var xp: Int
    var level: Int
    var freePackTickets: Int
    var pity: PityState
    var starterChosen: Bool
    var monthlyPass: MonthlyPass
    var lastDailyResetJST: String

    static let `default` = PlayerState(
        reishi: 1200,
        ofuda: 0,
        ownedCounts: [:],
        decks: [],
        activeDeck: nil,
        xp: 0,
        level: 1,
        freePackTickets: 0,
        pity: .default,
        starterChosen: false,
        monthlyPass: MonthlyPass(tier: .none),
        lastDailyResetJST: "1970-01-01"
    )
}

struct GameData {
    let cards: [Card]
    let gachaTables: [GachaTable]
    let progression: [ProgressionMilestone]
    let stages: [PvEStage]
    let starterDecks: [StarterDeck]
    let storeProducts: [StoreProduct]
    let cosmetics: [Cosmetic]

    var cardMap: [String: Card] {
        Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) })
    }
}
