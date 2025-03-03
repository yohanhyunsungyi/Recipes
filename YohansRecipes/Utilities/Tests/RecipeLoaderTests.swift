//
//  FavoriteStoreTests.swift
//  YohansRecipesTests
//
//  Created by Yohan Yi on 2/28/25.
//

import XCTest
@testable import YohansRecipes

final class RecipeLoaderTests: XCTestCase {
    
    // MARK: - Mock Data
    
    let testURL = "https://testUrl.com/recipes"
    var mockJSON: Data!
    
    override func setUp() {
        super.setUp()
        
        let json = """
        {
            "recipes": [
                {
                    "uuid": "02a80f95-09d6-430c-a9da-332584229d6f",
                    "name": "Bread and Butter Pudding",
                    "cuisine": "British",
                    "photo_url_large": "https://testUrl.com/large.jpg",
                    "photo_url_small": "https://testUrl.com/small.jpg",
                    "source_url": "https://testUrl.com/source",
                    "youtube_url": "https://testUrl.com/watch?v=test"
                },
                {
                    "uuid": "563dbb27-5323-443c-b30c-c221ae598568",
                    "name": "Budino Di Ricotta",
                    "cuisine": "Italian",
                    "photo_url_large": "https://testUrl.com/large2.jpg",
                    "photo_url_small": "https://testUrl.com/small2.jpg",
                    "source_url": "https://testUrl.com/source2",
                }
            ]
        }
        """
        mockJSON = json.data(using: .utf8)!
    }
    
    // MARK: - Tests
    
    func testFetchRecipes() async throws {
        let session = MockURLSession()
        session.mockData = mockJSON
        
        let fetchRecipesWithSession = { (urlString: String, session: URLSessionProtocol) async throws -> [Recipe] in
            guard let url = URL(string: urlString) else { return [] }
            
            let (data, _) = try await session.data(from: url)
            
            let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return recipeResponse.recipes
        }
        
        let recipes = try await fetchRecipesWithSession(testURL, session)
        
        XCTAssertEqual(recipes.count, 2)
        XCTAssertEqual(recipes[0].id, "02a80f95-09d6-430c-a9da-332584229d6f")
        XCTAssertEqual(recipes[0].name, "Bread and Butter Pudding")
        XCTAssertEqual(recipes[0].cuisine, "British")
        XCTAssertEqual(recipes[0].photoURLLarge, "https://testUrl.com/large.jpg")
        XCTAssertEqual(recipes[0].photoURLSmall, "https://testUrl.com/small.jpg")
        XCTAssertEqual(recipes[0].sourceURL, "https://testUrl.com/source")
        XCTAssertEqual(recipes[0].youtubeURL, "https://testUrl.com/watch?v=test")
        XCTAssertFalse(recipes[0].isFavorite)
        
        XCTAssertEqual(recipes[1].id, "563dbb27-5323-443c-b30c-c221ae598568")
        XCTAssertEqual(recipes[1].name, "Budino Di Ricotta")
        XCTAssertNil(recipes[1].youtubeURL)
    }
    
    func testInvalidURL() async {
        // Test with a empty URL
        do {
            _ = try await RecipeLoader.fetchRecipes(from: "")
        } catch {
            XCTAssertTrue(error is NSError)
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "RecipeLoader")
            XCTAssertEqual(nsError.code, 0)
        }
    }
    
    func testNetworkError() async {
        let session = MockURLSession()
        session.mockError = NSError(domain: "NetworkError", code: 404, userInfo: nil)
        
        let fetchRecipesWithSession = { (urlString: String, session: URLSessionProtocol) async throws -> [Recipe] in
            guard let url = URL(string: urlString) else { return [] }
            
            let (data, _) = try await session.data(from: url)
            
            let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return recipeResponse.recipes
        }
        
        do {
            _ = try await fetchRecipesWithSession(testURL, session)
        } catch {
            XCTAssertTrue(error is NSError)
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "NetworkError")
            XCTAssertEqual(nsError.code, 404)
        }
    }
}
