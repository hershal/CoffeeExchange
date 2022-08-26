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
class CEEntry: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    static let balanceKey = "balance"
    static let contactKey = "contact"

    var contact: CNContact
    var balance: Int

    init(contact: CNContact) {
        self.contact = contact
        self.balance = 1
    }

    var fullName: String {
        return "\(contact.givenName) \(contact.familyName)"
    }

    required init?(coder aDecoder: NSCoder) {
        guard let contact = aDecoder.decodeObject(of: CNContact.self, forKey: CEEntry.contactKey) else {
            return nil
        }
        self.contact = contact
        self.balance = aDecoder.decodeInteger(forKey: CEEntry.balanceKey)
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.contact, forKey: CEEntry.contactKey)
        coder.encode(self.balance, forKey: CEEntry.balanceKey)
    }
}
