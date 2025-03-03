//
//  HomeViewComponents.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 2/28/25.
//

import SwiftUI

// MARK: - Reusable button component

struct ActionButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var disabled: Bool = false
    
    @GestureState private var isPressed = false
    
    private let cornerRadius: CGFloat = 10
    private let tapThreshold: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 13))
            }
            Text(title)
                .font(.system(size: 14))
                .fontWeight(.medium)
        }
        .padding(8)
        .foregroundColor(isPressed ? .white : .black)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isPressed ? Color.black : Color.clear)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black, lineWidth: 0.7)
            }
        )
        .opacity(disabled ? 0.5 : 1.0)
        .contentShape(Rectangle())
        
        // Regular SwiftUI config.isPressed is not working in scrollview
        // https://developer.apple.com/forums/thread/774542
        // Therefore, used simultaneousGesture.
        // https://forums.swift.org/t/using-draggesture-to-implement-touchdown-and-touchup-interferes-with-scrolling-in-scrollview/36901
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
                .onEnded { value in
                    if abs(value.translation.width) < tapThreshold &&
                        abs(value.translation.height) < tapThreshold {
                        if !disabled {
                            action()
                        }
                    }
                }
        )
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search...", text: $searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding([.vertical, .horizontal], 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding([.horizontal, .vertical], 8)
    }
}

// MARK: - Action Button Horizental View

struct Actions: View {
    @ObservedObject var viewModel: RecipeViewModel
    @Binding var columns: Int
    @Binding var showFavoritesOnly: Bool
    @Binding var isRefreshing: Bool
    
    private func fetchRecipe(with urlString: String) async {
        isRefreshing = true
        await viewModel.fetchRecipes(with: urlString)
        isRefreshing = false
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                
                // Fewer columns button
                ActionButton(
                    title: "Fewer",
                    action: {
                        columns = max(columns - 1, 1)
                    },
                    icon: "minus",
                    disabled: columns <= 1
                )
                
                // More columns button
                ActionButton(
                    title: "More",
                    action: {
                        columns = min(columns + 1, 3)
                    },
                    icon: "plus",
                    disabled: columns >= 3
                )
                
                // Favorites filter
                ActionButton(
                    title: "Favorites",
                    action: {
                        showFavoritesOnly.toggle()
                    },
                    icon: showFavoritesOnly ? "heart.fill" : "heart"
                )
                
                // Shuffle button
                ActionButton(
                    title: "Shuffle",
                    action: {
                        viewModel.shuffleRecipes()
                    },
                    icon: "shuffle"
                )
                
                // Refresh button
                ActionButton(
                    title: "Refresh",
                    action: {
                        Task {
                            await fetchRecipe(with: viewModel.recipesURL)
                        }
                    },
                    icon: "arrow.clockwise"
                )
                
                // Malformed Data button
                ActionButton(
                    title: "Malformed",
                    action: {
                        Task {
                            await fetchRecipe(with: viewModel.malformedDataTestURL)
                        }
                    },
                    icon: "exclamationmark.triangle"
                )
                
                // Empty Data button
                ActionButton(
                    title: "Empty",
                    action: {
                        Task {
                            await fetchRecipe(with: viewModel.emptyDataTestURL)
                        }
                    },
                    icon: "tray"
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 3)
        }
        .padding(.bottom, 5)
    }
}

// MARK: - Error State Views

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .padding(.bottom, 8)
            Text("Loading recipes...")
                .foregroundColor(.secondary)
        }
        .padding(.top, 200)
    }
}

struct ErrorView: View {
    let title: String
    let buttonTitle: String?
    let buttonAction: () -> Void
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let buttonTitle {
                ActionButton(title: buttonTitle, action: buttonAction)
            }
        }
        .padding(.top, 50)
        .padding(.horizontal)
    }
}
