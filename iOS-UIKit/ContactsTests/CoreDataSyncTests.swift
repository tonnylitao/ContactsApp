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
        syncEngine = DataSyncEngine(container: createContainer(modelName: "Contacts"))
    }
    
    override func tearDownWithError() throws {
        syncEngine = nil
    }
    
    func test_load_first_page() throws {
        let list = mockingData(pageIndex: 1, pageSize: 5)
        
        let expect = expectation(description: "create 5 entities if 5 items in 1st page")
        
        syncEngine.sync(from: list, offset: 0, isFullFilled: true) { (error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            
            self.assertCountEqual(5)
        }
    }
    
    func test_load_second_empty_page() throws {
        try test_load_first_page()
        
        let list = [RemoteUser]()
        
        let expect = expectation(description: "create no entity if empty page")
        
        syncEngine.sync(from: list, offset: 5, isFullFilled: false) { (error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            
            self.assertCountEqual(5)
        }
    }
    
    func test_load_second_fullfield_page() throws {
        try test_load_first_page()
        
        let list = mockingData(pageIndex: 2, pageSize: 5)
        
        let expect = expectation(description: "create 5 entities if 5 items in 2nd page")
        
        syncEngine.sync(from: list, offset: 5, isFullFilled: true) { (error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            
            self.assertCountEqual(10)
        }
    }
    
    func test_load_second_empty_page1() throws {
        try test_load_second_fullfield_page()
        
        let expect = expectation(description: "delete 5 cached entities if empty 2nd page")
        
        syncEngine.sync(from: [RemoteUser](), offset: 5, isFullFilled: false) { (error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            
            self.assertCountEqual(5)
        }
    }
    
    func test_load_second_page_with_CURD() throws {
        try test_load_second_fullfield_page()
        
        var list = mockingData(pageIndex: 2, pageSize: 7)
        let item2 = list[2].copyWith(newEmail: "a new Email")
        
        /*
         delete 3rd, 4th, 5th
         update 2nd
         insert a new one
         so there are 8 items left
         */
        list = [list[0], item2, list[6]]
        
        let expect = expectation(description: "delete, update and insert if necessory")
        
        syncEngine.sync(from: list, offset: 5, isFullFilled: false) { (error) in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error)
            
            self.assertCountEqual(8)
            
            //
            let fetchRequest0 = NSFetchRequest<User>(entityName: "User")
            fetchRequest0.predicate = NSPredicate(format: "uniqueId IN %@", [list.first!.uniqueId, list.last!.uniqueId])
            let result0 = try! self.syncEngine.container.viewContext.fetch(fetchRequest0)
            XCTAssertEqual(result0.count, 2)
            
            //
            let fetchRequest1 = NSFetchRequest<User>(entityName: "User")
            fetchRequest1.predicate = NSPredicate(format: "uniqueId == %d", item2.uniqueId)
            fetchRequest1.fetchLimit = 1
            let result1 = try! self.syncEngine.container.viewContext.fetch(fetchRequest1)
            XCTAssertEqual(result1.first!.email, "a new Email")
        }
    }
 
    private func assertCountEqual(_ count: Int) {
        let request: NSFetchRequest<User> = User.fetchRequest()
        let result = (try? self.syncEngine.container.viewContext.fetch(request)) ?? []
        XCTAssertEqual(result.count, count)
    }
}

extension RemoteUser {
    func copyWith(newEmail: String) -> RemoteUser {
        RemoteUser(fakeId: fakeId, gender: gender, name: name, location: location,
                   email: newEmail,
                   login: login, dob: dob, registered: registered, phone: phone, cell: cell, id: id, picture: picture, nat: nat)
    }
}

fileprivate func mockingData(pageIndex: Int, pageSize: Int) -> [RemoteUser] {
    assert(pageSize <= 20)
    
    let data = Bundle(for: CoreDataSyncTests.self).url(forResource: "users", withExtension: "json").flatMap {
        try! Data(contentsOf: $0)
    }!
    var response = try! JSONDecoder().decode(RemoteUserResponse.self, from: data)
    response.results = Array(response.results[..<pageSize])
    let list = response.unsafeBuildFakeIds(pageIndex)
    return list
}

fileprivate func createContainer(modelName: String) -> NSPersistentContainer {
    let modelURL = Bundle.main.url(forResource: modelName,
                                   withExtension: "mom")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let container = NSPersistentContainer(name: modelName,
                                          managedObjectModel: model)
    
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { (description, error) in
        assert(description.type == NSInMemoryStoreType)
        
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    return container
}
