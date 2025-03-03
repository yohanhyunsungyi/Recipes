//
//  ImageLoaderTests.swift
//  YohansRecipesTests
//
//  Created by Yohan Yi on 2/28/25.
//

import XCTest
@testable import YohansRecipes

final class ImageLoaderTests: XCTestCase {
    
    var testURL: URL!
    var mockImage: UIImage!
    var mockImageData: Data!
    
    override func setUp() {
        super.setUp()
        
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
        mockImageData = mockImage.pngData()!
    }
    
    override func tearDown() {
        testURL = nil
        mockImage = nil
        mockImageData = nil
        super.tearDown()
    }
    
    // MARK: - Helper Functions
    
    func loadImage(from urlString: String, session: URLSessionProtocol) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await session.data(from: url)
        return UIImage(data: data)
    }
    
    // MARK: - Tests
    
    func testLoadImageSuccess() async throws {
        let session = MockURLSession()
        session.mockData = mockImageData
        
        let image = try await loadImage(from: testURL.absoluteString, session: session)
        
        XCTAssertNotNil(image, "Image should be not nil")
    }
    
    func testLoadImageFailure() async {
        let session = MockURLSession()
        session.mockError = NSError(domain: "NetworkError", code: 404,
                                    userInfo: [NSLocalizedDescriptionKey: "Image not found"])
        
        do {
            _ = try await loadImage(from: testURL.absoluteString, session: session)
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "NetworkError")
            XCTAssertEqual(nsError.code, 404)
        }
    }
    
    func testInvalidURL() async {
        let session = MockURLSession()
        
        do {
            // load with empty URL
            _ = try await loadImage(from: "", session: session)
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "ImageLoader")
            XCTAssertEqual(nsError.code, 0)
        }
    }
}
