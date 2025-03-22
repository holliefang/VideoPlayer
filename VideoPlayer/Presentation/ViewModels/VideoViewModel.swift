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
    
    private let loader: VideoLoader
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
    
    init(loader: VideoLoader) {
        self.loader = loader
    }
    
    func load(from url: URL) {
        subscriptions.removeAll()
        
        let playerItem = loader.loadItem(from: url)
        playerItem.publisher(for: \.status)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.durationText = getDurationText(CMTimeGetSeconds(playerItem.duration))
                    self.status = .readyToPlay
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
        
        removeTimeObserver()
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self,
                  self.duration > 0 else { return }
            let seconds = CMTimeGetSeconds(time)
            let minutes = Int(seconds) / 60
            let secs = Int(seconds) % 60
            self.currentTimeText = String(format: "%02d:%02d", minutes, secs)
            self.progress = Float(seconds / duration)
        }
        
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
    }
    
    func pause() {
        player.pause()
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

    private func getDurationText(_ seconds: Double) -> String {
        let date = Date(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return dateFormatter.string(from: date)
    }
}
