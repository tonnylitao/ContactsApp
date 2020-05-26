//
//  NSPredicateEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension NSPredicate {
    
    static func && (lhs: NSPredicate, rhs: @autoclosure () throws -> NSPredicate?) rethrows -> NSPredicate {
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [lhs, try rhs()].compactMap { $0 })
    }
    
    static func || (lhs: NSPredicate, rhs: @autoclosure () throws -> NSPredicate?) rethrows -> NSPredicate {
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: [lhs, try rhs()].compactMap { $0 })
    }
}
