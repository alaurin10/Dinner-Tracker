//
//  RecipesView.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI

struct RecipesView: View {
    @ObservedObject var dataStore: RecipeDataStore
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataStore.recipes) { recipe in
                    NavigationLink(destination: EditRecipeView(dataStore: dataStore, recipe: recipe)) {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                            Text("\(recipe.ingredients.count) ingredients")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteRecipe)
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(dataStore: dataStore, isPresented: $showingAddRecipe)
            }
        }
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        offsets.forEach { index in
            dataStore.deleteRecipe(at: index)
        }
    }
}

struct AddRecipeView: View {
    @ObservedObject var dataStore: RecipeDataStore
    @Binding var isPresented: Bool
    @State private var recipeName = ""
    @State private var selectedIngredients: Set<UUID> = []
    @State private var instructions: String = ""
    @State private var newIngredientName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Name") {
                    TextField("Enter recipe name", text: $recipeName)
                }
                
                Section("Instructions") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 120)
                }
                
                Section("Ingredients") {
                    HStack {
                        TextField("New ingredient", text: $newIngredientName)
                        Button {
                            let trimmed = newIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            dataStore.addIngredient(Ingredient(name: trimmed))
                            newIngredientName = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    List(dataStore.availableIngredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            if selectedIngredients.contains(ingredient.id) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedIngredients.contains(ingredient.id) {
                                selectedIngredients.remove(ingredient.id)
                            } else {
                                selectedIngredients.insert(ingredient.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let selectedRecipeIngredients = dataStore.availableIngredients.filter { selectedIngredients.contains($0.id) }
                        let newRecipe = Recipe(name: recipeName, ingredients: selectedRecipeIngredients, instructions: instructions)
                        dataStore.addRecipe(newRecipe)
                        isPresented = false
                    }
                    .disabled(recipeName.isEmpty || selectedIngredients.isEmpty)
                }
            }
        }
    }
}

struct EditRecipeView: View {
    @ObservedObject var dataStore: RecipeDataStore
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss
    @State private var recipeName: String = ""
    @State private var selectedIngredients: Set<UUID> = []
    @State private var instructions: String = ""
    @State private var editingNewIngredientName: String = ""
    
    var body: some View {
        Form {
            Section("Recipe Name") {
                TextField("Recipe name", text: $recipeName)
            }
            
            Section("Instructions") {
                TextEditor(text: $instructions)
                    .frame(minHeight: 120)
            }
            
            Section("Ingredients") {
                HStack {
                    TextField("New ingredient", text: $editingNewIngredientName)
                    Button {
                        let trimmed = editingNewIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        dataStore.addIngredient(Ingredient(name: trimmed))
                        editingNewIngredientName = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                
                List(dataStore.availableIngredients) { ingredient in
                    HStack {
                        Text(ingredient.name)
                        Spacer()
                        if selectedIngredients.contains(ingredient.id) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedIngredients.contains(ingredient.id) {
                            selectedIngredients.remove(ingredient.id)
                        } else {
                            selectedIngredients.insert(ingredient.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Recipe")
        .onAppear {
            recipeName = recipe.name
            selectedIngredients = Set(recipe.ingredients.map { $0.id })
            instructions = recipe.instructions
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let selectedRecipeIngredients = dataStore.availableIngredients.filter { selectedIngredients.contains($0.id) }
                    var updatedRecipe = recipe
                    updatedRecipe.name = recipeName
                    updatedRecipe.ingredients = selectedRecipeIngredients
                    updatedRecipe.instructions = instructions
                    dataStore.updateRecipe(updatedRecipe)
                    dismiss()
                }
                .disabled(recipeName.isEmpty || selectedIngredients.isEmpty)
            }
        }
    }
}

#Preview {
    RecipesView(dataStore: RecipeDataStore())
}
