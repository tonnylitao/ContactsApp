//
//  RemoteUserResponse.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

struct RemoteUserResponse: Decodable, CustomStringConvertible {
    
    var results: [RemoteUser]
    let info: PageInfo

    struct PageInfo: Decodable {
        let seed: String
        let results, page: Int
        let version: String
    }
    
    var description: String {
        return "{\(results)}"
    }
    
    /*
     important
     for local db be consistency with the remote server
     the results in api's order should be same as NSFetchedResultsController
     but unfortunately, the randomuser.me api does not support sort logic,
     so I create the fakeId locally only for trying to keep consistency
    */
    func unsafeBuildFakeIds(_ pageIndex: PageIndex) -> [RemoteUser] {
        
        return results.enumerated().map { (index, item) -> RemoteUser in
            var temp = item
            temp.fakeId = TypeOfId(index + (pageIndex-1) * ApiConfig.defaultPagingSize + 1)
            return temp
        }
    }
}
