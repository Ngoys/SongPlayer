import Foundation
import Combine

class SongListViewModel: StatefulViewModel<[Song]> {

    //----------------------------------------
    // MARK: - Initialization
    //----------------------------------------

    init(songStore: SongStore) {
        self.songStore = songStore
    }

    //----------------------------------------
    // MARK: - Actions
    //----------------------------------------

    override func load() -> AnyPublisher<[Song], Error> {
        print("SongListViewModel - fetchSongs()")
        return songStore.fetchSongs()
    }

    //----------------------------------------
    // MARK: - Internals
    //----------------------------------------

    private let songStore: SongStore
}
