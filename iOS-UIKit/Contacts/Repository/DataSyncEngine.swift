//  DataSyncManager.swift
//  Contacts
//
//  Created by TonnyLi on 8/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

import Foundation
import CoreData

class DataSyncEngine {
    
    var container: NSPersistentContainer!
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func sync<Remote: RemoteEntity>(remoteData: [Remote], offset: Int, isFullFilled: Bool, completion: @escaping (Error?) -> ()) where Remote.Entity: NSManagedObject {

        container.performBackgroundTask { context in
            var err: Error?
            do {
                if remoteData.isEmpty {
                    try self.batchDelete(type: Remote.self, decoration: { fetchRequest in
                        fetchRequest.fetchOffset = offset
                    }, in: context)
                }else {
                    try self.deleteOrInsertOrUpdate(with: remoteData, isFullFilled: isFullFilled, in: context)
                    
                    if context.hasChanges {
                        try context.save()
                    }
                }
            }catch {
                err = error
            }
            
            DispatchQueue.main.async {
                completion(err)
            }
        }
    }
    
    private func deleteOrInsertOrUpdate<Remote: RemoteEntity>(with remoteList: [Remote], isFullFilled: Bool, in context: NSManagedObjectContext) throws where Remote.Entity: NSManagedObject {
        guard !remoteList.isEmpty else { fatalError() }
        
        let key = Remote.Entity.primaryKeyName
        let ids = remoteList.map(\.uniqueId)
        
        // batch delete
        var predicates = [NSPredicate]()
        
        if !isFullFilled {
            predicates.append(NSPredicate(format: "%K > %d", Remote.Entity.primaryKeyName, ids.last!))
        }
        
        if remoteList.count > 1 {
            let (min, max) = (ids.first!, ids.last!)
            predicates.append(NSPredicate(format: "%K > %d AND %K < %d AND NOT %K IN %@", key, min, key, max, key, ids))
        }
        
        if !predicates.isEmpty {
            try batchDelete(type: Remote.self, decoration: { fetchRequest in
                fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            }, in: context)
        }
        
        // find-or-create
        let fetchRequest = Remote.Entity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", key, ids)
        let existed = try context.fetch(fetchRequest) as! [Remote.Entity]
        
        let idEntityMapping = existed.reduce(into: [:]) { $0[$1.uniqueId] = $1 }
        
        var updateCount = 0
        remoteList.forEach { item in
            if let entity = idEntityMapping[item.uniqueId] {
                // update
                if item.importInto(entity) {
                    updateCount += 1
                }
            }else {
                // create
                let entity = Remote.Entity(context: context)
                item.importInto(entity)
                context.insert(entity)
            }
        }
        
        print("sync update", updateCount)
        print("sync insert", remoteList.filter { idEntityMapping[$0.uniqueId] == nil } .count)
    }
    
    private func batchDelete<Remote: RemoteEntity>(type: Remote.Type, decoration: (NSFetchRequest<NSFetchRequestResult>) -> (), in context: NSManagedObjectContext) throws {
        if container.persistentStoreDescriptions.first?.type == NSInMemoryStoreType { return }
        
        let fetchRequest = Remote.Entity.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Remote.Entity.primaryKeyName, ascending: true)]
        
        decoration(fetchRequest)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
        
        var count = 0
        if let ids = result?.result as? [NSManagedObjectID], !ids.isEmpty {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [self.viewContext])
            count = ids.count
        }
        
        print("syc delete", count, fetchRequest.predicate as Any)
    }
}
