//
//  DBEntity.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData
import SwiftInKotlinStyle

/*
    two protocols connect differeent categories
 
             RemoteEntity    <------->    DBEntity
                  /                           \
                 /                             \
    Decodable data from api               NSManagedObject
        api Message                      Core data Message
        api Comment                      Core data Comment
              .                                .
              .                                .
 
    protocol RemoteEntity {
         var uniqueId: TypeOfId { get }
 
         associatedtype Entity: DBEntity
         func importInto(_ entiry: DBEntity)
    }
 */

protocol DBEntity: class {
    var uniqueId: TypeOfId { get }
}
