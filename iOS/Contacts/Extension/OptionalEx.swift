//
//  OptionalEx.swift
//  Contacts
//
//  Created by TonnyLi on 24/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension Optional {
    
    typealias Decorator = (Wrapped) -> Void
    
    @discardableResult
    func ifSome(_ decorator: Decorator) -> Self {
        
        self.flatMap(decorator)
        
        return self
    }
}
