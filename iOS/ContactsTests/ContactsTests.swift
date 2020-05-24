//
//  ContactsTests.swift
//  ContactsTests
//
//  Created by TonnyLi on 24/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import XCTest

class ContactsTests: XCTestCase {
    
    struct Admin: Decodable, RemoteResource {
        static var path: ApiPath = .users
        
        var results: [RemoteUser]
    }
    
    func testTheNameOfFirstAdmin() throws {
        let expects = expectation(description: "the result from api")
        var target: Admin?
        
        let count = 1
        
        Admin.get(.users, parameters: ["results": "\(count)", "seed": "office"]) {
            target = $0.unwrapResult
            expects.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertEqual(target?.results.count, count)
            XCTAssertEqual(target?.results.first?.name.last, "Wood")
        }
        
    }
}
