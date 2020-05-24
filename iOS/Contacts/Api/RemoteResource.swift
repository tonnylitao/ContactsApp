//
//  API.swift
//  Contacts
//
//  Created by TonnySunm on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

protocol RemoteResource {
    static var path: ApiPath { get }
}

typealias DecodableRemoteResource = Decodable & RemoteResource

/*
 Admin.get(url) { admin in ... }
 
 [Admin].get(url) { adminInArray in ... }
 */
extension Array: RemoteResource where Element: DecodableRemoteResource {
    static var path: ApiPath {
        return Element.path
    }
}
