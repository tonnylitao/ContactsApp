//
//  ResultEx.swift
//  Contacts
//
//  Created by TonnyLi on 12/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

/*
 get rid of switch case
 
 switch result {
 case .success(let data):
 case .failure(let error):
 }
 
 */

extension Result {
    
    @discardableResult
    func onSuccess(_ handler: (Success) -> ()) -> Self {
        if case let .success(value) = self { handler(value) }
        return self
    }
    
    @discardableResult
    func onFailure(_ handler: (Failure) -> ()) -> Self {
        if case let .failure(error) = self { handler(error) }
        return self
    }
}

extension Result {
    
    var wrappedResult: Success? {
        if case let .success(result) = self {
            return result
        }
        
        return nil
    }
    
    var error: AppError? {
        if case let .failure(error) = self {
            return error as? AppError
        }
        
        return nil
    }
}
