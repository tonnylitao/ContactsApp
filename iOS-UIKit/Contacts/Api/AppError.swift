//
//  Error.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import Alamofire

enum AppError: Error, Equatable {
    
    case networking(String)
    case invalidApiPath
    case invalidResponse
    case invalidData
    case decoding
    
    case coredata(String)
    case other(String)
    
}

extension AppError {
    var humanReadableMessage: String {
        switch self {
        case .networking:
            return "😂\nBusy\n Network"
        default:
            return "🍺\nCome back\n later"
        }
    }
    
    var isCoreDataError: Bool {
        switch self {
        case .coredata:
           return true
        default:
           return false
        }
    }
}
