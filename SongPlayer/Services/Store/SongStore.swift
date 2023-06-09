import Foundation
import Combine

class SongStore: BaseStore {

    //----------------------------------------
    // MARK: - Initialization
    //----------------------------------------

    init(apiClient: APIClient, coreDataStore: CoreDataStore) {
        self.apiClient = apiClient
        self.coreDataStore = coreDataStore
    }

    //----------------------------------------
    // MARK: - Actions
    //----------------------------------------

    func fetchSongs() -> AnyPublisher<[Song], Error> {
        let endPoint = "Lenhador/a0cf9ef19cd816332435316a2369bc00/raw/a1338834fc60f7513402a569af09ffa302a26b63/Songs.json"

        let publisher = apiClient.apiRequest(.get, endPoint)
            .tryMap { apiResponse -> [Song] in
                let decodedModel = try self.decoder.decode(SongPlayerAPIJSON<[Song]>.self, from: apiResponse.data)
                return decodedModel.data
            }
            .map { [weak self] fetchedSongs in
                guard let self = self else { return fetchedSongs }
            
                let offlineSongs = self.coreDataStore.fetchAllSongs()

                // Save fetched songs to Core Data
                fetchedSongs.forEach { song in
                    // If the song is downloaded previously and stored in Core Data,
                    // We will update the localFilePath,
                    // and change the status to .canPlay to update theSongView's UI
                    if let offlineSongs = offlineSongs.first(where: { $0.id == song.id && $0.localFilePath != nil }) {
                        song.localFilePath = offlineSongs.localFilePath
                    }
                    if offlineSongs.contains(song) == false {
                        self.coreDataStore.createOrUpdateSong(song: song)
                    }
                }

                return fetchedSongs
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return publisher
    }

    //----------------------------------------
    // MARK: - Internals
    //----------------------------------------

    private let apiClient: APIClient

    private let coreDataStore: CoreDataStore
}
