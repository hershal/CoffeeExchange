//
//  CEEntryViewModel.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import Contacts

class CEEntryDetailViewModel: NSObject {

    var truth: CEEntry

    init(truth: CEEntry) {
        self.truth = truth
        super.init()
    }

    var initials: String {
        var initialString = ""
        let givenName = truth.contact.givenName
        let familyName = truth.contact.familyName
        if givenName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            initialString.append(givenName[givenName.startIndex])
        }
        if familyName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            initialString.append(familyName[familyName.startIndex])
        }
        return initialString.uppercaseString
    }

    dynamic var balance: Int {
        get {
            return truth.balance
        }
        set (newValue) {
            truth.balance = newValue
        }
    }

    var balanceSubtext: String {
        if balance == 0 {
            return "Balance has been restored."
        } else {
            return "You \(balanceDirectionPresent) \(truth.contact.givenName) \(absBalance) \(noun)."
        }
    }

    var balanceDirectionPast: String {
        return balance < 0 ? "lent" : "owed"
    }

    var balanceDirectionPresent: String {
        return balance < 0 ? "lent" : "owe"
    }

    var absBalance: Int {
        return abs(balance)
    }

    var noun: String {
        return absBalance == 1 ? "cup" : "cups"
    }

    var balanceText: String {
        return "\(absBalance) \(noun) \(balanceDirectionPast)"
    }

    var picture: NSData? {
        return truth.contact.thumbnailImageData
    }

    var hasPhoneNumber: Bool {
        let contact = truth.contact
        return contact.isKeyAvailable(CNContactPhoneNumbersKey) && contact.phoneNumbers.count > 0
    }

    var callablePhoneNumbers: [String: CNPhoneNumber]? {
        guard hasPhoneNumber else {
            return nil
        }
        let labeledValues = truth.contact.phoneNumbers.filter { (labeledValue) -> Bool in
            callablePhoneLabels.contains(labeledValue.label)
        }
        return zipLabeledPhoneValues(labeledValues)
    }

    var textablePhoneNumbers: [String: CNPhoneNumber]? {
        guard hasPhoneNumber else {
            return nil
        }
        let labeledValues = truth.contact.phoneNumbers.filter { (labeledValue) -> Bool in
            textablePhoneLabels.contains(labeledValue.label)
        }
        return zipLabeledPhoneValues(labeledValues)
    }

    private func zipLabeledPhoneValues(labeledValues: [CNLabeledValue]) -> [String: CNPhoneNumber] {
        var assoc = [String: CNPhoneNumber]()
        labeledValues.forEach { (labeledValue) in
            if let value = labeledValue.value as? CNPhoneNumber {
                assoc[humanPhoneLabels[labeledValue.label]!] = value
            }
        }
        return assoc
    }

    let callablePhoneLabels = [CNLabelPhoneNumberiPhone, CNLabelPhoneNumberMobile, CNLabelPhoneNumberMain, CNLabelHome, CNLabelWork, CNLabelOther]
    let textablePhoneLabels = [CNLabelPhoneNumberiPhone, CNLabelPhoneNumberMobile, CNLabelOther]
    let humanPhoneLabels = [CNLabelPhoneNumberiPhone: "iPhone", CNLabelPhoneNumberMobile: "mobile", CNLabelPhoneNumberMain: "main", CNLabelHome: "home", CNLabelWork: "work", CNLabelOther: "other"]

    var hasAddresses: Bool {
        let contact = truth.contact
        return contact.isKeyAvailable(CNContactPostalAddressesKey) && contact.postalAddresses.count > 0
    }

    var postalAddresses: [CNPostalAddress]? {
        guard hasAddresses else {
            return nil
        }
        let labeledValues = truth.contact.postalAddresses
        return labeledValues.map { (labeledValue) -> CNPostalAddress in
            labeledValue.value as! CNPostalAddress
        }
    }

}
