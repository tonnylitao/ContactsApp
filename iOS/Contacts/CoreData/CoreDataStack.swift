//
//  CoreDataStack.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
    
    static var shared = CoreDataStack()
    private override init() {}
    

    @available(iOS 10.0, *)
    private lazy var persistentContainer: NSPersistentContainer = {
        return NSPersistentContainer(name: "Contacts").apply {
            $0.loadPersistentStores(completionHandler: { (storeDescription, error) in
                
                error.ifSome {
                    fatalError("Unresolved error \($0)")
                }
            })
        }
    }()
    
    
    fileprivate lazy var backgroundContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.newBackgroundContext().apply {
                $0.name = "Background ctx"
            }
        }else {
            return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType).apply {
                $0.name = "Root ctx"
                TODO("persistentStoreCoordinator")
            }
        }
    }()
    
    
    lazy var mainContext: NSManagedObjectContext = {
        if #available(iOS 10.0, *) {
            return self.persistentContainer.viewContext.apply {
                $0.name = "Main ctx"
                $0.automaticallyMergesChangesFromParent = true
            }
        }else {
            return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType).apply {
                $0.name = "Main ctx"
                TODO("persistentStoreCoordinator")
                $0.parent = self.backgroundContext
                $0.automaticallyMergesChangesFromParent = true
            }
        }
    }()
    
    
    func childContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType).apply {
            $0.name = "Child ctx"
            TODO("persistentStoreCoordinator")
            $0.parent = self.mainContext
        }
    }
}


extension CoreDataStack {
    
    static func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) throws -> Result<[TypeOfId], AppError>,
                                      completion: @escaping DBIdsResultCompletion) {
        
        if #available(iOS 10.0, *) {
            shared.persistentContainer.performBackgroundTask { context in
                
                let result: Result<[TypeOfId], AppError>
                do {
                    result = try task(context)
                }catch {
                    completion(.failure(.coredata(error.localizedDescription)))
                    return
                }
                
                do {
                    try context.save()
                }catch {
                    return completion(.failure(.coredata(error.localizedDescription)))
                }
                
                completion(result)
            }
        } else {
            let context = CoreDataStack.shared.backgroundContext
            
            let result: Result<[TypeOfId], AppError>
            do {
                result = try task(context)
            }catch {
                completion(.failure(.coredata(error.localizedDescription)))
                return
            }
            
            
            context.performAndWait {
                
                do {
                    try context.save()
                }catch {
                    return completion(.failure(.coredata(error.localizedDescription)))
                }
            }
            
            completion(result)
        }
        
    }
}

extension NSManagedObjectContext {
    var nickName: String {
        return name ?? "some background ctx"
    }
}
