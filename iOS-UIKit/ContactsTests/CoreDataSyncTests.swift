//  CoreDataSyncTests.swift
//  ContactsTests
//
//  Created by TonnyLi on 10/04/21.
//  Copyright © 2021 tonnysunm. All rights reserved.
//  Github: https://github.com/tonnysunm/ContactsApp
//

@testable import Contacts
import XCTest
import CoreData

class CoreDataSyncTests: XCTestCase {
    
    var syncEngine: DataSyncEngine!
    
    override func setUpWithError() throws {
        syncEngine = DataSyncEngine(container: createContainer())
    }
    
    override func tearDownWithError() throws {
        syncEngine = nil
    }
    
    
    func createContainer() -> NSPersistentContainer {
        let modelURL = Bundle.main.url(forResource: "Contacts", withExtension: "mom")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "Contacts", managedObjectModel: model)
        
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }
    
    
    func testExample() throws {
        let data = Bundle(for: Self.self).url(forResource: "users", withExtension: "json").flatMap {
            try! Data(contentsOf: $0)
        }!
        let response = try JSONDecoder().decode(RemoteUserResponse.self, from: data)
        let list = response.unsafeBuildFakeIds(1)
        
        let expect = expectation(description: "sync")
        
        syncEngine.sync(remoteData: list, offset: 0, isFullFilled: false) { (error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            
            let request: NSFetchRequest<User> = User.fetchRequest()
            let result = (try? self.syncEngine.container.viewContext.fetch(request)) ?? []
            XCTAssertEqual(result.count, 20)
        }
    }
    
}
