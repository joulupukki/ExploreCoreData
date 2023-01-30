//
//  Contact.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/27/23.
//

import CoreData

struct Contact: Queryable, Identifiable {
    typealias Filter = ContactFilter

    let id: String
    let givenName: String
    let familyName: String?

    init(result: ManagedContact) {
        self.id = result.id ?? UUID().uuidString
        self.givenName = result.givenName ?? "Unknown"
        self.familyName = result.familyName
    }

    var displayName: String {
        var name = givenName
        if let familyName {
            name += " \(familyName)"
        }
        return name
    }
}

struct ContactFilter: QueryFilter {
    static let all = ContactFilter()

    private var filterType: FilterType = .all
    var searchString: String = ""

    private enum FilterType {
        case all
    }

    func fetchRequest(_ dataStore: DataStore) -> NSFetchRequest<ManagedContact> {
        let fetchRequest = ManagedContact.fetchRequest() as NSFetchRequest<ManagedContact>
        switch filterType {
        case .all:
            if !searchString.isEmpty {
                fetchRequest.predicate = NSPredicate(format: "givenName BEGINSWITH[cd] %@", searchString)
            } else {
                fetchRequest.predicate = NSPredicate(value: true)
            }
            fetchRequest.sortDescriptors = orderedSortDescriptors
        }
        return fetchRequest
    }

    private var orderedSortDescriptors: [NSSortDescriptor] {
        [
            NSSortDescriptor(key: "givenName", ascending: true),
            NSSortDescriptor(key: "familyName", ascending: true)
        ]
    }
}

//extension Contact: Comparable {
//    public static func < (lhs: Conversation, rhs: Conversation) -> Bool {
//
//        let sortToTop1 = lhs.shouldSortToTop
//        let sortToTop2 = rhs.shouldSortToTop
//
//        if sortToTop1 && !sortToTop2 {
//            return false
//        } else if sortToTop2 && !sortToTop1 {
//            return true
//        } else {
//            return (lhs.displayDate ?? .distantPast) < (rhs.displayDate ?? .distantPast)
//        }
//    }
//
//    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
