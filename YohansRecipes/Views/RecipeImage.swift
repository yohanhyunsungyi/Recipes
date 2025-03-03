//
//  RecipeImage 2.swift
//  YohansRecipes
//
//  Created by Yohan Yi on 3/1/25.
//

import SwiftUI

struct RecipeImage: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image
    
    init(url: String, placeholder: Image = Image(systemName: "photo")) {
        self.placeholder = placeholder
        let imageURL = URL(string: url) ?? URL(string: "")!
        _loader = StateObject(wrappedValue: ImageLoader(url: imageURL))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    
                    if loader.isLoading {
                        ProgressView()
                    } else {
                        placeholder
                            .font(.system(size: 30))
                            .foregroundColor(Color(.systemGray3))
                    }
                }
            }
        }
        .onAppear {
            loader.load()
        }
        .onDisappear {
            loader.cancelTask()
        }
    }
}
