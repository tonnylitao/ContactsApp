//  Box.swift
//  Contacts
//
//  Created by TonnyLi on 19/03/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation

class ValueWrapper<T> {
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    typealias Listener = (T) -> ()
    private var listener: Listener?
    
    func observe(listener: Listener?) {
        self.listener = listener
    }
}

