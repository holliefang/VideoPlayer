//
//  LocalVideoLoader.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/19.
//

import Foundation

class UserDefaultStorage: LocalStorage {
    
    private let key = "url.history"
    
    func save(url: URL) {
        var urlStrings = savedURLStrings()
        urlStrings.append(url.absoluteString)
        UserDefaults.standard.set(urlStrings, forKey: key)
    }
    
    private func savedURLStrings() -> [String] {
        return Array(Set(UserDefaults.standard.array(forKey: key) as? [String] ?? []))
    }
    
    func retrieve() -> [URL] {
        let urlStrings = savedURLStrings()
        let urls = urlStrings.compactMap{ URL(string: $0) }
        return urls
    }
}
