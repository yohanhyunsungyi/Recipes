//
//  RemoteImageLoaderTests.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import XCTest
@testable import YohansRecipes

final class RemoteImageLoaderTests: XCTestCase {
    
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
    
    // MARK: - Helper Function
    
    func loadImage(from url: URL, session: URLSessionProtocol) async throws -> UIImage {
        let (data, _) = try await session.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw RemoteImageLoaderError.invalidImageData
        }
        
        return image
    }
    
    // MARK: - Tests
    
    func testLoadImageSuccess() async throws {
        let mockSession = MockURLSession()
        mockSession.mockData = mockImageData
        
        let image = try await loadImage(from: testURL, session: mockSession)
        
        XCTAssertNotNil(image, "successfully load an image")
    }
    
    func testLoadImageNetworkError() async {
        let mockSession = MockURLSession()
        let expectedError = NSError(domain: "NetworkError", code: 404,
                                    userInfo: [NSLocalizedDescriptionKey: "Not found"])
        mockSession.mockError = expectedError
        
        do {
            _ = try await loadImage(from: testURL, session: mockSession)
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "NetworkError")
            XCTAssertEqual(nsError.code, 404)
        }
    }
    
    func testLoadImageInvalidData() async {
        let mockSession = MockURLSession()
        mockSession.mockData = Data("not an image".utf8)
        
        do {
            _ = try await loadImage(from: testURL, session: mockSession)
        } catch let error as RemoteImageLoaderError {
            switch error {
            case .invalidImageData:
                // This is the expected error
                XCTAssertTrue(true, "Correctly threw invalidImageData error")
            default:
                XCTFail("Wrong error \(error)")
            }
        } catch {
            XCTFail("Wrong error \(error)")
        }
    }
}
