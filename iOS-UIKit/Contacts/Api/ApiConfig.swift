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
    
    /* disable github text search */
    static let apiHost = "\u{68}\u{74}\u{74}\u{70}\u{73}\u{3a}\u{2f}\u{2f}\u{72}\u{61}\u{6e}\u{64}\u{6f}\u{6d}\u{75}\u{73}\u{65}\u{72}\u{2e}\u{6d}\u{65}\u{2f}"
    
    static let defaultSeed = "contacts" //to get same data from api
    
    static let defaultPagingSize = 20
    
    static let firstPageIndex: PageIndex = 1
}

enum ApiPath: String {
    case users = "/api"
}

