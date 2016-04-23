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
class CEEntry: Hashable, Equatable, NSCoding {

    static let balanceKey = "balance";
    static let identifierKey = "identifier";

    var identifier: String
    var balance: Int
    var hashValue: Int {
        return identifier.hashValue
    }

    init(identifier: String) {
        self.identifier = identifier
        self.balance = 0
    }

    @objc required init?(coder aDecoder: NSCoder) {
        let bal = aDecoder.decodeIntegerForKey(CEEntry.balanceKey)
        let ident = aDecoder.decodeObjectForKey(CEEntry.identifierKey) as? String
        if let ident = ident {
            self.identifier = ident
            self.balance = bal
        } else {
            return nil
        }
    }

    func increaseBalance(amount: Int) {
        balance = balance + amount
    }

    func decreaseBalance(amount: Int) {
        balance = balance - amount
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(identifier, forKey: CEEntry.identifierKey)
        aCoder.encodeInteger(balance, forKey: CEEntry.balanceKey)
    }
}


func ==(lhs: CEEntry, rhs: CEEntry) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
