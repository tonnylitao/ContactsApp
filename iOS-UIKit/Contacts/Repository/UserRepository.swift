//  UserRepository.swift
//  Contacts
//
//  Created by TonnyLi on 4/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation
import CoreData

protocol UserRepository {
    func fetchUsers(offset: Int, limit: Int, completion: @escaping ResultCompletion<[RemoteUser]>)
}

class UserRepositoryImpl: UserRepository {
    var local: LocalUserDataSource!
    var remote: RemoteUserDataSource!
    
    var dataSyncManager: DataSyncManager!
    
    func fetchUsers(offset: Int, limit: Int, completion: @escaping ResultCompletion<[RemoteUser]>) {
        var localData: [User]
        do {
            localData = try local.fetchUsers(offset: offset, limit: limit)
        }catch {
            completion(.failure(.coredata(error.localizedDescription)))
            return
        }
        
        //
        remote.fetchUsers(offset: offset, limit: limit, completion: { [weak self] (result) in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            let remoteData = try! result.get()
            self.dataSyncManager.sync(offset: offset, limit: limit, localData: localData, remoteData: remoteData) { err in
                if let err = err {
                    completion(.failure(.coredata(err.localizedDescription)))
                }else {
                    completion(.success(remoteData))
                }
            }
        })
    }
}

protocol LocalUserDataSource {
    func fetchUsers(offset: Int, limit: Int) throws -> [DBUser]
}

class LocalDataSourceImpl: LocalUserDataSource {
    var context: NSManagedObjectContext!
    
    func fetchUsers(offset: Int, limit: Int) throws -> [DBUser] {
        let fetchRequest = NSFetchRequest<DBUser>(entityName: "User")
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        return try context.fetch(fetchRequest)
    }
    
}

protocol RemoteUserDataSource {
    func fetchUsers(offset: Int, limit: Int, completion: @escaping ResultCompletion<[RemoteUser]>)
}

class RemoteDataSourceImpl: RemoteUserDataSource {
    
    func fetchUsers(offset: Int, limit: Int, completion: @escaping ResultCompletion<[RemoteUser]>) {
        let url = ApiConfig.apiHost + ApiPath.users.rawValue
        
        let page = offset/limit
        let para: [String: Any] = ["page": "\(page)", "results": "\(limit)", "seed": ApiConfig.defaultSeed]
        
        RemoteUserResponse.request(url, parameters: para) { result in
            if case .success(let response) = result {
                let newArray = response.unsafeBuildFakeIds(page)
                completion(.success(newArray))
            }else {
                completion(.failure(result.error!))
            }
        }
    }
}

class DataSyncManager {
    
    var lastIdInPreviousPage: TypeOfId?
    var container: NSPersistentContainer!
    
    func sync(offset: Int, limit: Int, localData: [DBUser], remoteData: [RemoteUser], completion: @escaping (Error?) -> ()) {
        
        let count = remoteData.count
        
        if count == 0 {
            deleteAllAfter(id: lastIdInPreviousPage, completion: completion)
        }else {
            updateOrInsertOrDeleteIn(remoteData: remoteData) { [weak self] err in
                guard let self = self else { return }
                
                if let err = err {
                    completion(err)
                    return
                }
                
                if count < limit {
                    self.deleteAllAfter(id: remoteData.last!.uniqueId, completion: completion)
                }else {
                    completion(nil)
                }
            }
        }
    }
    
    private func deleteAllAfter(id: TypeOfId?, completion: @escaping (Error?) -> ()) {
        
        let viewContext = container.viewContext
        container.performBackgroundTask { (context) in
            
            var predicate: NSPredicate?
            if let id = id {
                predicate = NSPredicate(format: "id > %@", id)
            }
            
            do {
                let count = try context.batchDeleteWith(predicate: predicate, viewContext: viewContext)
                print(context.nickName, "delete: \(String(describing: predicate)) \(count)")
                
                if context.hasChanges {
                    try context.save()
                }
            }catch {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    private func updateOrInsertOrDeleteIn(remoteData: [RemoteUser], completion: @escaping (Error?) -> ()) {
        
        let viewContext = container.viewContext
        container.performBackgroundTask { context in
            let ids = remoteData.map { $0.uniqueId }
            
            let toUpdateFetchRequest = NSFetchRequest<User>(entityName: "User")
            toUpdateFetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
            
            let existedUsers: [User]
            do {
                existedUsers = try context.fetch(toUpdateFetchRequest)
            }catch {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            //
            if remoteData.count > 1 {
                let minId = ids.first!
                let maxId = ids.last!
                
                /*
                 batch delete
                 */
                let predicate = NSPredicate(format: "id >= %d AND id <= %d AND NOT id IN %@", minId, maxId, ids)
                do {
                    let count = try context.batchDeleteWith(predicate: predicate, viewContext: viewContext)
                    print(context.nickName, "delete: \(count) entity which in [\(minId)...\(maxId)] and not in \(ids)")
                }catch {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
            }
            
            /*
             insert
             */
            let existedUsersIds = Set(existedUsers.map { $0.uniqueId })
            
            for item in remoteData where !existedUsersIds.contains(item.uniqueId) {
                let entity = User(context: context)
                
                item.importInto(entity)
                context.insert(entity)
            }
            
            print(context.nickName, "insert: \(ids.filter { !existedUsersIds.contains($0) })")
            
            /*
             update
             */
            let remoteDataMapping: [TypeOfId : RemoteUser] = remoteData.dictionaryBy { $0.uniqueId }
            existedUsers.forEach { item in
                remoteDataMapping[item.uniqueId]?.importInto(item)
            }
            
            print(context.nickName, "update: \(existedUsersIds)")
            
            if context.hasChanges {
                do {
                    try context.save()
                }catch {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
}

fileprivate extension NSManagedObjectContext {
    
    func batchDeleteWith(predicate: NSPredicate?, viewContext: NSManagedObjectContext) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        fetchRequest.predicate = predicate
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        let deletedResult = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        
        var count = 0
        if let ids = deletedResult?.result as? [NSManagedObjectID], !ids.isEmpty {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [viewContext])
            
            count = ids.count
        }
        
        return count
    }

}
