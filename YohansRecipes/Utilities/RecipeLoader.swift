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
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "RecipeLoader", code: statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid response: \(statusCode)"])
        }
        
        let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
        return recipeResponse.recipes
    }
    
    static func clearImageCache() async {
        await ImageLoader.clearCache()
    }
}
