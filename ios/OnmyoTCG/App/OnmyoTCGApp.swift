import SwiftUI

@main
struct OnmyoTCGApp: App {
    @StateObject private var viewModel: AppViewModel

    init() {
        let data: GameData
        do {
            data = try BundleDataService().loadGameData()
        } catch {
            data = GameData(cards: [], gachaTables: [], progression: [], stages: [], starterDecks: [], storeProducts: [], cosmetics: [])
        }
        _viewModel = StateObject(wrappedValue: AppViewModel(data: data))
    }

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}
