//
//  URLHistoryViewController.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/23.
//

import UIKit

class URLHistoryViewController: UIViewController {
    
    // MARK: - Properties
    private var videoURLs: [URL] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    // MARK: - UI
    private let tableView = UITableView()
    private let storage: LocalStorage
    
    // MARK: - Life Cycles
    init(storage: LocalStorage) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoURLs = storage.retrieve()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Video URL History"
        setupUI()
    }
    
    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension URLHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videoURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let videoURL = videoURLs[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = videoURL.absoluteString
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = VideoViewModel(storage: storage)
        let controller = FullScreenVideoPlayerViewController(viewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .crossDissolve
        let videoURL = videoURLs[indexPath.row]
        viewModel.load(from: videoURL)
        present(controller, animated: true)
    }
}
