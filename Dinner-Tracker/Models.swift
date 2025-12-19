//
//  Models.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import Foundation

struct Ingredient: Identifiable, Codable {
    var id = UUID()
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

enum CookingUnit: String, Codable, CaseIterable {
    case none = ""
    case teaspoon = "tsp"
    case tablespoon = "tbsp"
    case cup = "cup"
    case milliliter = "ml"
    case liter = "l"
    case gram = "g"
    case kilogram = "kg"
    case ounce = "oz"
    case pound = "lb"
    case pinch = "pinch"
    case dash = "dash"
    case toTaste = "to taste"
    
    var displayName: String {
        switch self {
        case .none: return "No unit"
        case .teaspoon: return "Teaspoon (tsp)"
        case .tablespoon: return "Tablespoon (tbsp)"
        case .cup: return "Cup"
        case .milliliter: return "Milliliter (ml)"
        case .liter: return "Liter (l)"
        case .gram: return "Gram (g)"
        case .kilogram: return "Kilogram (kg)"
        case .ounce: return "Ounce (oz)"
        case .pound: return "Pound (lb)"
        case .pinch: return "Pinch"
        case .dash: return "Dash"
        case .toTaste: return "To taste"
        }
    }
}

struct RecipeIngredient: Codable, Hashable {
    var name: String
    var quantity: String
    var unit: CookingUnit
    
    init(name: String, quantity: String = "", unit: CookingUnit = .none) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}

struct Recipe: Identifiable, Codable {
    var id = UUID()
    var name: String
    var recipeIngredients: [RecipeIngredient]
    var instructions: String
    var imageData: Data?
    
    init(name: String, recipeIngredients: [RecipeIngredient] = [], instructions: String = "", imageData: Data? = nil) {
        self.name = name
        self.recipeIngredients = recipeIngredients
        self.instructions = instructions
        self.imageData = imageData
    }
    
    // For backward compatibility
    var ingredientNames: [String] {
        return recipeIngredients.map { $0.name }
    }
    
    var ingredients: [Ingredient] {
        return recipeIngredients.map { Ingredient(name: $0.name) }
    }
}
