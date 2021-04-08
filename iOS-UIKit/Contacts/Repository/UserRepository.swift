//  UserRepository.swift
//  Contacts
//
//  Created by TonnyLi on 4/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation

protocol UserRepository {
    func updateLastIdInPreviousPage(id: TypeOfId?)
    
    /*
     pageIndex: start from 1
     id is asc order in both core data and http api
     */
    func fetchUsers(pageIndex: Int, pageSize: Int, completion: @escaping ResultCompletion<[RemoteUser]>)
}

class UserRepositoryImpl: UserRepository {
    var remote: RemoteUserDataSource!
    
    var dataSyncManager: DataSyncManager!
    
    func updateLastIdInPreviousPage(id: TypeOfId?) {
        dataSyncManager.lastIdInPreviousPage = id
    }
    
    func fetchUsers(pageIndex: Int, pageSize: Int, completion: @escaping ResultCompletion<[RemoteUser]>) {
        
        remote.fetchUsers(pageIndex: pageIndex, pageSize: pageSize, completion: { [weak self] (result) in
            guard let self = self else { return }
            
            if case .failure(_) = result {
                completion(result)
                return
            }
            
            let remoteData = try! result.get()
//            if pageIndex == 2 {
//                remoteData = Array(remoteData[0..<pageSize/2])
//                remoteData.remove(at: 1)
//                var a = remoteData[2]
//                a.name = RemoteUser.Name(title: "AA", first: "B", last: "C")
//                remoteData[2] = a
//            }
            self.dataSyncManager.sync(remoteData: remoteData, isFullPagination: remoteData.count == pageSize) { err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                
                completion(.success(remoteData))
            }
        })
    }
}

protocol RemoteUserDataSource {
    func fetchUsers(pageIndex: Int, pageSize: Int, completion: @escaping ResultCompletion<[RemoteUser]>)
}

class RemoteDataSourceImpl: RemoteUserDataSource {
    
    func fetchUsers(pageIndex: Int, pageSize: Int, completion: @escaping ResultCompletion<[RemoteUser]>) {
        let url = ApiConfig.apiHost + ApiPath.users.rawValue
        
        let para: [String: Any] = ["page": "\(pageIndex)", "results": "\(pageSize)", "seed": ApiConfig.defaultSeed]
        
        RemoteUserResponse.request(url, parameters: para) { result in
            if case .success(let response) = result {
                let newArray = response.unsafeBuildFakeIds(pageIndex)
                completion(.success(newArray))
            }else {
                completion(.failure(result.error!))
            }
        }
    }
}
