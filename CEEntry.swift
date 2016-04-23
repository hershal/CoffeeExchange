//
//  CEEntry.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import Contacts

// Would this be better as a value-type?
class CEEntry {

    static let balanceKey = "balance";
    static let identifierKey = "identifier";

    var contact: CNContact
    var balance: Int
    var hashValue: Int {
        return contact.identifier.hashValue
    }

    init(contact: CNContact) {
        self.contact = contact
        self.balance = 0
    }

    func increaseBalance(amount: Int) {
        balance = balance + amount
    }

    func decreaseBalance(amount: Int) {
        balance = balance - amount
    }
}