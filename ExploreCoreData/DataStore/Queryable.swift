//
//  Queryable.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/10/23.
//  Based on: https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/
//

import CoreData
import SwiftUI

protocol Queryable {
    associatedtype Filter: QueryFilter
    init(result: Filter.ResultType)
}

protocol QueryFilter: Equatable {
    associatedtype ResultType: NSFetchRequestResult
    func fetchRequest(_ dataStore: DataStore) -> NSFetchRequest<ResultType>
}

@propertyWrapper
struct Query<T: Queryable>: DynamicProperty {
    @Environment(\.dataStore) private var dataStore: DataStore
    @StateObject private var core = Core()
    private let baseFilter: T.Filter

    var wrappedValue: QueryResults<T> { core.results }

    var projectedValue: Binding<T.Filter> {
        return Binding {
            core.filter ?? baseFilter
        } set: {
            if core.filter != $0 {
                core.objectWillChange.send()
                core.filter = $0
            }
        }
    }

    init(_ filter: T.Filter) {
        self.baseFilter = filter
    }

    mutating func update() {
        if core.dataStore == nil { core.dataStore = dataStore }
        if core.filter == nil { core.filter = baseFilter }
        core.fetchIfNecessary()
    }

    private class Core: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private(set) var results: QueryResults<T> = QueryResults<T>()

        var dataStore: DataStore?
        var filter: T.Filter?

        private var frc: NSFetchedResultsController<T.Filter.ResultType>?

        func executeQuery(dataStore: DataStore, filter: T.Filter) {
            let fetchRequest = filter.fetchRequest(dataStore)
            let context = dataStore.viewContext

            // You MUST leave this as an NSArray
            let results: NSArray = (try? context.fetch(fetchRequest) as NSArray) ?? NSArray()
            self.results = QueryResults(results: results)
        }

        func fetchIfNecessary() {
            guard let ds = dataStore else {
                fatalError("Attempting to execute a @Query but the DataStore is not in the environment")
            }
            guard let f = filter else {
                fatalError("Attempting to execute a @Query without a filter")
            }

            var shouldFetch = false

            let request = f.fetchRequest(ds)
            if let controller = frc {
                if controller.fetchRequest.predicate != request.predicate {
                    controller.fetchRequest.predicate = request.predicate
                    shouldFetch = true
                }
                if controller.fetchRequest.sortDescriptors != request.sortDescriptors {
                    controller.fetchRequest.sortDescriptors = request.sortDescriptors
                    shouldFetch = true
                }
            } else {
                let controller = NSFetchedResultsController(fetchRequest: request,
                                                            managedObjectContext: ds.viewContext,
                                                            sectionNameKeyPath: nil, cacheName: nil)
                controller.delegate = self
                frc = controller
                shouldFetch = true
            }

            if shouldFetch {
                try? frc?.performFetch()
                let resultsArray = (frc?.fetchedObjects as NSArray?) ?? NSArray()
                results = QueryResults(results: resultsArray)
            }
        }

        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            objectWillChange.send()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            let resultsArray = (controller.fetchedObjects as NSArray?) ?? NSArray()
            results = QueryResults(results: resultsArray)
        }
    }
}
