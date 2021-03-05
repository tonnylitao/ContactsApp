//
//  ArrayEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension Array {
    
    func dictionaryBy<T: Hashable>(key: (Element) -> T?) -> [T: Element] {
    
        return self.reduce(into: [:], { (result, item) in
            guard let value = key(item) else { return }
            
            result[value] = item
        })
    }
}
