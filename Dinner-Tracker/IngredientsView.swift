//
//  IngredientsView.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI

struct IngredientsView: View {
    @ObservedObject var dataStore: RecipeDataStore
    @State private var newIngredientName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Add new ingredient", text: $newIngredientName)
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        .disabled(newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                
                Section("Available Ingredients") {
                    if dataStore.availableIngredients.isEmpty {
                        Text("No ingredients yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(dataStore.availableIngredients) { ingredient in
                            Text(ingredient.name)
                        }
                        .onDelete(perform: deleteIngredient)
                    }
                }
            }
            .navigationTitle("Ingredients")
        }
    }
    
    private func addIngredient() {
        let trimmedName = newIngredientName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let newIngredient = Ingredient(name: trimmedName)
        dataStore.addIngredient(newIngredient)
        newIngredientName = ""
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        offsets.forEach { index in
            dataStore.deleteIngredient(at: index)
        }
    }
}

#Preview {
    IngredientsView(dataStore: RecipeDataStore())
}
