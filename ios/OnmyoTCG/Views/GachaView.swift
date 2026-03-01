import SwiftUI

struct GachaView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("霊石: \(viewModel.player.reishi) / 無料チケット: \(viewModel.player.freePackTickets)")
            Text("Pity SR: \(viewModel.player.pity.pullsSinceSR)/10, UR: \(viewModel.player.pity.pullsSinceUR)/90")
            VStack(alignment: .leading) {
                Text("提供割合")
                Text("C 70% / R 20% / SR 9% / UR 1%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Button("1連") {
                    do { try viewModel.drawSingle(); errorText = nil }
                    catch { errorText = String(describing: error) }
                }
                .buttonStyle(.borderedProminent)

                Button("10連") {
                    do { try viewModel.drawTen(); errorText = nil }
                    catch { errorText = String(describing: error) }
                }
                .buttonStyle(.bordered)
            }
            if let errorText {
                Text(errorText).foregroundStyle(.red)
            }
            Spacer()
        }
        .padding()
    }
}
