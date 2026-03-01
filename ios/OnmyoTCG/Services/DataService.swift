import Foundation

protocol DataLoading {
    func loadGameData() throws -> GameData
}

enum DataServiceError: Error {
    case missingFile(String)
}

final class BundleDataService: DataLoading {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func loadGameData() throws -> GameData {
        GameData(
            cards: try load("cards"),
            gachaTables: try load("gacha_tables"),
            progression: try load("progression"),
            stages: try load("pve_stages"),
            starterDecks: try load("starter_decks"),
            storeProducts: try load("store_products"),
            cosmetics: try load("cosmetics")
        )
    }

    private func load<T: Decodable>(_ fileName: String) throws -> T {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw DataServiceError.missingFile(fileName)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

final class FileDataService: DataLoading {
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func loadGameData() throws -> GameData {
        GameData(
            cards: try load("cards"),
            gachaTables: try load("gacha_tables"),
            progression: try load("progression"),
            stages: try load("pve_stages"),
            starterDecks: try load("starter_decks"),
            storeProducts: try load("store_products"),
            cosmetics: try load("cosmetics")
        )
    }

    private func load<T: Decodable>(_ fileName: String) throws -> T {
        let url = baseURL.appendingPathComponent("\(fileName).json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
