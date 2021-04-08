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
    
    var lastIdInPreviousPage: TypeOfId?
    var container: NSPersistentContainer!
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func sync(remoteData: [RemoteUser], isFullPagination: Bool, completion: @escaping (AppError?) -> ()) {
        container.performBackgroundTask { context in
            do {
                if !isFullPagination {
                    // batch delete
                    let maxId = remoteData.last?.uniqueId ?? self.lastIdInPreviousPage
                    let predicate = maxId != nil ? NSPredicate(format: "id > %d", maxId!) : nil
                    
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
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
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
            let minId = ids.first!
            let maxId = ids.last!
            
            let predicate = NSPredicate(format: "id >= %d AND id <= %d AND NOT id IN %@", minId, maxId, ids)
            let count = try batchDeleteWith(predicate: predicate, context: context)
            
            print("syc delete", "\(count) entity which in [\(minId)...\(maxId)] and not in \(ids)")
        }
        
        // fetch
        let toUpdateFetchRequest = NSFetchRequest<DBUser>(entityName: "User")
        toUpdateFetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        
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
