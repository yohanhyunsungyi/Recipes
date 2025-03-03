//
//  ImageCacheTests.swift
//  YohansRecipesTests
//
//  Created by Yohan Yi on 2/28/25.
//

import XCTest
@testable import YohansRecipes

final class ImageCacheTests: XCTestCase {
    
    private let testURL1 = URL(string: "https://testUrl.com/large1.jpg")!
    private let testURL2 = URL(string: "https://testUrl.com/large2.jpg")!
    
    private var testImage1: UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    private var testImage2: UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    override func setUp() async throws {
        await ImageCache.shared.clearCache()
    }
    
    // MARK: - Tests
    
    func testGetNonExistentImage() async {
        let cachedImage = await ImageCache.shared.getImage(for: testURL1)
        XCTAssertNil(cachedImage, "Cache should be nil")
    }
    
    func testStoreAndRetrieveImage() async {
        // Store an image in the cache
        let image = testImage1
        await ImageCache.shared.storeImage(image, for: testURL1)
        
        // Retrieve the image from cache
        let cachedImage = await ImageCache.shared.getImage(for: testURL1)
        
        XCTAssertNotNil(cachedImage, "Cached image should not be nil")
        
        if let cachedImage = cachedImage {
            let imageData = image.pngData()
            let cachedImageData = cachedImage.pngData()
            
            XCTAssertEqual(imageData, cachedImageData, "Cached should match original image")
        }
    }
    
    func testClearCache() async {
        // Store images in the cache
        await ImageCache.shared.storeImage(testImage1, for: testURL1)
        await ImageCache.shared.storeImage(testImage2, for: testURL2)
        
        // Clear the cache
        await ImageCache.shared.clearCache()
        
        let cachedImage1 = await ImageCache.shared.getImage(for: testURL1)
        let cachedImage2 = await ImageCache.shared.getImage(for: testURL2)
        
        XCTAssertNil(cachedImage1, "Cache should be nil after clearing")
        XCTAssertNil(cachedImage2, "Cache should be nil after clearing")
    }
    
    func testCacheOverrideWithSameURL() async {
        // Store image in the cache
        await ImageCache.shared.storeImage(testImage1, for: testURL1)
        
        // Store a different image with the same URL
        await ImageCache.shared.storeImage(testImage2, for: testURL1)
        
        // Retrieve the image from cache
        let cachedImage = await ImageCache.shared.getImage(for: testURL1)
        
        // The cached image should be the second image (testImage2)
        XCTAssertNotNil(cachedImage, "Cached should not be nil")
        
        if let cachedImage = cachedImage {
            let image2Data = testImage2.pngData()
            let cachedImageData = cachedImage.pngData()
            
            XCTAssertEqual(image2Data, cachedImageData, "Cached image should be the image2")
        }
    }
} 
