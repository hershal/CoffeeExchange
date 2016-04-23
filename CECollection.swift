//
//  CECollection.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import Contacts

class CECollection {

    static let archiveName = "CoffeeCollectionArchive.bin"

    var entries: [CEEntry]
    var identifiers: [String] {
        return entries.map({$0.contact.identifier})
    }

    init(shouldUnarchive: Bool) {
        entries = [CEEntry]()
        if shouldUnarchive {
            unarchive()
        }
    }

    lazy private var archiveLocation: String = {
        let location = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let url = NSURL(string: location)
        let saveLocation = url!.URLByAppendingPathComponent(CECollection.archiveName)
        return saveLocation.absoluteString
    }()

    func save() {
        archive()
    }

    func addEntry(contact: CNContact) {
        if (identifiers.contains(contact.identifier)) {
            NSLog("CECollection:: Trying to add contact which already exists in store!")
            return
        }
        entries.append(CEEntry(contact: contact))
        NSLog("CECollection:: Added entry: \(contact.identifier)")
    }

    private func unarchive() {
        if let unarchivedEntries = NSKeyedUnarchiver.unarchiveObjectWithFile(archiveLocation) as? [CEEntry] {
            entries = unarchivedEntries
        } else {
            entries.removeAll()
        }
    }

    private func archive() {
        NSKeyedArchiver.archiveRootObject(entries, toFile: archiveLocation)
    }
}