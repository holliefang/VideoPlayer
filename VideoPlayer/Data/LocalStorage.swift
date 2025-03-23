//
//  VideoLoader.swift
//  VideoPlayer
//
//  Created by 方思涵 on 2025/3/19.
//

import AVFoundation

protocol LocalStorage {
    func save(url: URL)
    func retrieve() -> [URL]
}
