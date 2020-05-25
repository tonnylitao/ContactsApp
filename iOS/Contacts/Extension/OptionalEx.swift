//
//  OptionalEx.swift
//  Contacts
//
//  Created by TonnyLi on 24/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension Optional {
    
    /*
     if let a = optional {
     
     }else {
     
     }
     
     switch optional {
     case .some(let a) {
     
     }
     case .none: {
     
     }
     
     --------------------------
     
     optional.ifSome {
        
     }
     
     optional.ifSome({
        $0
     }) {
     
     }
     
     */
    
    func ifSome(_ transform: (Wrapped) throws -> Void, _ else: (() throws -> ())? = nil ) rethrows -> () {
        try flatMap(transform)
        
        try `else`?()
    }
}
