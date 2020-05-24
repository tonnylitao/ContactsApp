//
//  ApiConfig.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

typealias PageIndex = Int

struct ApiConfig {
    
    static let defaultSeed = "contacts" //to get same data from api
    
    static let defaultPagingSize = 20
    
    static let firstPageIndex: PageIndex = 1
}

enum ApiPath: String {
    case users = "/api"
}

