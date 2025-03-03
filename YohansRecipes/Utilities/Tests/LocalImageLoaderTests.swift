//
//  LocalImageLoaderTests.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import XCTest
@testable import YohansRecipes

final class LocalImageLoaderTests: XCTestCase {
        
    var testURL: URL!
    var mockImage: UIImage!
    var loader: LocalImageLoader!
        
    override func setUp() async throws {
        try await super.setUp()
            
        testURL = URL(string: "https://testUrl.com/large.jpg")!
        mockImage = {
            UIGraphicsBeginImageContext(CGSize(width: 100, height: 100))
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(UIColor.red.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }()
        loader = LocalImageLoader()
    }
    
    override func tearDown() async throws {
        try await loader.clearCache()
        testURL = nil
        mockImage = nil
        loader = nil
        try await super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSaveAndLoadImage() async throws {
        try await loader.saveImage(mockImage, for: testURL)
        
        let loadedImage = try await loader.loadImage(from: testURL)
        
        XCTAssertNotNil(loadedImage, "Retrieve the image from cache Successfully")
    }
    
    func testLoadImageNotInCache() async throws {
        let loadedImage = try await loader.loadImage(from: testURL)
        
        XCTAssertNil(loadedImage, "Should return nil")
    }
    
    func testClearCache() async throws {
        try await loader.saveImage(mockImage, for: testURL)
        
        var loadedImage = try await loader.loadImage(from: testURL)
        XCTAssertNotNil(loadedImage, "Image should be in cache")
        
        try await loader.clearCache()
        
        loadedImage = try await loader.loadImage(from: testURL)
        XCTAssertNil(loadedImage, "Image should not be in cache")
    }
}
