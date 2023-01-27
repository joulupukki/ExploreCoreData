//
//  DataStore.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/10/23.
//  Based on: https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/
//

import CoreData
import SwiftUI

class DataStore: ObservableObject {
    let container = NSPersistentContainer(name: "ExploreCoreData")

    static var shared = DataStore()

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load persistent store: \(error.localizedDescription)")
            } else {
                print("Initialized persistent store: \(description.url?.absoluteString ?? "path unknown")")
            }
        }
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}

private struct DataStoreEnvironmentKey: EnvironmentKey {
    static let defaultValue = DataStore()
}

extension EnvironmentValues {
    var dataStore: DataStore {
        get { self[DataStoreEnvironmentKey.self] }
        set { self[DataStoreEnvironmentKey.self] = newValue }
    }
}
