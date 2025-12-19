//
//  RecipesView.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI
import PhotosUI

func imageFromData(_ data: Data?) -> Image? {
    guard let data = data else { return nil }
    #if os(iOS)
    if let uiImage = UIImage(data: data) {
        return Image(uiImage: uiImage)
    }
    #endif
    return nil
}

struct RecipesView: View {
    @ObservedObject var dataStore: RecipeDataStore
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataStore.recipes) { recipe in
                    NavigationLink(destination: EditRecipeView(dataStore: dataStore, recipe: recipe)) {
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
                                Text("\(recipe.ingredients.count) ingredients")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
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
    @State private var recipeIngredients: [RecipeIngredient] = []
    @State private var instructions: String = ""
    @State private var newIngredientName: String = ""
    @State private var newIngredientQuantity: String = ""
    @State private var newIngredientUnit: CookingUnit = .none
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    private func addIngredient() {
        let trimmed = newIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recipeIngredients.append(RecipeIngredient(name: trimmed, quantity: newIngredientQuantity, unit: newIngredientUnit))
        newIngredientName = ""
        newIngredientQuantity = ""
        newIngredientUnit = .none
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Image") {
                    VStack(spacing: 12) {
                        if let image = imageFromData(selectedImageData) {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .cornerRadius(8)
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "photo.fill")
                                        .foregroundStyle(.gray)
                                )
                        }
                        
                        PhotosPicker(selection: $selectedImageItem, matching: .images) {
                            Label("Select Image", systemImage: "photo")
                        }
                        .onChange(of: selectedImageItem) { _, newValue in
                            Task {
                                if let data = try await newValue?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                
                Section("Recipe Name") {
                    TextField("Enter recipe name", text: $recipeName)
                }
                
                Section("Instructions") {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 120)
                }
                
                Section("Ingredients Needed") {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Ingredient", text: $newIngredientName)
                            .onSubmit { addIngredient() }
                            .submitLabel(.done)
                        HStack(spacing: 8) {
                            TextField("Quantity", text: $newIngredientQuantity)
                                .frame(maxWidth: 80)
                            Picker("", selection: $newIngredientUnit) {
                                ForEach(CookingUnit.allCases, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .frame(maxWidth: 100)
                            Spacer()
                            Button {
                                addIngredient()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.borderless)
                            .contentShape(Rectangle())
                        }
                    }
                    
                    ForEach(recipeIngredients, id: \.self) { ingredient in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ingredient.name)
                                    .font(.body)
                                if !ingredient.quantity.isEmpty {
                                    HStack(spacing: 2) {
                                        Text(ingredient.quantity)
                                        Text(ingredient.unit.rawValue)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button(action: {
                                recipeIngredients.removeAll { $0 == ingredient }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
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
                        let newRecipe = Recipe(name: recipeName, recipeIngredients: recipeIngredients, instructions: instructions, imageData: selectedImageData)
                        dataStore.addRecipe(newRecipe)
                        isPresented = false
                    }
                    .disabled(recipeName.isEmpty)
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
    @State private var recipeIngredients: [RecipeIngredient] = []
    @State private var instructions: String = ""
    @State private var newIngredientName: String = ""
    @State private var newIngredientQuantity: String = ""
    @State private var newIngredientUnit: CookingUnit = .none
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var editingIndex: Int? = nil
    @State private var editingName: String = ""
    @State private var editingQuantity: String = ""
    @State private var editingUnit: CookingUnit = .none

    private func addIngredient() {
        let trimmed = newIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recipeIngredients.append(RecipeIngredient(name: trimmed, quantity: newIngredientQuantity, unit: newIngredientUnit))
        newIngredientName = ""
        newIngredientQuantity = ""
        newIngredientUnit = .none
    }
    
    private func startEditing(at index: Int) {
        editingIndex = index
        editingName = recipeIngredients[index].name
        editingQuantity = recipeIngredients[index].quantity
        editingUnit = recipeIngredients[index].unit
    }
    
    private func saveEdit() {
        guard let index = editingIndex else { return }
        recipeIngredients[index].name = editingName
        recipeIngredients[index].quantity = editingQuantity
        recipeIngredients[index].unit = editingUnit
        editingIndex = nil
    }
    
    private func cancelEdit() {
        editingIndex = nil
    }
    
    var body: some View {
        Form {
            Section("Recipe Image") {
                VStack(spacing: 12) {
                    if let image = imageFromData(selectedImageData) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .clipped()
                    } else if let image = imageFromData(recipe.imageData) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .clipped()
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo.fill")
                                    .foregroundStyle(.gray)
                            )
                    }
                    
                    PhotosPicker(selection: $selectedImageItem, matching: .images) {
                        Label("Select Image", systemImage: "photo")
                    }
                    .onChange(of: selectedImageItem) { _, newValue in
                        Task {
                            if let data = try await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
            }
            
            Section("Recipe Name") {
                TextField("Recipe name", text: $recipeName)
            }
            
            Section("Instructions") {
                TextEditor(text: $instructions)
                    .frame(minHeight: 120)
            }
            
            Section("Ingredients Needed") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Ingredient", text: $newIngredientName)
                        .onSubmit { addIngredient() }
                        .submitLabel(.done)
                    HStack(spacing: 8) {
                        TextField("Quantity", text: $newIngredientQuantity)
                            .frame(maxWidth: 80)
                        Picker("", selection: $newIngredientUnit) {
                            ForEach(CookingUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .frame(maxWidth: 100)
                        Spacer()
                        Button {
                            addIngredient()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.borderless)
                        .contentShape(Rectangle())
                    }
                }
                
                ForEach(Array(recipeIngredients.enumerated()), id: \.offset) { index, ingredient in
                    if editingIndex == index {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Ingredient", text: $editingName)
                            HStack(spacing: 8) {
                                TextField("Quantity", text: $editingQuantity)
                                    .frame(maxWidth: 80)
                                Picker("", selection: $editingUnit) {
                                    ForEach(CookingUnit.allCases, id: \.self) { unit in
                                        Text(unit.displayName).tag(unit)
                                    }
                                }
                                .frame(maxWidth: 100)
                            }
                            HStack(spacing: 12) {
                                Button("Delete") {
                                    recipeIngredients.remove(at: index)
                                    editingIndex = nil
                                }
                                .foregroundStyle(.red)
                                Spacer()
                                Button("Cancel") {
                                    cancelEdit()
                                }
                                .foregroundStyle(.gray)
                                Button("Save") {
                                    saveEdit()
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name)
                                .font(.body)
                            if !ingredient.quantity.isEmpty {
                                HStack(spacing: 2) {
                                    Text(ingredient.quantity)
                                    Text(ingredient.unit.rawValue)
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            startEditing(at: index)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Recipe")
        .onAppear {
            recipeName = recipe.name
            recipeIngredients = recipe.recipeIngredients
            instructions = recipe.instructions
            selectedImageData = recipe.imageData
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
                    var updatedRecipe = recipe
                    updatedRecipe.name = recipeName
                    updatedRecipe.recipeIngredients = recipeIngredients
                    updatedRecipe.instructions = instructions
                    updatedRecipe.imageData = selectedImageData ?? recipe.imageData
                    dataStore.updateRecipe(updatedRecipe)
                    dismiss()
                }
                .disabled(recipeName.isEmpty)
            }
        }
    }
}

#Preview {
    RecipesView(dataStore: RecipeDataStore())
}
