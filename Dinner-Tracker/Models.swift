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

struct Recipe: Identifiable, Codable {
    var id = UUID()
    var name: String
    var ingredients: [Ingredient]
    var instructions: String
    
    init(name: String, ingredients: [Ingredient] = [], instructions: String = "") {
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
    }
}
