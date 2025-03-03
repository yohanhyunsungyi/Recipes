//
//  ImageLoader.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Image Loader

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let url: URL
    private var task: Task<Void, Never>?
    
    // Caching (localLoader) is efficient for sharing, but network requests (remoteLoader) are managed independently for each ImageLoader.
    private static let sharedLocalLoader = LocalImageLoader()
    private let remoteLoader = RemoteImageLoader()
    
    static func clearCache() async {
        await sharedLocalLoader.clearCache()
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func load() {
        cancelTask()
        
        // Don't reload if already loaded
        if image != nil { return }
        
        isLoading = true
        
        task = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                // Try local cache first
                if let cachedImage = await Self.sharedLocalLoader.loadImage(from: url) {
                    await MainActor.run {
                        self.image = cachedImage
                        self.isLoading = false
                    }
                    return
                }
                
                // If not in cache, fetch from network
                let loadedImage = try await remoteLoader.loadImage(from: url)
                
                // Store in local cache
                await Self.sharedLocalLoader.saveImage(loadedImage, for: url)
                
                await MainActor.run {
                    self.image = loadedImage
                    self.error = nil
                    self.isLoading = false
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.error = error
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
        isLoading = false
    }
    
    deinit {
        Task { @MainActor [weak self] in
            self?.cancelTask()
        }
    }
}
