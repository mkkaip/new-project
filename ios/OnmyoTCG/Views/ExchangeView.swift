import SwiftUI

struct ExchangeView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 8) {
            Text("護符: \(viewModel.player.ofuda)")
            Button("SR指定交換 (120)") {
                do { try viewModel.exchangeSR(cardID: "sr_001"); errorText = nil }
                catch { errorText = String(describing: error) }
            }
            .buttonStyle(.borderedProminent)

            Button("UR指定交換 (450)") {
                do { try viewModel.exchangeUR(cardID: "ur_001"); errorText = nil }
                catch { errorText = String(describing: error) }
            }
            .buttonStyle(.bordered)

            Button("イベントスキン交換 (600)") {
                do { try viewModel.exchangeSkin(cosmeticID: "skin_event_001"); errorText = nil }
                catch { errorText = String(describing: error) }
            }
            .buttonStyle(.bordered)

            if let errorText {
                Text(errorText).foregroundStyle(.red)
            }
            Spacer()
        }
        .padding()
    }
}
