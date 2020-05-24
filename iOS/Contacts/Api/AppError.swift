//
//  Error.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

enum AppError: Error {
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
            return "🍺\nComeback\n later"
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

extension Error {
    
    var appError: AppError {
        
        if let err = self as? AppError {
            return err
        }
        
        return .other(self.localizedDescription)
    }
}
