import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        TabView {
            StarterView(viewModel: viewModel)
                .tabItem { Label("Starter", systemImage: "sparkles") }
            GachaView(viewModel: viewModel)
                .tabItem { Label("Gacha", systemImage: "shippingbox") }
            ExchangeView(viewModel: viewModel)
                .tabItem { Label("Exchange", systemImage: "arrow.left.arrow.right") }
            PvEView(viewModel: viewModel)
                .tabItem { Label("PvE", systemImage: "flag") }
        }
    }
}
