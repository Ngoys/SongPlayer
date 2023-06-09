import Foundation
import CoreData

class CoreDataStore {

    //----------------------------------------
    // MARK: - Initialization
    //----------------------------------------

    init(coreDataStack: CoreDataStack) {
        self.mainContext = coreDataStack.mainContext
        self.backgroundContext = coreDataStack.backgroundContext
    }

    //----------------------------------------
    // MARK: - Actions
    //----------------------------------------

    func createOrUpdateSong(song: Song) {
        var currentSongDataModal: SongDataModal?
        let fetchRequest = SongDataModal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", song.id)

        backgroundContext.performAndWait {
            do {
                let results = try self.backgroundContext.fetch(fetchRequest)

                if results.isEmpty {
                    currentSongDataModal = SongDataModal(context: self.backgroundContext)
                } else {
                    currentSongDataModal = results.first
                }

                currentSongDataModal?.id = song.id
                currentSongDataModal?.name = song.name
                currentSongDataModal?.audioURL = song.audioURL
                currentSongDataModal?.localFilePath = song.localFilePath

                print("CoreDataStore - createOrUpdateSong(id: \(song.id))")
                self.saveInBackgroundContext()
            } catch {
                print("CoreDataStore - createOrUpdateSong() - Error \(error)")
            }
        }
    }

    func fetchAllSongs() -> [Song] {
        do {
            let fetchRequest = SongDataModal.fetchRequest()
            let results = try mainContext.fetch(fetchRequest)
            print("CoreDataStore - fetchAllSongs() - \(results.map{ $0.id } )")
            return results.map { $0.toSong() }
        } catch {
            print("CoreDataStore - fetchAllSongs() - Error \(error)")
            return []
        }
    }

    func updateSongLocalFilePath(id: String, localFilePath: String) {
        var currentSongDataModal: SongDataModal?
        let fetchRequest = SongDataModal.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        backgroundContext.performAndWait {
            do {
                let results = try self.backgroundContext.fetch(fetchRequest)

                guard let result = results.first else { return }

                currentSongDataModal = result
                currentSongDataModal?.localFilePath = localFilePath

                print("CoreDataStore - updateSongLocalFilePath(id: \(id), localFilePath: \(localFilePath))")
                self.saveInBackgroundContext()
            } catch {
                print("CoreDataStore - updateSongLocalFilePath(id: \(id)) - Error \(error)")
            }
        }
    }

    func deleteAllSongs() {
        let fetchRequest = SongDataModal.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            results.forEach { result in
                backgroundContext.delete(result)
            }

            print("CoreDataStore - deleteAllSongs()")
            self.saveInBackgroundContext()
        } catch {
            print("CoreDataStore - deleteAllSongs() - Error \(error)")
        }
    }

    func saveInMainContext() {
        guard mainContext.hasChanges else { return }
        do {
            try mainContext.save()
        } catch {
            mainContext.rollback()
            print("CoreDataStore - saveInMainContext() - Error \(error)")
        }
    }

    func saveInBackgroundContext() {
        guard backgroundContext.hasChanges else { return }
        do {
            try backgroundContext.save()
        } catch {
            backgroundContext.rollback()
            print("CoreDataStore - saveInBackgroundContext() - Error \(error)")
        }
    }

    //----------------------------------------
    // MARK: - Internals
    //----------------------------------------

    private let mainContext: NSManagedObjectContext

    private let backgroundContext: NSManagedObjectContext
}
