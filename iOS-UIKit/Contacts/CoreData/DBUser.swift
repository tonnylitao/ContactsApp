//
//  DBUser.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData
import UIKit

typealias DBUser = User

extension DBUser {

    public override func awakeFromInsert() {
        setPrimitiveValue(NSDate(), forKey: #keyPath(DBUser.createdAt))
    }
    
}

extension DBUser: DBEntity {
    
    static var primaryKeyName: String {
        return "uniqueId"
    }
    
    static var name: String {
        return "User"
    }
    
}
