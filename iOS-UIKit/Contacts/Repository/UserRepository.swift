//  UserRepository.swift
//  Contacts
//
//  Created by TonnyLi on 4/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation

protocol UserRepository {
    
    /*
     pageIndex: start from 1
     id is asc order in both core data and http api
     */
    func fetchUsers(pageIndex: Int, pageSize: Int, completion: @escaping ResultCompletion<[RemoteUser]>)
}

class UserRepositoryImpl: UserRepository {
    
    var remoteDataSource: RemoteUserDataSource!
    var dataSyncEngine: DataSyncEngine!
    
    init(remoteDataSource: RemoteUserDataSource, dataSyncEngine: DataSyncEngine) {
        self.remoteDataSource = remoteDataSource
        self.dataSyncEngine = dataSyncEngine
    }
    
    func fetchUsers(pageIndex: Int, pageSize: Int, completion: @escaping ResultCompletion<[RemoteUser]>) {
        
        remoteDataSource.fetchUsers(pageIndex: pageIndex, pageSize: pageSize, completion: { [weak self] (result) in
            guard let self = self else { return }
            
            if case .failure(_) = result {
                completion(result)
                return
            }
            
            let remoteData = try! result.get()
            self.dataSyncEngine.sync(from: remoteData, offset: (pageIndex-1) * pageSize, isFullFilled: remoteData.count == pageSize) { err in
                if let err = err {
                    completion(.failure(.coredata(err.localizedDescription)))
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
            let newResult = result.map { $0.unsafeBuildFakeIds(pageIndex) }
            completion(newResult)
        }
    }
}
