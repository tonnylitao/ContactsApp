//
//  DBEntity.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData

/*
    two protocols connect differeent categories
 
             RemoteEntity    <------->    DBEntity
                  /                           \
                 /                             \
    Decodable data from api               NSManagedObject
        api Message                      Core data Message
        api Comment                      Core data Comment
              .                                .
              .                                .
 
    protocol RemoteEntity {
         var uniqueId: TypeOfId { get }
 
         associatedtype Entity: DBEntity
         func importInto(_ entiry: DBEntity)
    }
 */

protocol DBEntity: class {
    var uniqueId: TypeOfId { get }
}

typealias DBIdsResultCompletion = (Result<[TypeOfId], AppError>) -> ()

extension DBEntity where Self: NSManagedObject {
    
    /*
     DBMessage sync with RemoteMessage
     DBComment sync with RemoteComment
     */
    static func keepConsistencyWith<M: RemoteEntity>(previousPageLastId id: TypeOfId?,
                                                     remoteData: [M],
                                                     condition: NSPredicate?,
                                                     completion: @escaping DBIdsResultCompletion) where M.Entity == Self {
        
        let count = remoteData.count
        
        if count == 0 {
            completion(.success([]))
            
            deleteAllAfter(id: id, with: condition, completion: completion)
        }else if count == 1 {
            deleteAllAfter(id: remoteData.last?.uniqueId, with: condition, completion: completion)
            
            updateOrInsert(remoteData: remoteData.first!, with: condition, completion: completion)
        }else {
            updateOrInsertOrDeleteInRange(remoteData: remoteData, with: condition, completion: completion)
            
            if count < ApiConfig.defaultPagingSize {
                deleteAllAfter(id: remoteData.last?.uniqueId, with: condition, completion: completion)
            }
        }
    }
    
    private static func deleteAllAfter(id: TypeOfId?,
                                           with condition: NSPredicate?,
                                           completion: @escaping DBIdsResultCompletion) {
        
        guard let id = id, let entityName = Self.entity().name else { return }
        
        CoreDataStack.performBackgroundTask({ context in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.predicate = NSPredicate(format: "id > %d", id) && condition
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            //
            let context = CoreDataStack.shared.mainContext
            var result: NSBatchDeleteResult?
            do {
                result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            }catch {
                return .failure(.coredata(error.localizedDescription))
            }
            
            //
            var count = 0
            if let ids = result?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [CoreDataStack.shared.mainContext])
                
                count = ids.count
            }
            
            print(context.nickName, "delete: \(String(describing: fetchRequest.predicate)) \(count)")
            
            return .success([])
        }, completion: completion)
    }
    
    private static func updateOrInsert<M: RemoteEntity>(remoteData: M,
                                                            with condition: NSPredicate?,
                                                            completion: @escaping DBIdsResultCompletion) where M.Entity == Self {
        
        guard let entityName = Self.entity().name else  {
            completion(.failure(.coredata("Self.entity().name is nil")))
            return
        }
        
        let id = remoteData.uniqueId
        
        CoreDataStack.performBackgroundTask({ context in
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName).apply {
                $0.predicate = NSPredicate(format: "id == %d", id) && condition
                $0.fetchLimit = 1
            }
            
            let entities: [Self]
            do {
                entities = try context.fetch(fetchRequest) as! [Self]
            }catch {
                return .failure(.coredata(error.localizedDescription))
            }
            
            if let entity = entities.first {
                print(context.nickName, "update: \(id)")
                
                remoteData.importInto(entity)
            }else {
                print(context.nickName, "insert: \(id)")
                
                let entity = Self(context: context)
                remoteData.importInto(entity)
                
                context.insert(entity)
            }
            
            return .success([id])
        }, completion: completion)
        
    }
    
    private static func updateOrInsertOrDeleteInRange<M: RemoteEntity>(remoteData: [M],
                                                                           with condition: NSPredicate?,
                                                                           completion: @escaping DBIdsResultCompletion) where M.Entity == Self {
        
        guard remoteData.count >= 2,
            let entityName = Self.entity().name else {
                completion(.failure(.coredata("count <= 2 or Self.entity().name is nil")))
                return
        }
        
        CoreDataStack.performBackgroundTask({ context in
            
            let toUpdateFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            toUpdateFetchRequest.predicate = NSPredicate(format: "id IN %@", remoteData.map { $0.uniqueId }) && condition

            let toUpdateEntities: [Self]
            do {
                toUpdateEntities = try context.fetch(toUpdateFetchRequest) as! [Self]
            }catch {
                return .failure(.coredata(error.localizedDescription))
            }
            
            let ids = remoteData.compactMap { $0.uniqueId } .sorted()
            
            let minId = ids.first!
            let maxId = ids.last!
            
            /*
             batch delete
             */
            let toDeleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            toDeleteFetchRequest.predicate = NSPredicate(format: "id >= %d AND id <= %d AND NOT id IN %@", minId, maxId, ids) && condition
            
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: toDeleteFetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            
            
            var deletedResult: NSBatchDeleteResult?
            do {
                deletedResult = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            }catch {
                return .failure(.coredata(error.localizedDescription))
            }
            
            var count = 0
            if let ids = deletedResult?.result as? [NSManagedObjectID] {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [CoreDataStack.shared.mainContext])
                
                count = ids.count
            }
            print(context.nickName, "delete: \(count) entity which in [\(minId)...\(maxId)] and not in \(ids) and \(String(describing: condition))")
            
            /*
             insert
            */
            let dbDataMapping = toUpdateEntities.dictionaryBy { $0.uniqueId }
            let remoteDataMapping = remoteData.dictionaryBy { $0.uniqueId }
            
            for id in ids where dbDataMapping[id] == nil {
                let entity = Self(context: context)
                
                remoteDataMapping[id]?.importInto(entity)
                context.insert(entity)
            }
            
            print(context.nickName, "insert: \(ids.filter { dbDataMapping[$0] == nil })")
            
            /*
             update
             */
            toUpdateEntities.forEach { item in
                remoteDataMapping[item.uniqueId]?.importInto(item)
            }
            
            print(context.nickName, "update: \(toUpdateEntities.map { $0.uniqueId })")
            
            return .success(remoteData.map { $0.uniqueId })
        }, completion: completion)
    }
}
