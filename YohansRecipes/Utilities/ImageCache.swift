//
//  ImageCache.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import Foundation
import UIKit

actor ImageCache {
    static let shared = ImageCache()
    
    // Using NSCache for automatic memory management
    private var memoryCache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure memory cache https://stackoverflow.com/questions/18899762/when-does-nscache-release-the-caches-objects
        memoryCache.countLimit = 50
    }
    
    func getImage(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString
        return memoryCache.object(forKey: key)
    }
    
    func storeImage(_ image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        memoryCache.setObject(image, forKey: key)
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
    }
}
