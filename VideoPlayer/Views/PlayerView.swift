//
//  PlayerView.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/19.
//

import UIKit
import AVFoundation
import Combine

protocol PlayerViewDelegate: AnyObject {
    var fullScreenPresentingController: UIViewController? { get }
}

class PlayerView: UIView {
    
    // MARK: - Properties
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    private var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    private var url: URL?
    private let viewModel: VideoViewModel
    private var cancellable = Set<AnyCancellable>()
    weak var delegate: PlayerViewDelegate?
    
    // MARK: - UI
    private lazy var playerControlView: PlayerControlView = {
        let view = PlayerControlView()
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var retryButton: UIButton = {
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("重試", for: .normal)
        retryButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return retryButton
    }()
    
    private lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleGestureTapped))
        gesture.numberOfTapsRequired = 1
        return gesture
    }()
    private lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleGestureTapped))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    // MARK: - Life Cycles
    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        backgroundColor = .black
        playerLayer.player = viewModel.player
        
        addSubview(loadingIndicator)
        addSubview(playerControlView)
        addSubview(retryButton)
   
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        playerControlView.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playerControlView.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerControlView.trailingAnchor.constraint(equalTo: trailingAnchor),
            playerControlView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addGestureRecognizer(singleTapGesture)
        addGestureRecognizer(doubleTapGesture)
        
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.loadingIndicator.stopAnimating()
                    self.playVideo()
                case .failed:
                    self.loadingIndicator.stopAnimating()
                case .none:
                    break
                }
                self.retryButton.isHidden = status != .failed
            }
            .store(in: &cancellable)
        
        viewModel.$durationText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                self?.playerControlView.setDuration(duration)
            }
            .store(in: &cancellable)
        
        viewModel.$currentTimeText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentTime in
                self?.playerControlView.setCurrentTime(currentTime)
            }
            .store(in: &cancellable)
        
        viewModel.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.playerControlView.updatePlayPauseButton(isPlaying: isPlaying)
            }
            .store(in: &cancellable)
        
        viewModel.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.playerControlView.updateSlider(maxValue: 1, currentTime: progress)
            }
            .store(in: &cancellable)
    }
    
    @objc func handleSingleGestureTapped(_ sender: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: { [self] in
            playerControlView.alpha = playerControlView.isHidden ? 1 : 0
        }) { [self] _ in
            playerControlView.isHidden = !playerControlView.isHidden
        }
    }
    
    @objc func handleDoubleGestureTapped(_ sender: UIGestureRecognizer) {
        let controller = FullScreenVideoPlayerViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .crossDissolve
        delegate?.fullScreenPresentingController?.present(controller, animated: true)
    }
    
    func load(_ url: URL) {
        self.url = url
        loadingIndicator.startAnimating()
        viewModel.load(from: url)
    }
    
    private func playVideo() {
        viewModel.play()
    }
    
    private func pauseVideo() {
        viewModel.pause()
    }
    
    @objc private func retryButtonTapped() {
        guard let url else { return }
        load(url)
    }
}

extension PlayerView: PlayerControlDelegate {
    func didTogglePlay() {
        viewModel.isPlaying ? pauseVideo() : playVideo()
    }
    
    func didSlideSeek(to value: Float) {
        viewModel.seek(to: value)
    }
}
