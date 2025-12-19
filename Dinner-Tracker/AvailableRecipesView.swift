//
//  AvailableRecipesView.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI

struct AvailableRecipesView: View {
    @ObservedObject var dataStore: RecipeDataStore
    
    var availableRecipes: [Recipe] {
        dataStore.getAvailableRecipes()
    }
    
    var body: some View {
        NavigationStack {
            List {
                if availableRecipes.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No recipes available")
                            .font(.headline)
                        Text("Add more ingredients to see what you can cook!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(availableRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            HStack(spacing: 12) {
                                if let image = imageFromData(recipe.imageData) {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .clipped()
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "photo.fill")
                                                .foregroundStyle(.gray)
                                                .font(.system(size: 24))
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text("\(recipe.ingredients.count) ingredients")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Available Recipes")
        }
    }
}

struct FlowLayout<Content: View>: View {
    let content: Content
    var spacing: CGFloat = 8
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
    }
}

#Preview {
    AvailableRecipesView(dataStore: RecipeDataStore())
}
