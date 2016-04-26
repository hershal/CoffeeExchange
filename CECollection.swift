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

    var delegate: CECollectionDelegate?
    var entries: [CEEntry]
    var identifiers: [String] {
        return entries.map({$0.contact.identifier})
    }

    init() {
        entries = [CEEntry]()
    }

    lazy private var archiveLocation: String = {
        let location = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let url = NSURL(string: location)
        let saveLocation = url!.URLByAppendingPathComponent(CECollection.archiveName)
        return saveLocation.absoluteString
    }()

    func addEntry(contact: CNContact) -> CEEntry? {
        if (identifiers.contains(contact.identifier)) {
            NSLog("CECollection:: Trying to add contact which already exists in store!")
            return nil
        }
        let entry = CEEntry(contact: contact)
        entries.append(entry)
        NSLog("CECollection:: Added entry: \(contact.identifier)")
        delegate?.collectionDidAddEntry(self, entry: entry)
        return entry
    }

    func unarchive() {
        entries.removeAll()
        if let unarchivedEntries = NSKeyedUnarchiver.unarchiveObjectWithFile(archiveLocation) as? [CEEntry] {
            entries = unarchivedEntries
        }
        NSLog("CECollection::DidUnarchiveFrom: \(archiveLocation)")
        NSLog("CECollection::Loaded \(entries.count) items")
        delegate?.collectionDidFinishLoading(self)
    }

    func archive() {
        NSKeyedArchiver.archiveRootObject(entries, toFile: archiveLocation)
        NSLog("CECollection::DidArchiveTo: \(archiveLocation)")
    }
}

protocol CECollectionDelegate {
    func collectionDidFinishLoading(collection: CECollection)
    func collectionDidAddEntry(collection: CECollection, entry: CEEntry)
}