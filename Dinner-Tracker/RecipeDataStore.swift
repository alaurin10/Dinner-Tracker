//
//  RecipeDataStore.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import Foundation
import Combine

class RecipeDataStore: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var availableIngredients: [Ingredient] = []
    
    private let recipesKey = "recipes"
    private let ingredientsKey = "availableIngredients"
    
    init() {
        loadRecipes()
        loadIngredients()
    }
    
    // MARK: - Recipe Management
    
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveRecipes()
    }
    
    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
            saveRecipes()
        }
    }
    
    func deleteRecipe(at index: Int) {
        recipes.remove(at: index)
        saveRecipes()
    }
    
    // MARK: - Ingredient Management
    
    func addIngredient(_ ingredient: Ingredient) {
        if !availableIngredients.contains(where: { $0.name.lowercased() == ingredient.name.lowercased() }) {
            availableIngredients.append(ingredient)
            saveIngredients()
        }
    }
    
    func deleteIngredient(at index: Int) {
        availableIngredients.remove(at: index)
        saveIngredients()
    }
    
    // MARK: - Recipe Matching
    
    func getAvailableRecipes() -> [Recipe] {
        let availableIngredientNames = Set(availableIngredients.map { $0.name.lowercased() })
        
        return recipes.filter { recipe in
            let recipeIngredientNames = Set(recipe.ingredients.map { $0.name.lowercased() })
            return recipeIngredientNames.isSubset(of: availableIngredientNames)
        }
    }
    
    // MARK: - Persistence
    
    private func saveRecipes() {
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: recipesKey)
        }
    }
    
    private func loadRecipes() {
        if let data = UserDefaults.standard.data(forKey: recipesKey),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            recipes = decoded
        }
    }
    
    private func saveIngredients() {
        if let encoded = try? JSONEncoder().encode(availableIngredients) {
            UserDefaults.standard.set(encoded, forKey: ingredientsKey)
        }
    }
    
    private func loadIngredients() {
        if let data = UserDefaults.standard.data(forKey: ingredientsKey),
           let decoded = try? JSONDecoder().decode([Ingredient].self, from: data) {
            availableIngredients = decoded
        }
    }
}
