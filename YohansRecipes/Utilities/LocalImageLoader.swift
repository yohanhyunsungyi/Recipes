//
//  LocalImageLoader.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import Foundation
import UIKit

actor LocalImageLoader {
    private let cache: ImageCache
    
    init(cache: ImageCache = .shared) {
        self.cache = cache
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        return await cache.getImage(for: url)
    }
    
    func saveImage(_ image: UIImage, for url: URL) async {
        await cache.storeImage(image, for: url)
    }
    
    func clearCache() async {
        await cache.clearCache()
    }
} 
