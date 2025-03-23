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
    
    
    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
