//
//  DaoInAnyWhere.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension NSObject: Dao {}

extension Dao where Self: NSObject {
    
    typealias Decorator = (Self) -> Void
        
    /*
     https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/apply.html
    */
    
    @discardableResult
    func apply(_ decorators: Decorator...) -> Self {
        
        decorators.forEach {
            $0(self)
        }
        
        return self
    }
    
    @discardableResult
    func applyIf(_ condition: Bool, _ decorators: Decorator...) -> Self {
        if condition {
            decorators.forEach {
                $0(self)
            }
        }
        
        return self
    }
    
}
