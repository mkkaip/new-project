import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var data: GameData
    @Published private(set) var player: PlayerState
    @Published var selectedStageID: String?

    private let store: PlayerStateStoring
    private let gachaService: GachaService
    private let deckService = DeckService()
    private let exchangeService = ExchangeService()
    private let progressionService: ProgressionService
    private let dailyResetService: DailyResetService
    private lazy var pveService = PvEService(progression: progressionService)

    init(data: GameData, store: PlayerStateStoring = UserDefaultsPlayerStateStore()) {
        self.data = data
        self.store = store
        self.player = store.load()
        self.gachaService = GachaService()
        self.progressionService = ProgressionService(milestones: data.progression)
        self.dailyResetService = DailyResetService(progressionService: progressionService)
        refreshDailyIfNeeded()
    }

    func chooseStarter(id: String) {
        guard let starter = data.starterDecks.first(where: { $0.id == id }) else { return }
        deckService.applyStarter(starter, state: &player)
        persist()
    }

    func drawSingle() throws {
        _ = try gachaService.draw(tableID: "standard", count: 1, gameData: data, state: &player)
        persist()
    }

    func drawTen() throws {
        _ = try gachaService.draw(tableID: "standard", count: 10, gameData: data, state: &player)
        persist()
    }

    func exchangeSR(cardID: String) throws {
        try exchangeService.exchangeCard(cardID: cardID, rarity: .superRare, state: &player)
        persist()
    }

    func exchangeUR(cardID: String) throws {
        try exchangeService.exchangeCard(cardID: cardID, rarity: .ultraRare, state: &player)
        persist()
    }

    func exchangeSkin(cosmeticID: String) throws {
        guard let cosmetic = data.cosmetics.first(where: { $0.id == cosmeticID }) else { return }
        try exchangeService.exchangeEventSkin(cosmetic: cosmetic, state: &player)
        persist()
    }

    func clearSelectedStage() {
        guard let selectedStageID,
              let stage = data.stages.first(where: { $0.id == selectedStageID }) else { return }
        _ = pveService.clearStage(stage, state: &player)
        persist()
    }

    func refreshDailyIfNeeded() {
        dailyResetService.refreshIfNeeded(state: &player)
        persist()
    }

    private func persist() {
        store.save(player)
    }
}
