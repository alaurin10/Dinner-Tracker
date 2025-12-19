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
    @State private var showingEditSheet = false
    @State private var ingredientBeingEdited: Ingredient? = nil
    @State private var editedIngredientName: String = ""
    
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
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                Button {
                                    if let idx = dataStore.availableIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        dataStore.deleteIngredient(at: idx)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                        .imageScale(.medium)
                                }
                                .buttonStyle(.borderless)
                                .contentShape(Rectangle())
                                .accessibilityLabel("Delete \(ingredient.name)")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                ingredientBeingEdited = ingredient
                                editedIngredientName = ingredient.name
                                showingEditSheet = true
                            }
                        }
                        .onDelete(perform: deleteIngredient)
                    }
                }
            }
            .navigationTitle("Ingredients")
            .sheet(isPresented: $showingEditSheet) {
                NavigationStack {
                    Form {
                        Section("Edit Ingredient") {
                            TextField("Ingredient name", text: $editedIngredientName)
                                .submitLabel(.done)
                        }
                    }
                    .navigationTitle("Edit Ingredient")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingEditSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let trimmed = editedIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if let ingredient = ingredientBeingEdited,
                                   !trimmed.isEmpty,
                                   let idx = dataStore.availableIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                    var updated = ingredient
                                    updated.name = trimmed
                                    dataStore.availableIngredients[idx] = updated
                                    // Persist the change
                                    // Using existing save path by triggering setter side-effects via a replace
                                }
                                showingEditSheet = false
                            }
                            .disabled(editedIngredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
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
