//
//  HomeView.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import Foundation
import SwiftUI
import UIKit

struct HomeView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    @State private var viewState = ViewState()
    private struct ViewState {
        var columns: Int = 2
        var searchText: String = ""
        var showFavoritesOnly: Bool = false
        var isRefreshing: Bool = false
    }
    
    private var filteredRecipes: [Recipe] {
        var recipes = viewModel.reacipes
        
        // Filter by favorites
        if viewState.showFavoritesOnly {
            recipes = recipes.filter { $0.isFavorite }
        }
        
        // Filter by search text
        if !viewState.searchText.isEmpty {
            recipes = recipes.filter { $0.name.localizedCaseInsensitiveContains(viewState.searchText) }
        }
        
        return recipes
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(searchText: $viewState.searchText)
                
                // Action Buttons
                Actions(
                    viewModel: viewModel,
                    columns: $viewState.columns,
                    showFavoritesOnly: $viewState.showFavoritesOnly,
                    isRefreshing: $viewState.isRefreshing
                )
                
                // Contents
                contents
            }
            .navigationTitle("Recipes")
            .animation(.easeInOut(duration: 0.3), value: viewState.columns)
            .onAppear {
                if viewModel.reacipes.isEmpty {
                    Task {
                        await viewModel.fetchRecipes(with: viewModel.recipesURL)
                    }
                }
            }
        }
    }
    
    // MARK: - Showing Content Logic depnds on View Status
    private var contents: some View {
        ScrollView {
            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.error {
                ErrorView(title: error.localizedDescription,
                          buttonTitle: "Try Again",
                          buttonAction: {
                    Task {
                        await viewModel.fetchRecipes(with: viewModel.recipesURL)
                    }
                },
                          systemImage: "exclamationmark.triangle")
            } else if viewModel.isEmptyResponse {
                emptyResponseView
            } else if filteredRecipes.isEmpty && !viewState.isRefreshing {
                noResultsView
            } else {
                recipeGrid
            }
        }
    }
    
    // MARK: - Grid View
    
    private var recipeGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: viewState.columns),
            spacing: 16
        ) {
            ForEach(filteredRecipes) { recipe in
                NavigationLink {
                    DetailView(
                        recipeId: recipe.id
                    )
                    .environmentObject(viewModel)
                } label: {
                    RecipeCard(recipe: recipe, onFavoriteToggle: {
                        viewModel.toggleFavorite(for: recipe.id)
                    })
                }
                .id(recipe.id)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.3), value: filteredRecipes)
    }
    
    // MARK: - Error Views
    
    private var emptyResponseView: some View {
        ErrorView(
            title: "The recipe service returned an empty list.",
            buttonTitle: "Try Again",
            buttonAction: {
                Task {
                    await viewModel.fetchRecipes(with: viewModel.recipesURL)
                }
            },
            systemImage: "exclamationmark.circle"
        )
    }
    
    private var noResultsView: some View {
        if viewState.showFavoritesOnly {
            return ErrorView(
                title: viewState.searchText.isEmpty ? "No favorite recipes" : "No favorite recipes found for \"\(viewState.searchText)\"",
                buttonTitle: "Show All Recipes",
                buttonAction: { viewState.showFavoritesOnly = false },
                systemImage: "magnifyingglass"
            )
        } else {
            return ErrorView(
                title: "No recipes found for \"\(viewState.searchText)\"",
                buttonTitle: "Show All Recipes",
                buttonAction: { viewState.searchText = "" },
                systemImage: "magnifyingglass"
            )
        }
    }
}
