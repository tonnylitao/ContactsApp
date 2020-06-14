//
//  SegmentFilter.swift
//  Contacts
//
//  Created by TonnyLi on 24/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

enum SegmentFilter {
    case all
    case byNationality(String)
}

extension SegmentFilter {
    
    var predicate: NSPredicate? {
        switch self {
        case .all:
            return nil
        case .byNationality(let countryCode):
            return NSPredicate(format: "nationality == %@", countryCode)
        }
    }
    
    var apiParams: [String: String] {
        switch self {
        case .all:
            return [:]
        case .byNationality(let countryCode):
            return ["nat": countryCode]
        }
    }
}

extension SegmentFilter: Equatable {}
