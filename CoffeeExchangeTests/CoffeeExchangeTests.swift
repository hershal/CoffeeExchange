//
//  CoffeeExchangeTests.swift
//  CoffeeExchangeTests
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import XCTest
@testable import CoffeeExchange

class CoffeeExchangeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEntryEquality() {
        // Don't care if balance changes

        let entry0 = CEEntry(identifier: "000")
        entry0.balance = 10

        let entry1 = CEEntry(identifier: "000")
        entry1.balance = 10

        XCTAssert(entry0 == entry1)
        entry1.identifier = "001"
        XCTAssert(entry0 != entry1)
    }
}
