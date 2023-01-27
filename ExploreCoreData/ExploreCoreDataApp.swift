//
//  ExploreCoreDataApp.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/27/23.
//

import SwiftUI

@main
struct ExploreCoreDataApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.dataStore, DataStore.shared)
        }
    }
}
