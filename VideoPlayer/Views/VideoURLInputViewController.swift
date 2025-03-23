//
//  VideoURLInputViewController.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/16.
//

import UIKit


class VideoURLInputViewController: UIViewController, PlayerViewDelegate {
    
    // MARK: - Properties
    private let viewModel: VideoViewModel
    var fullScreenPresentingController: UIViewController? {
        return self
    }
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let urlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入影片網址..."
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private lazy var playerView = PlayerView(viewModel: viewModel)
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setTitle("播放", for: .normal)
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: Life Cycles
    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        scrollView.showsVerticalScrollIndicator = false
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(urlTextField)
        scrollView.addSubview(playButton)
        scrollView.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            urlTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            urlTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            playButton.leadingAnchor.constraint(equalTo: urlTextField.leadingAnchor),
            playButton.trailingAnchor.constraint(equalTo: urlTextField.trailingAnchor),
            playButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            
            playerView.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playerView.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 9 / 16),
            
            playerView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: scrollView.bottomAnchor, multiplier: 0.2)
        ])
        
        playButton.layer.cornerRadius = 4
        playerView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.pause()
    }
    
    @objc private func playButtonTapped() {
        guard let urlString = urlTextField.text, let url = URL(string: urlString) else {
            let alert = UIAlertController(title: "網址格式錯誤", message: "請檢查輸入網址", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確認", style: .cancel))
            present(alert, animated: true)
            return
        }
        playerView.load(url)
    }
    
}
