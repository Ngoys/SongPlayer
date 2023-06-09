import Foundation
import Combine
import MediaPlayer
import AVFoundation

class AudioPlayerService: NSObject, AudioPlayer {

    //----------------------------------------
    // MARK: - Initialization
    //----------------------------------------

    override init() {
        super.init()

        remoteCommandCenterManager = RemoteCommandCenterManager(audioPlayer: self)
        nowPlayingInfoCenterManager = NowPlayingInfoCenterManager(audioPlayer: self)
        
        basicAudioPlayer = BasicAudioPlayer(remoteCommandCenterManager: remoteCommandCenterManager,
                                            nowPlayingInfoCenterManager: nowPlayingInfoCenterManager)
        liveStreamAudioPlayer = LiveStreamAudioPlayer(remoteCommandCenterManager: remoteCommandCenterManager,
                                                      nowPlayingInfoCenterManager: nowPlayingInfoCenterManager)

        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        } catch {
            print("AudioPlayerService - Error setting audio session mode to playback - \(error)")
        }

        //----------------------------------------
        // MARK: - Start observing data
        //----------------------------------------

        currentAudioPlayerSubject.sink { currentAudioPlayer in
            guard let currentAudioPlayer = currentAudioPlayer else { return }

            currentAudioPlayer.audioPlayerStateDidChangePublisher.sink { audioPlayer in
                guard let audioPlayer = audioPlayer else { return }

                self.audioPlayerStateDidChangeSubject.send(audioPlayer)
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)
    }

    //----------------------------------------
    // MARK: - Properties
    //----------------------------------------

    private let audioPlayerStateDidChangeSubject = CurrentValueSubject<AudioPlayer?, Never>(nil)
    var audioPlayerStateDidChangePublisher: AnyPublisher<AudioPlayer?, Never> {
        return audioPlayerStateDidChangeSubject.eraseToAnyPublisher()
    }

    var isPlaying: Bool {
        return currentAudioPlayer?.isPlaying ?? false
    }

    var isLoading: Bool {
        return currentAudioPlayer?.isLoading ?? false
    }

    var currentAudioContent: AudioContent? {
        get {
            return currentAudioPlayer?.currentAudioContent
        }
        set {
            switch newValue?.audioContentType {
            case .audioClip:
                if let currentAudioPlayer = currentAudioPlayer,
                   currentAudioPlayer !== basicAudioPlayer {
                    currentAudioPlayer.reset()
                }

                currentAudioPlayer = basicAudioPlayer
                basicAudioPlayer.currentAudioContent = newValue

            case .livestream:
                // Future expansion
                if let currentAudioPlayer = currentAudioPlayer,
                   currentAudioPlayer !== liveStreamAudioPlayer {
                    currentAudioPlayer.reset()
                }

                currentAudioPlayer = liveStreamAudioPlayer
                liveStreamAudioPlayer.currentAudioContent = newValue

            case .none:
                break
            }
        }
    }

    var currentTime: TimeInterval {
        get {
            return currentAudioPlayer?.currentTime ?? 0.0
        }

        set {
            currentAudioPlayer?.currentTime = newValue
        }
    }

    //----------------------------------------
    // MARK: - Actions
    //----------------------------------------

    func play(seekTime: Double?) {
        setAudioSession(true)
        currentAudioPlayer?.play(seekTime: seekTime)
    }

    func pause(forceDispose: Bool = false) {
        if self.isPlaying {
            setAudioSession(false)
            currentAudioPlayer?.pause(forceDispose: forceDispose)
        }
    }

    func reset() {
        currentAudioContent = nil
        currentAudioPlayer?.reset()
    }
    
    private func setAudioSession(_ active: Bool) {
        DispatchQueue.global(qos: .background).async {
            // Need to be in the background thread to prevent UI lags on the main thread
            try? self.audioSession.setActive(active)
        }
    }
    
    //----------------------------------------
    // MARK: - Internals
    //----------------------------------------

    private var currentAudioPlayer: AudioPlayer? {
        didSet {
            currentAudioPlayerSubject.send(currentAudioPlayer)
        }
    }

    private var basicAudioPlayer: BasicAudioPlayer!

    private var liveStreamAudioPlayer: LiveStreamAudioPlayer!

    private let currentAudioPlayerSubject = CurrentValueSubject<AudioPlayer?, Never>(nil)

    private var remoteCommandCenterManager: RemoteCommandCenterManager!

    private var nowPlayingInfoCenterManager: NowPlayingInfoCenterManager!

    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()

    private var cancellables: Set<AnyCancellable> = Set()
}
