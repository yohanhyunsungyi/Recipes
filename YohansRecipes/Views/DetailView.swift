//
//  RecipeDetailView.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import SwiftUI

struct DetailView: View {
    
    @EnvironmentObject private var viewModel: RecipeViewModel
    private let recipeId: String

    private var recipe: Recipe? {
        return viewModel.reacipes.first(where: { $0.id == recipeId })
    }
    
    init(recipeId: String) {
        self.recipeId = recipeId
    }
    
    var body: some View {
        Group {
            if let recipe = recipe {
                recipeContent(for: recipe)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                notFoundDetail
            }
        }
    }
    
    // MARK: - View Components
    
    private func recipeContent(for recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                imageSection(for: recipe)
                
                infoSection(for: recipe)
            }
        }
    }
    
    private var notFoundDetail: some View {
        ErrorView(
            title: "No recipe detail found",
            buttonTitle: nil,
            buttonAction: {},
            systemImage: "exclamationmark.triangle"
        )
    }
    
    private func imageSection(for recipe: Recipe) -> some View {
        RecipeImage(url: recipe.photoURLLarge)
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
    }
    
    
    private func infoSection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            titleSection(for: recipe)
            Divider()
            linksSection(for: recipe)
            Spacer()
        }
        .padding()
    }
    
    private func titleSection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Text(recipe.cuisine)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                favoriteButton(for: recipe)
            }
        }
    }
    
    private func favoriteButton(for recipe: Recipe) -> some View {
        Button {
            viewModel.toggleFavorite(for: recipe.id)
        } label: {
            Label("Favorites", systemImage: recipe.isFavorite ? "heart.fill" : "heart")
                .labelStyle(.iconOnly)
                .font(.title2)
                .foregroundColor(recipe.isFavorite ? .red : .gray)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: recipe.isFavorite)
        }
    }
    
    private func linksSection(for recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Links")
                .font(.headline)
            
            if let youtubeURL = recipe.youtubeURL, let url = URL(string: youtubeURL) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.red)
                        Text("Watch Video Tutorial")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            if let sourceURL = recipe.sourceURL, !sourceURL.isEmpty, let url = URL(string: sourceURL) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                        Text("View Original Recipe")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}


