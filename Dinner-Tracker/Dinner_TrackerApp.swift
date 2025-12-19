//
//  Dinner_TrackerApp.swift
//  Dinner-Tracker
//
//  Created by Andrew Laurin on 12/18/25.
//

import SwiftUI

@main
struct Dinner_TrackerApp: App {
    @StateObject private var dataStore = RecipeDataStore()

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
        .windowStyle(.automatic)
        #else
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
        #endif
    }
}
