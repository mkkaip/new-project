import Foundation

protocol PlayerStateStoring {
    func load() -> PlayerState
    func save(_ state: PlayerState)
}

final class UserDefaultsPlayerStateStore: PlayerStateStoring {
    private let defaults: UserDefaults
    private let key = "onmyo.player.state"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> PlayerState {
        guard let data = defaults.data(forKey: key),
              let state = try? JSONDecoder().decode(PlayerState.self, from: data) else {
            return .default
        }
        return state
    }

    func save(_ state: PlayerState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}

final class InMemoryPlayerStateStore: PlayerStateStoring {
    var value: PlayerState

    init(initial: PlayerState = .default) {
        value = initial
    }

    func load() -> PlayerState {
        value
    }

    func save(_ state: PlayerState) {
        value = state
    }
}
