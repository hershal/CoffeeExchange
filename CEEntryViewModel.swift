//
//  CEEntryViewModel.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit

class CEEntryDetailViewModel: NSObject {

    var truth: CEEntry
    dynamic var balance: Int {
        get {
            return truth.balance
        }
        set (newValue) {
            truth.balance = newValue
        }
    }

    private var balanceDirectionPast: String {
        return balance < 0 ? "lent" : "owed"
    }

    private var balanceDirectionPresent: String {
        return balance < 0 ? "lent" : "owe"
    }

    private var absBalance: Int {
        return abs(balance)
    }

    private var noun: String {
        return absBalance == 1 ? "cup" : "cups"
    }

    var balanceText: String {
        return "\(absBalance) \(noun) \(balanceDirectionPast)"
    }

    var balanceSubtext: String {
        if balance == 0 {
            return "Balance has been restored."
        } else {
            return "You \(balanceDirectionPresent) \(truth.contact.givenName) \(balance) \(noun)."
        }
    }

    init(truth: CEEntry) {
        self.truth = truth
        super.init()
    }
}
