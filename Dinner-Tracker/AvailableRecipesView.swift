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
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.name)
                                .font(.headline)
                            
                            FlowLayout(spacing: 6) {
                                ForEach(recipe.ingredients) { ingredient in
                                    Text(ingredient.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.vertical, 4)
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
