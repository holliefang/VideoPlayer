//
//  PlayerControlView.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/18.
//

import UIKit
import AVFoundation

protocol PlayerControlDelegate: AnyObject {
    func didTogglePlay()
    func didSlideSeek(to value: Float)
}

class PlayerControlView: UIView {
    
    weak var delegate: PlayerControlDelegate?
    
    private let stackView = UIStackView()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .selected)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        return button
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .lightGray
        slider.addTarget(self, action: #selector(didSlideSeek), for: .valueChanged)
        slider.setThumbImage(createCircleImage(diameter: 16, color: .white), for: .normal)
        return slider
    }()
    
    private let separator = UIView()
    private let durationLabel = UILabel()
    private let currentTimeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        backgroundColor = .black.withAlphaComponent(0.7)
        durationLabel.font = .systemFont(ofSize: 12, weight: .black)
        durationLabel.textColor = .white
        currentTimeLabel.font = .systemFont(ofSize: 12, weight: .black)
        currentTimeLabel.textColor = .systemGreen
        separator.backgroundColor = .lightGray
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(playButton)
        addSubview(slider)
        addSubview(currentTimeLabel)
        addSubview(durationLabel)
        addSubview(separator)
        
        durationLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        currentTimeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            slider.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 4),
            slider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            playButton.topAnchor.constraint(equalTo: topAnchor),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            durationLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            durationLabel.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 2),
            currentTimeLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: currentTimeLabel.leadingAnchor, constant: -8),
            separator.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 2),
            separator.heightAnchor.constraint(equalToConstant: 8),
            separator.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            separator.widthAnchor.constraint(equalToConstant: 2),
        ])
    }
    
    @objc private func didTapPlayPause() {
        delegate?.didTogglePlay()
    }
    
    @objc private func didSlideSeek() {
        delegate?.didSlideSeek(to: slider.value)
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        playButton.isSelected = isPlaying
    }
    
    func updateSlider(maxValue: Float, currentTime: Float) {
        slider.maximumValue = maxValue
        slider.value = currentTime
    }
    
    func setDuration(_ text: String) {
        durationLabel.text = text
    }
    
    func setCurrentTime(_ text: String) {
        currentTimeLabel.text = text
    }
    
    func createCircleImage(diameter: CGFloat, color: UIColor) -> UIImage? {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            context.cgContext.fillEllipse(in: rect)
        }
        return image
    }
}

