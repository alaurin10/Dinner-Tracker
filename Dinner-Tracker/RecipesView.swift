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
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingIngredientEditor = false
    @State private var editingIngredientIndex: Int? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Recipe Image Section
                    VStack(spacing: 12) {
                        if let image = imageFromData(selectedImageData) {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .cornerRadius(12)
                                .clipped()
                        } else if let image = imageFromData(recipe.imageData) {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 240)
                                .overlay(
                                    Image(systemName: "photo.fill")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 48))
                                )
                        }
                        
                        PhotosPicker(selection: $selectedImageItem, matching: .images) {
                            Label("Change Image", systemImage: "photo.badge.checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .cornerRadius(8)
                        }
                        .onChange(of: selectedImageItem) { _, newValue in
                            Task {
                                if let data = try await newValue?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        // Recipe Name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Recipe Name", systemImage: "text.book")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.gray)
                            TextField("Enter recipe name", text: $recipeName)
                                .font(.system(size: 18, weight: .semibold))
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Instructions", systemImage: "list.number")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.gray)
                            TextEditor(text: $instructions)
                                .font(.system(size: 16))
                                .frame(minHeight: 140)
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .scrollContentBackground(.hidden)
                        }
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Ingredients", systemImage: "list.bullet.clipboard")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.gray)
                                Spacer()
                                Button(action: { showingIngredientEditor = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.blue)
                                }
                            }
                            
                            if recipeIngredients.isEmpty {
                                Text("No ingredients added yet")
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 24)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(Array(recipeIngredients.enumerated()), id: \.offset) { index, ingredient in
                                        IngredientRow(
                                            ingredient: ingredient,
                                            onEdit: {
                                                editingIngredientIndex = index
                                                showingIngredientEditor = true
                                            },
                                            onDelete: {
                                                recipeIngredients.remove(at: index)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Edit Recipe")
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
            .sheet(isPresented: $showingIngredientEditor) {
                if let index = editingIngredientIndex {
                    IngredientEditorView(
                        ingredient: $recipeIngredients[index],
                        isPresented: $showingIngredientEditor,
                        onDelete: {
                            recipeIngredients.remove(at: index)
                            editingIngredientIndex = nil
                        }
                    )
                } else {
                    IngredientEditorView(
                        ingredient: .constant(RecipeIngredient(name: "", quantity: "", unit: .none)),
                        isPresented: $showingIngredientEditor,
                        onAdd: { newIngredient in
                            recipeIngredients.append(newIngredient)
                            editingIngredientIndex = nil
                        }
                    )
                }
            }
            .onChange(of: showingIngredientEditor) { _, isShowing in
                if !isShowing {
                    editingIngredientIndex = nil
                }
            }
        }
        .onAppear {
            recipeName = recipe.name
            recipeIngredients = recipe.recipeIngredients
            instructions = recipe.instructions
            selectedImageData = recipe.imageData
        }
    }
}

struct IngredientRow: View {
    let ingredient: RecipeIngredient
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.system(size: 16, weight: .semibold))
                if !ingredient.quantity.isEmpty {
                    HStack(spacing: 4) {
                        Text(ingredient.quantity)
                        Text(ingredient.unit.rawValue)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.blue)
                }
                .contentShape(Rectangle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.red)
                }
                .contentShape(Rectangle())
            }
        }
        .padding(12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

struct IngredientEditorView: View {
    @Binding var ingredient: RecipeIngredient
    @Binding var isPresented: Bool
    var onDelete: (() -> Void)? = nil
    var onAdd: ((RecipeIngredient) -> Void)? = nil
    
    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var unit: CookingUnit = .none
    
    let isEditing: Bool
    
    init(ingredient: Binding<RecipeIngredient>, isPresented: Binding<Bool>, onDelete: (() -> Void)? = nil, onAdd: ((RecipeIngredient) -> Void)? = nil) {
        self._ingredient = ingredient
        self._isPresented = isPresented
        self.onDelete = onDelete
        self.onAdd = onAdd
        self.isEditing = onDelete != nil
        
        _name = State(initialValue: ingredient.wrappedValue.name)
        _quantity = State(initialValue: ingredient.wrappedValue.quantity)
        _unit = State(initialValue: ingredient.wrappedValue.unit)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Ingredient Name") {
                    TextField("e.g., Olive Oil", text: $name)
                }
                
                Section("Quantity") {
                    TextField("e.g., 2", text: $quantity)
                        .keyboardType(.decimalPad)
                }
                
                Section("Unit") {
                    Picker("Unit", selection: $unit) {
                        ForEach(CookingUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                }
                
                if isEditing && onDelete != nil {
                    Section {
                        Button(role: .destructive, action: {
                            onDelete?()
                            isPresented = false
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Ingredient")
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Ingredient" : "Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        if isEditing {
                            ingredient.name = name
                            ingredient.quantity = quantity
                            ingredient.unit = unit
                        } else {
                            onAdd?(RecipeIngredient(name: name, quantity: quantity, unit: unit))
                        }
                        isPresented = false
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    RecipesView(dataStore: RecipeDataStore())
}
