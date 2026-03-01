import Foundation

enum ExchangeError: Error {
    case insufficientOfuda
}

final class ExchangeService {
    func exchangeCard(cardID: String, rarity: CardRarity, state: inout PlayerState) throws {
        let cost: Int
        switch rarity {
        case .superRare:
            cost = 120
        case .ultraRare:
            cost = 450
        default:
            cost = 0
        }
        guard state.ofuda >= cost else { throw ExchangeError.insufficientOfuda }
        state.ofuda -= cost
        state.ownedCounts[cardID, default: 0] += 1
    }

    func exchangeEventSkin(cosmetic: Cosmetic, state: inout PlayerState) throws {
        guard state.ofuda >= cosmetic.ofudaCost else { throw ExchangeError.insufficientOfuda }
        state.ofuda -= cosmetic.ofudaCost
    }
}
