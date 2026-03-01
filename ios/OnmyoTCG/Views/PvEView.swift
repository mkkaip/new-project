import SwiftUI

struct PvEView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.data.stages) { stage in
                VStack(alignment: .leading, spacing: 8) {
                    Text(stage.name).font(.headline)
                    Text("報酬: 霊石\(stage.rewardReishi) / 護符\(stage.rewardOfuda) / XP\(stage.rewardXP)")
                        .font(.caption)
                    Button("挑戦") {
                        viewModel.selectedStageID = stage.id
                        viewModel.clearSelectedStage()
                    }
                }
            }
            .navigationTitle("PvE")
            .toolbar {
                Text("PLv \(viewModel.player.level)  XP \(viewModel.player.xp)")
            }
        }
    }
}
