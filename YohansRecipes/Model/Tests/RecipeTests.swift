//
//  RecipeTests.swift
//  YohansRecipesTests
//
//  Created by Yohan Yi on 2/28/25.
//
import XCTest
@testable import YohansRecipes

final class RecipeTests: XCTestCase {
    
    private let validRecipeJSON = """
    {
        "cuisine": "British",
        "name": "Apple Frangipan Tart",
        "photo_url_large": "https://testUrl.com/large.jpg",
        "photo_url_small": "https://testUrl.com/small.jpg",
        "source_url": "https://testUrl.com/recipes/banana-pancakes",
        "uuid": "74f6d4eb-da50-4901-94d1-deae2d8af1d1",
        "youtube_url": "https://www.testUrl.com/watch?v=rp8Slv4INLk"
    }
    """
    
    private let recipeResponseJSON = """
    {
        "recipes": [
            {
                "cuisine": "British",
                "name": "Bakewell Tart",
                "photo_url_large": "https://testUrl.com/large.jpg",
                "photo_url_small": "https://testUrl.com/small.jpg",
                    "source_url": "https://www.testUrl.com/recipes/banana",
                "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6",
                "youtube_url": "https://www.testUrl.com/watch?v=1ahpSTf_Pvk"
            },
            {
                "cuisine": "American",
                "name": "Banana Pancakes",
                "photo_url_large": "https://testUrl.com/large.jpg",
                "photo_url_small": "https://testUrl.com/small.jpg",
                "source_url": "https://www.testUrl.com/recipes/banana-pancakes",
                "uuid": "f8b20884-1e54-4e72-a417-dabbc8d91f12",
            }
        ]
    }
    """
    
    // MARK: - Decoding Tests
    
    func testRecipeDecoding() throws {
        let data = validRecipeJSON.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(Recipe.self, from: data)
        
        XCTAssertEqual(recipe.id, "74f6d4eb-da50-4901-94d1-deae2d8af1d1")
        XCTAssertEqual(recipe.name, "Apple Frangipan Tart")
        XCTAssertEqual(recipe.cuisine, "British")
        XCTAssertEqual(recipe.photoURLLarge, "https://testUrl.com/large.jpg")
        XCTAssertEqual(recipe.photoURLSmall, "https://testUrl.com/small.jpg")
        XCTAssertEqual(recipe.sourceURL, "https://testUrl.com/recipes/banana-pancakes")
        XCTAssertEqual(recipe.youtubeURL, "https://www.testUrl.com/watch?v=rp8Slv4INLk")
        XCTAssertFalse(recipe.isFavorite) // Default should be false
    }
    
    func testRecipeResponseDecoding() throws {
        let data = recipeResponseJSON.data(using: .utf8)!
        let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
        
        XCTAssertEqual(response.recipes.count, 2)
        XCTAssertEqual(response.recipes[0].id, "eed6005f-f8c8-451f-98d0-4088e2b40eb6")
        XCTAssertEqual(response.recipes[1].id, "f8b20884-1e54-4e72-a417-dabbc8d91f12")
        XCTAssertNil(response.recipes[1].youtubeURL)
    }
    
    // MARK: - Encoding Tests
    
    func testRecipeEncoding() throws {
        let recipe = Recipe(
            id: "8938f16a-954c-4d65-953f-fa069f3f1b0d",
            name: "Blackberry Fool",
            cuisine: "British",
            photoURLLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ff52841a-df5b-498c-b2ae-1d2e09ea658d/large.jpg",
            photoURLSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/ff52841a-df5b-498c-b2ae-1d2e09ea658d/small.jpg",
            sourceURL: "https://www.bbc.co.uk/food/recipes/blackberry_fool_with_11859",
            youtubeURL: "https://www.youtube.com/watch?v=kniRGjDLFrQ",
            isFavorite: true
        )
        
        let encodedData = try JSONEncoder().encode(recipe)
        let decodedRecipe = try JSONDecoder().decode(Recipe.self, from: encodedData)
        
        XCTAssertEqual(decodedRecipe.id, recipe.id)
        XCTAssertEqual(decodedRecipe.name, recipe.name)
        XCTAssertEqual(decodedRecipe.cuisine, recipe.cuisine)
        XCTAssertEqual(decodedRecipe.photoURLLarge, recipe.photoURLLarge)
        XCTAssertEqual(decodedRecipe.photoURLSmall, recipe.photoURLSmall)
        XCTAssertEqual(decodedRecipe.sourceURL, recipe.sourceURL)
        XCTAssertEqual(decodedRecipe.youtubeURL, recipe.youtubeURL)
        XCTAssertFalse(decodedRecipe.isFavorite)
    }
}
