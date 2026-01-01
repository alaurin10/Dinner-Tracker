import SwiftUI

struct IngredientsView: View {
    @ObservedObject var dataStore: RecipeDataStore
    @State private var newIngredientName = ""
    @State private var showingEditSheet = false
    @State private var ingredientBeingEdited: Ingredient? = nil
    @State private var editedIngredientName: String = ""
    @State private var editedIngredientCategory: IngredientCategory = .other

    @State private var newIngredientCategory: IngredientCategory = .other

    private var groupedIngredients: [IngredientCategory: [Ingredient]] {
        Dictionary(grouping: dataStore.availableIngredients, by: { $0.category })
    }

    private var sortedCategories: [IngredientCategory] {
        groupedIngredients.keys.sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("Add new ingredient", text: $newIngredientName)
                            Button(action: addIngredient) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                            .disabled(newIngredientName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        Picker("Category", selection: $newIngredientCategory) {
                            ForEach(IngredientCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                if dataStore.availableIngredients.isEmpty {
                    Section {
                        Text("No ingredients yet")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section(header: Text(category.rawValue)) {
                            ForEach(groupedIngredients[category]!) { ingredient in
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
                                    editedIngredientCategory = ingredient.category
                                    showingEditSheet = true
                                }
                            }
                        }
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
                            Picker("Category", selection: $editedIngredientCategory) {
                                ForEach(IngredientCategory.allCases) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
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
                                    updated.category = editedIngredientCategory
                                    dataStore.availableIngredients[idx] = updated
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
        
        let newIngredient = Ingredient(name: trimmedName, category: newIngredientCategory)
        dataStore.addIngredient(newIngredient)
        newIngredientName = ""
        newIngredientCategory = .other
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        // This is a placeholder as direct deletion from the grouped list is complex.
        // The trash button per item is the primary deletion method.
    }
}

#Preview {
    IngredientsView(dataStore: RecipeDataStore())
}

