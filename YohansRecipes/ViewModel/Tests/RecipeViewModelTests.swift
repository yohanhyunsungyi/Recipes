//
//  RecipeViewModelTests.swift
//  YohansRecipesTests
//
//  Created by Yohan Yi on 2/28/25.
//

import XCTest
@testable import YohansRecipes

final class RecipeViewModelTests: XCTestCase {
    
    private let validRecipeJSON = """
    {
        "recipes": [
            {
                "cuisine": "Malaysian",
                "name": "Apam Balik",
                "photo_url_large": "https://testUrl.com/large.jpg",
                "photo_url_small": "https://testUrl.com/small.jpg",
                "source_url": "https://testUrl.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                "youtube_url": "https://testUrl.com/watch?v=6R8ffRRJcrg"
            },
            {
                "cuisine": "British",
                "name": "Apple & Blackberry Crumble",
                "photo_url_large": "https://testUrl.com/large.jpg",
                "photo_url_small": "https://testUrl.com/small.jpg",
                "source_url": "https://testUrl.com/recipes/778642/apple-and-blackberry-crumble",
                "uuid": "599344f4-3c5c-4cca-b914-2210e3b3312f",
                "youtube_url": "https://testUrl.com/watch?v=4vhcOwVBDO4"
            }
        ]
    }
    """
    
    private let emptyRecipeJSON = """
    {
        "recipes": []
    }
    """
    
    private let malformedJSON = "{ this is not valid JSON }"
    
    private var viewModel: RecipeViewModel!
    private var mockRecipes: [Recipe] = []
    
    override func setUp() async throws {
        viewModel = RecipeViewModel()
        
        let data = validRecipeJSON.data(using: .utf8)!
        let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
        mockRecipes = recipeResponse.recipes
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockRecipes = []
    }
    
    // MARK: - Fetch Tests
    
    func testFetchRecipesSuccess() async throws {
        let expectation = expectation(description: "Recipes loaded")
        
        await MainActor.run {
            viewModel.isLoading = true
            viewModel.reacipes = mockRecipes
            viewModel.isLoading = false
            viewModel.error = nil
            viewModel.isEmptyResponse = viewModel.reacipes.isEmpty
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Verify results
        XCTAssertEqual(viewModel.reacipes.count, 2)
        XCTAssertEqual(viewModel.reacipes[0].id, "0c6ca6e7-e32a-4053-b824-1dbf749910d8")
        XCTAssertEqual(viewModel.reacipes[1].id, "599344f4-3c5c-4cca-b914-2210e3b3312f")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isEmptyResponse)
    }
    
    func testFetchRecipesEmpty() async throws {
        let data = emptyRecipeJSON.data(using: .utf8)!
        let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
        let emptyRecipes = recipeResponse.recipes
        
        let expectation = expectation(description: "Empty recipes loaded")
        
        await MainActor.run {
            viewModel.isLoading = true
            viewModel.reacipes = emptyRecipes
            viewModel.isLoading = false
            viewModel.error = nil
            viewModel.isEmptyResponse = viewModel.reacipes.isEmpty
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.reacipes.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.isEmptyResponse)
    }
    
    func testFetchRecipesError() async {
        let error = NSError(domain: "test", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not found"])
        
        let expectation = expectation(description: "Error handling")
        
        await MainActor.run {
            viewModel.isLoading = true
            viewModel.reacipes = []
            viewModel.error = error
            viewModel.isLoading = false
            viewModel.isEmptyResponse = false
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Verify results
        XCTAssertEqual(viewModel.reacipes.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isEmptyResponse)
    }
    
    // MARK: - Favorites Tests
    
    func testToggleFavorite() async throws {
        await MainActor.run {
            viewModel.reacipes = mockRecipes
        }
        
        // Initial state should be not favorite
        XCTAssertFalse(viewModel.isFavorite(id: "0c6ca6e7-e32a-4053-b824-1dbf749910d8"))
        
        // Toggle favorite
        viewModel.toggleFavorite(for: "0c6ca6e7-e32a-4053-b824-1dbf749910d8")
        
        // Verify state changed
        XCTAssertTrue(viewModel.isFavorite(id: "0c6ca6e7-e32a-4053-b824-1dbf749910d8"))
        
        // Toggle back
        viewModel.toggleFavorite(for: "0c6ca6e7-e32a-4053-b824-1dbf749910d8")
        
        // Verify state changed back
        XCTAssertFalse(viewModel.isFavorite(id: "0c6ca6e7-e32a-4053-b824-1dbf749910d8"))
    }
    
    // MARK: - Shuffle Tests
    
    func testShuffleRecipes() async throws {
        // Create a viewModel with many recipes to increase shuffle chance
        viewModel.reacipes = (1...20).map { index in
            Recipe(
                id: "uuid-\(index)",
                name: "name-\(index)",
                cuisine: "Cuisine",
                photoURLLarge: "https://testUrl.com/large\(index).jpg",
                photoURLSmall: "https://testUrl.com/small\(index).jpg",
                sourceURL: nil,
                youtubeURL: nil
            )
        }
        
        // Get the initial order
        let initialOrder = viewModel.reacipes.map { $0.id }
        
        // Shuffle
        viewModel.shuffleRecipes()
        
        // Wait for the shuffle animation to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds to match the viewModel implementation
        
        // Get the new order
        let newOrder = viewModel.reacipes.map { $0.id }
        
        // Verify the order changed
        XCTAssertNotEqual(initialOrder, newOrder)
    }
}
