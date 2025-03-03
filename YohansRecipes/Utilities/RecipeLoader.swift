//
//  RecipeLoader.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/2/25.
//

import Foundation

class RecipeLoader {

    static func fetchRecipes(from urlString: String) async throws -> [Recipe] {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "RecipeLoader", code: 0,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
        return recipeResponse.recipes
    }
    
    static func clearImageCache() async {
        await ImageLoader.clearCache()
    }
}
