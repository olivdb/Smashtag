//
//  RecentSearches.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 20/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation

struct RecentSearches {
    private static let defaults = UserDefaults.standard
    private static let key = "RecentSearches"
    private static let limit = 100
    
    static private(set) var searches: [String] {
        get { return (defaults.object(forKey: key) as? [String]) ?? [] }
        set { defaults.set(newValue, forKey: key) }
    }
    
    static func add(_ term: String) {
        guard !term.isEmpty else { return }
        var newSearches = searches.filter { $0.caseInsensitiveCompare(term) != .orderedSame }
        newSearches.insert(term, at: 0)
        while newSearches.count > limit {
            newSearches.removeLast()
        }
        searches = newSearches
    }
    
    static func removeAt(_ index: Int) {
        var newSearches = searches
        if index < newSearches.count {
            newSearches.remove(at: index)
            searches = newSearches
        }
    }
}
