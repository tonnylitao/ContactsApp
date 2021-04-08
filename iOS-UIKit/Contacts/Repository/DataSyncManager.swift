//  DataSyncManager.swift
//  Contacts
//
//  Created by TonnyLi on 8/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation
import CoreData

class DataSyncManager {
    
    var container: NSPersistentContainer!
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    var lastIdInPreviousPage: TypeOfId?
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func sync(remoteData: [RemoteUser], isFullPagination: Bool, completion: @escaping (AppError?) -> ()) {
        container.performBackgroundTask { context in
            do {
                if !isFullPagination {
                    // batch delete
                    let maxId = remoteData.last?.uniqueId ?? self.lastIdInPreviousPage
                    let predicate = maxId != nil ? NSPredicate(format: "%K > %d", #keyPath(DBUser.uniqueId), maxId!) : nil
                    
                    let count = try self.batchDeleteWith(predicate: predicate, context: context)
                    print("syc delete", count)
                }
                
                if !remoteData.isEmpty {
                    try self.updateOrInsertOrDeleteIn(remoteData: remoteData, context: context)
                }
                
                if context.hasChanges {
                    try context.save()
                }
                
                DispatchQueue.main.async {
                    completion(nil)
                }
            }catch {
                DispatchQueue.main.async {
                    completion(.coredata(error.localizedDescription))
                }
            }
        }
    }
    
    private func batchDeleteWith(predicate: NSPredicate?, context: NSManagedObjectContext) throws -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        if let predicate = predicate {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(DBUser.uniqueId), ascending: true)]
            fetchRequest.predicate = predicate
        }
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
        
        var count = 0
        if let ids = result?.result as? [NSManagedObjectID], !ids.isEmpty {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [self.viewContext])
            
            count = ids.count
        }
        
        return count
    }
    
    private func updateOrInsertOrDeleteIn(remoteData: [RemoteUser], context: NSManagedObjectContext) throws {
        let ids = remoteData.map { $0.uniqueId }
        
        // batch delete
        if remoteData.count > 1 {
            let (minId, maxId) = (ids.first!, ids.last!)
            
            let key = #keyPath(DBUser.uniqueId)
            let predicate = NSPredicate(format: "%K >= %d AND %K <= %d AND NOT %K IN %@", key, minId, key, maxId, key, ids)
            let count = try batchDeleteWith(predicate: predicate, context: context)
            
            print("syc delete", "\(count) entity which in [\(minId)...\(maxId)] and not in \(ids)")
        }
        
        // fetch
        let toUpdateFetchRequest = NSFetchRequest<DBUser>(entityName: "User")
        toUpdateFetchRequest.predicate = NSPredicate(format: "%K IN %@", #keyPath(DBUser.uniqueId), ids)
        
        let existedEntity = try context.fetch(toUpdateFetchRequest)
        let existedIdEntityMapping: [TypeOfId: DBUser] = existedEntity.dictionaryBy { $0.uniqueId }
        
        var updatedIds = [TypeOfId]()
        remoteData.forEach { remoteUser in
            let existed = existedIdEntityMapping[remoteUser.uniqueId]
            if let entity = existed {
                // update
                if remoteUser.importInto(entity) {
                    updatedIds.append(remoteUser.uniqueId)
                }
            }else {
                // insert
                let entity = DBUser(context: context)
                remoteUser.importInto(entity)
                
                context.insert(entity)
            }
        }
        
        print("sync insert", remoteData.compactMap { existedIdEntityMapping[$0.uniqueId] == nil ? $0.uniqueId : nil })
        print("sync update", updatedIds)
    }
}
