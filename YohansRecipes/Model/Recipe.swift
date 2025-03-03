//
//  Recipe.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import Foundation

struct Recipe: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let cuisine: String
    let photoURLLarge: String
    let photoURLSmall: String
    let sourceURL: String?
    let youtubeURL: String?
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case cuisine
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
        // isFavorite is not from the API
    }
}

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}
