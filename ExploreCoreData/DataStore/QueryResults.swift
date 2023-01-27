//
//  QueryResults.swift
//  ExploreCoreData
//
//  Created by Boyd Timothy on 1/16/23.
//  Based on: https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/
//

import CoreData

struct QueryResults<T: Queryable>: RandomAccessCollection {
    private let results: NSArray

    internal init(results: NSArray = NSArray()) {
        self.results = results
    }

    var count: Int { results.count }
    var startIndex: Int { 0 }
    var endIndex: Int { count }

    subscript(position: Int) -> T {
        let object = results.object(at: position) as! T.Filter.ResultType
        return T(result: object)
    }
}
