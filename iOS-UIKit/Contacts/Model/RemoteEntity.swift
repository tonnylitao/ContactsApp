//
//  RemoteEntity.swift
//  Contacts
//
//  Created by TonnyLi on 22/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData

protocol RemoteEntity {
    var uniqueId: TypeOfId { get }
    
    associatedtype Entity: DBEntity
    
    @discardableResult
    func importInto(_ entiry: Entity) -> Bool
}
