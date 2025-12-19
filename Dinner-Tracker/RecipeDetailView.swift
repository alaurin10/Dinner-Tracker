//
//  RecipeDetailView.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recipe Image
                if let image = imageFromData(recipe.imageData) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .cornerRadius(12)
                        .clipped()
                        .padding(.horizontal)
                }
                
                // Recipe Title
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("\(recipe.recipeIngredients.count) ingredients")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Divider()
                
                // Ingredients Section
                if !recipe.recipeIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(recipe.recipeIngredients, id: \.self) { ingredient in
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                        .foregroundStyle(.secondary)
                                    
                                    HStack(spacing: 6) {
                                        if !ingredient.quantity.isEmpty {
                                            Text(ingredient.quantity)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.blue)
                                        }
                                        if ingredient.unit != .none {
                                            Text(ingredient.unit.rawValue)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.blue)
                                        }
                                        Text(ingredient.name)
                                            .font(.body)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                }
                
                // Instructions Section
                if !recipe.instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            let steps = recipe.instructions
                                .split(separator: "\n")
                                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                            
                            if steps.isEmpty {
                                Text(recipe.instructions)
                                    .font(.body)
                                    .lineSpacing(4)
                            } else {
                                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(index + 1).")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.blue)
                                            .frame(width: 24, alignment: .leading)
                                        
                                        Text(step.trimmingCharacters(in: .whitespaces))
                                            .font(.body)
                                            .lineSpacing(2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Recipe")
//        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RecipeDetailView(recipe: Recipe(
        name: "Pasta Carbonara",
        recipeIngredients: [
            RecipeIngredient(name: "Pasta", quantity: "400", unit: .gram),
            RecipeIngredient(name: "Eggs", quantity: "3", unit: .none),
            RecipeIngredient(name: "Bacon", quantity: "200", unit: .gram),
            RecipeIngredient(name: "Parmesan Cheese", quantity: "100", unit: .gram)
        ],
        instructions: "1. Cook pasta in salted boiling water.\n2. While pasta cooks, fry bacon until crispy.\n3. Beat eggs with cheese.\n4. Drain pasta and mix with bacon.\n5. Remove from heat and add egg mixture.\n6. Toss quickly and serve immediately."
    ))
}
