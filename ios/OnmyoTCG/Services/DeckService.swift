import Foundation

enum DeckError: Error {
    case invalidCardCount
}

final class DeckService {
    static let minDeckSize = 20
    static let maxCopiesPerCard = 3

    func validate(deck: Deck) throws {
        guard deck.cardIDs.count >= Self.minDeckSize else {
            throw DeckError.invalidCardCount
        }
        let grouped = Dictionary(grouping: deck.cardIDs, by: { $0 })
        let violates = grouped.contains { $0.value.count > Self.maxCopiesPerCard }
        if violates {
            throw DeckError.invalidCardCount
        }
    }

    func applyStarter(_ starter: StarterDeck, state: inout PlayerState) {
        guard !state.starterChosen else { return }
        let deck = Deck(id: UUID(), name: starter.title, cardIDs: starter.cards)
        state.decks.append(deck)
        state.activeDeck = deck.id
        for id in starter.cards {
            state.ownedCounts[id, default: 0] += 1
        }
        state.starterChosen = true
    }
}
