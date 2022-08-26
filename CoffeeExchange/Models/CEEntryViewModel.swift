//
//  CEEntryViewModel.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-24.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import Contacts


internal protocol CNLabeledPhoneNumberOrPostalValue : NSCopying, NSSecureCoding {
    
}

class CEEntryDetailViewModel: NSObject {

    var truth: CEEntry

    init(truth: CEEntry) {
        self.truth = truth
        super.init()
    }

    lazy var initials: String = {
        var initialString = ""
        let givenName = self.truth.contact.givenName
        let familyName = self.truth.contact.familyName
        if givenName.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            initialString.append(givenName[givenName.startIndex])
        }
        if familyName.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            initialString.append(familyName[familyName.startIndex])
        }
        return initialString.uppercased()
    }()

    @objc dynamic var balance: Int
    {
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
        return truth.contact.thumbnailImageData as NSData?
    }

    lazy var hasPhoneNumber: Bool = {
        let contact = self.truth.contact
        return contact.isKeyAvailable(CNContactPhoneNumbersKey) && contact.phoneNumbers.count > 0
    }()

    lazy var callablePhoneNumbers: [(String, CNPhoneNumber)]? = {
        guard self.hasPhoneNumber else {
            return nil
        }
        let labeledValues = self.truth.contact.phoneNumbers.filter { (labeledValue) -> Bool in
            self.callablePhoneLabels.contains(labeledValue.label!)
        }
        return self.zipLabeledPhoneValues(labeledValues: labeledValues)
    }()

    lazy var textablePhoneNumbers: [(String, CNPhoneNumber)]? = {
        guard self.hasPhoneNumber else {
            return nil
        }
        let labeledValues = self.truth.contact.phoneNumbers.filter { (labeledValue) -> Bool in
            self.textablePhoneLabels.contains(labeledValue.label!)
        }
        return self.zipLabeledPhoneValues(labeledValues: labeledValues)
    }()

    
    private func zipLabeledPhoneValues(labeledValues: [CNLabeledValue<CNPhoneNumber>]) -> [(String, CNPhoneNumber)] {
        var phoneLabels = [String]()
        var phoneNumbers = [CNPhoneNumber]()

        for labeledValue in labeledValues {
            phoneNumbers.append(labeledValue.value)
            if let label = humanPhoneLabels[labeledValue.label!] {
                phoneLabels.append(label)
            } else {
                phoneLabels.append("")
            }
        }
        return Array(zip(phoneLabels, phoneNumbers))
    }

    private let callablePhoneLabels = [CNLabelPhoneNumberiPhone, CNLabelPhoneNumberMobile, CNLabelPhoneNumberMain, CNLabelHome, CNLabelWork, CNLabelOther]
    private let textablePhoneLabels = [CNLabelPhoneNumberiPhone, CNLabelPhoneNumberMobile, CNLabelOther]
    let humanPhoneLabels = [CNLabelPhoneNumberiPhone: "iPhone", CNLabelPhoneNumberMobile: "mobile", CNLabelPhoneNumberMain: "main", CNLabelHome: "home", CNLabelWork: "work", CNLabelOther: "other"]

    lazy var hasAddresses: Bool = {
        let contact = self.truth.contact
        return contact.isKeyAvailable(CNContactPostalAddressesKey) && contact.postalAddresses.count > 0
    }()

    lazy var postalAddresses: [(String, CNPostalAddress)]? = {
        guard self.hasAddresses else {
            return nil
        }
        let labeledValues = self.truth.contact.postalAddresses
        return self.zipLabeledPostalValues(labeledValues: labeledValues)
    }()

private func zipLabeledPostalValues(labeledValues: [CNLabeledValue<CNPostalAddress>]) -> [(String, CNPostalAddress)] {
        var addressLabels = [String]()
        var addresses = [CNPostalAddress]()

        for labeledValue in labeledValues {
            addresses.append(labeledValue.value)
            if let label = humanPostalAddressLabels[labeledValue.label!] {
                addressLabels.append(label)
            } else {
                addressLabels.append("")
            }
        }
        return Array(zip(addressLabels, addresses))
    }

    let humanPostalAddressLabels = [CNLabelHome: "Home", CNLabelWork: "Work", CNLabelOther: ""]
}
