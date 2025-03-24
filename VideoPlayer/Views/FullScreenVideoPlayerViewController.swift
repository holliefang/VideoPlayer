//
//  FullScreenVideoPlayerViewController.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/16.
//

import UIKit
import AVKit

class FullScreenVideoPlayerViewController: UIViewController {
    
    private let viewModel: VideoViewModel
    private lazy var playerView = PlayerView(viewModel: viewModel)
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerView)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleCloseButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
