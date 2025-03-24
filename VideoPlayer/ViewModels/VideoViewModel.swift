//
//  VideoViewModel.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/19.
//
import AVFoundation
import Combine

class VideoViewModel {
    
    enum Status {
        case readyToPlay
        case failed
    }
    
    private let videoURLStorage: LocalStorage
    private var subscriptions = Set<AnyCancellable>()
    private var timeObserver: Any?

    @Published var status: Status?
    @Published var durationText: String = "--:--"
    @Published var currentTimeText: String = "--:--"
    @Published var progress: Float = 0
    private var duration: Double {
        return player.currentItem?.duration.seconds ?? 0
    }
    @Published var isPlaying = false
    let player = AVPlayer()
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter
    }()
    
    init(storage: LocalStorage) {
        self.videoURLStorage = storage
    }
    
    deinit {
        removeTimeObserver()
    }
    
    func load(from url: URL) {
        subscriptions.removeAll()
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [.duration])
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.durationText = getDurationText(CMTimeGetSeconds(playerItem.duration))
                    self.status = .readyToPlay
                    self.videoURLStorage.save(url: url)
                case .failed:
                    self.status = .failed
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
        player.replaceCurrentItem(with: playerItem)
                
        player.publisher(for: \.timeControlStatus)
            .removeDuplicates()
            .throttle(for: .seconds(0.45), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] status in
                self?.isPlaying = (status == .playing)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    func play() {
        player.play()
        addTimeObserver()
    }
    
    func pause() {
        player.pause()
        removeTimeObserver()
    }
    
    @objc private func videoDidFinishPlaying() {
        player.seek(to: .zero)
    }
    
    func seek(to seconds: Float)  {
        player.pause()
        let time = CMTime(seconds: Double(seconds) * duration, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] finished in
            if finished {
                self?.player.play()
            }
        }
    }
    
    private func removeTimeObserver() {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
    }
    
    private func addTimeObserver() {
        guard timeObserver == nil else { return }
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self,
                  self.duration > 0 else { return }
            let seconds = CMTimeGetSeconds(time)
            let minutes = Int(seconds) / 60
            let secs = Int(seconds) % 60
            self.currentTimeText = String(format: "%02d:%02d", minutes, secs)
            self.progress = Float(seconds / duration)
        }
    }

    private func getDurationText(_ seconds: Double) -> String {
        let date = Date(timeIntervalSince1970: seconds)
        return VideoViewModel.dateFormatter.string(from: date)
    }
}
