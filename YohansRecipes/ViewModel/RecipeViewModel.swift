//
//  RecipeViewModel.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import Foundation
import SwiftUI

class RecipeViewModel: ObservableObject {
    
    @Published var reacipes: [Recipe] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isShuffling = false
    @Published var isEmptyResponse = false
    
    // URLs for fetching recipes
    let recipesURL = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
    let emptyDataTestURL = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
    let malformedDataTestURL = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
    
    // MARK: - Recipe Fetching
    
    func fetchRecipes(with urlString: String) async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
            self.isEmptyResponse = false
            self.reacipes = []
        }
        
        await RecipeLoader.clearImageCache()
        
        do {
            try await performFetch(urlString: urlString)
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    private func performFetch(urlString: String) async throws {
        do {
            let fetchedRecipes = try await RecipeLoader.fetchRecipes(from: urlString)
            
            await MainActor.run {
                self.reacipes = fetchedRecipes
                
                if self.reacipes.isEmpty {
                    self.isEmptyResponse = true
                }
                
                self.isLoading = false
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Favorites Management
    
    func isFavorite(id: String) -> Bool {
        return reacipes.first(where: { $0.id == id })?.isFavorite ?? false
    }
    
    func toggleFavorite(for recipeId: String) {
        if let index = reacipes.firstIndex(where: { $0.id == recipeId }) {
            reacipes[index].isFavorite.toggle()
        }
    }
    
    // MARK: - Suffle Recipes
    
    func shuffleRecipes() {
        if isShuffling || isLoading { return }
        
        isShuffling = true
        
        Task { @MainActor in
            var shuffledRecipes = self.reacipes
            
            shuffledRecipes.shuffle()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.reacipes = shuffledRecipes
            }
            
            // Set the isShuffling state after 0.5 seconds delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.isShuffling = false
        }
    }
}

