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
    
    lazy var newBackgroundContext: NSManagedObjectContext = {
        return container.newBackgroundContext()
    }()
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    func sync<Remote: RemoteEntity>(from remoteData: [Remote], offset: Int, isFullFilled: Bool, completion: @escaping (Error?) -> ()) where Remote.Entity: NSManagedObject {

        let context = newBackgroundContext
        
        context.perform {
            var err: Error?
            do {
                if remoteData.isEmpty {
                    try self.batchDelete(type: Remote.self, decoration: { fetchRequest in
                        fetchRequest.fetchOffset = offset
                    }, in: context)
                }else {
                    try self.sync(from: remoteData, isFullFilled: isFullFilled, in: context)
                    
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
    
    private func sync<Remote: RemoteEntity>(from remoteList: [Remote], isFullFilled: Bool, in context: NSManagedObjectContext) throws where Remote.Entity: NSManagedObject {
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
        //fix 'Multiple NSEntityDescriptions claim' when using in-memory type in unit testing
        let fetchRequest = NSFetchRequest<Remote.Entity>(entityName: Remote.Entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: key, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "%K IN %@", key, ids)
        let existed = try context.fetch(fetchRequest) 
        
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
                //fix 'Multiple NSEntityDescriptions claim' when using in-memory type in unit testing
                let entity = NSEntityDescription.insertNewObject(forEntityName: Remote.Entity.name, into: context) as! Remote.Entity
                item.importInto(entity)
            }
        }
        
        print("sync update", updateCount, "count")
        print("sync insert", remoteList.filter { idEntityMapping[$0.uniqueId] == nil } .count, "count")
    }
    
    private func batchDelete<Remote: RemoteEntity>(type: Remote.Type, decoration: (NSFetchRequest<NSFetchRequestResult>) -> (), in context: NSManagedObjectContext) throws where Remote.Entity: NSManagedObject {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Remote.Entity.name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Remote.Entity.primaryKeyName, ascending: true)]
        decoration(fetchRequest)
        
        if container.persistentStoreDescriptions.first?.type == NSInMemoryStoreType {
            fetchRequest.resultType = .managedObjectIDResultType
            let result = try context.fetch(fetchRequest) as! [NSManagedObjectID]
            
            if !result.isEmpty {
                result.forEach { id in
                    context.delete(context.object(with: id))
                }
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: result], into: [self.viewContext])
            }
            
            print("syc delete", result.count, "count", fetchRequest.predicate as Any)
        }else {
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            var count = 0
            if let ids = result?.result as? [NSManagedObjectID], !ids.isEmpty {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [self.viewContext])
                count = ids.count
            }
            
            print("syc delete", count, "count", fetchRequest.predicate as Any)
        }
    }
}
