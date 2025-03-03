//
//  RecipeCard.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import SwiftUI

struct RecipeCard: View {
    
    let recipe: Recipe
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        // Wrap the entire card in a container to ensure all components animate together
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                imageSection
                nameSection
            }
        }
        .padding(.bottom, 8)
        .cornerRadius(10)
        .contentShape(Rectangle())
    }
    
    // MARK: - View Components
    
    private var imageSection: some View {
        ZStack(alignment: .topLeading) {
            RecipeImage(url: recipe.photoURLSmall)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .opacity(0.5)
            cuisineTag
            favoriteButton
        }
    }
    
    private var cuisineTag: some View {
        Text(recipe.cuisine)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(4)
            .background(Color.black)
            .cornerRadius(5)
            .padding([.top, .leading], 10)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onFavoriteToggle()
            }
        }) {
            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(.red)
                .font(.system(size: 22))
                .padding(8)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: recipe.isFavorite)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var nameSection: some View {
        Text(recipe.name)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .lineLimit(3)
            .multilineTextAlignment(.trailing)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.5)
            .padding([.horizontal, .vertical], 10)
            .padding([.bottom, .trailing], 0)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
