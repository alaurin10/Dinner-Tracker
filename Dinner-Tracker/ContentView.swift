//
//  ContentView.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataStore: RecipeDataStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AvailableRecipesView(dataStore: dataStore)
                .tabItem {
                    Label("Available", systemImage: "fork.knife")
                }
                .tag(0)
            
            RecipesView(dataStore: dataStore)
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
                .tag(1)
            
            IngredientsView(dataStore: dataStore)
                .tabItem {
                    Label("Ingredients", systemImage: "list.bullet")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(RecipeDataStore())
}
