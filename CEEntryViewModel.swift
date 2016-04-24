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

    var balanceText: String {
        get {
            return "\(self.balance)"
        }
    }

    init(truth: CEEntry) {
        self.truth = truth
        super.init()
    }
}