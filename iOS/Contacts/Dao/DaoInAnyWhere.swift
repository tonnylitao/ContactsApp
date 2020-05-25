//
//  DaoInAnyWhere.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension Dao where Self: NSObject {
    
    typealias ObjectDecorator = (Self) -> Void
    
    @discardableResult
    func apply(_ decorators: ObjectDecorator...) -> Self {
        
        decorators.forEach { [unowned self] in
            $0(self)
        }
        
        return self
    }
    
}

extension NSObject: Dao {}
