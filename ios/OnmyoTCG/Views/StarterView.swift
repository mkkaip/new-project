import SwiftUI

struct StarterView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.data.starterDecks) { starter in
                VStack(alignment: .leading) {
                    Text(starter.title).font(.headline)
                    Text("枚数: \(starter.cards.count)")
                    Button("このスターターを選択") {
                        viewModel.chooseStarter(id: starter.id)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.player.starterChosen)
                }
            }
            .navigationTitle("Starter Deck")
        }
    }
}
