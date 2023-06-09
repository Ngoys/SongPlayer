import Foundation

// Since the SongView UI will only show 1 of these 4 statues at a time,
// I will combine all of the statues into one enum, SongStatus
// This SongStatus will be used to show/hide the buttons
enum SongStatus: Equatable {
    case canPlay
    case canPause
    case canDownload
    case isDownloading(progress: Double)
}
