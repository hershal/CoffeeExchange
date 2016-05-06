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
    private var entries: [CEEntry]
    var identifiers: [String] {
        return entries.map({$0.contact.identifier})
    }

    init() {
        entries = [CEEntry]()
    }

    var count: Int {
        return entries.count
    }

    lazy private var archiveLocation: String = {
        let location = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let url = NSURL(string: location)
        let saveLocation = url!.URLByAppendingPathComponent(CECollection.archiveName)
        return saveLocation.absoluteString
    }()

    func addEntry(entry: CEEntry) {
        if (identifiers.contains(entry.contact.identifier)) {
            NSLog("CECollection:: Trying to add contact which already exists in store!")
            return
        }
        entries.append(entry)
        NSLog("CECollection:: Added entry: \(entry.contact.identifier)")
        delegate?.collection(self, didAddEntry: entry)
        delegate?.collection(self, didChangeCount: count)
    }

    func unarchive() {
        entries.removeAll()
        if let unarchivedEntries = NSKeyedUnarchiver.unarchiveObjectWithFile(archiveLocation) as? [CEEntry] {
            entries.appendContentsOf(unarchivedEntries)
        }
        NSLog("CECollection::DidUnarchiveFrom: \(archiveLocation)")
        NSLog("CECollection::Loaded \(entries.count) items")
        delegate?.collectionDidFinishLoading(self)
        delegate?.collection(self, didChangeCount: count)
    }

    func archive() {
        NSKeyedArchiver.archiveRootObject(entries, toFile: archiveLocation)
        NSLog("CECollection::DidArchiveTo: \(archiveLocation)")
    }

    func contains(entry entry: CEEntry) -> Bool {
        return contains(contact: entry.contact)
    }

    func contains(contact contact: CNContact) -> Bool {
        return contains(identifier: contact.identifier)
    }

    func contains(identifier identifier: String) -> Bool {
        return entries.reduce(0, combine: { (accum, iter) -> Int in
            return iter.contact.identifier == identifier ? 1 : 0
        }) != 0
    }

    func entryWithIdentifier(identifier: String) -> CEEntry? {
        for entry in entries {
            if entry.contact.identifier == identifier {
                return entry
            }
        }
        return nil
    }

    func removeAll() {
        entries.removeAll()
        delegate?.collection(self, didChangeCount: count)
        archive()
    }

    func removeAtIndex(index: Int) {
        entries.removeAtIndex(index)
        delegate?.collection(self, didChangeCount: count)
    }

    func indexOfEntry(entry: CEEntry) -> Int? {
        let index = entries.indexOf(entry)
        if index != NSNotFound {
            return index
        }
        return nil
    }

    func entryAtIndex(index: Int) -> CEEntry? {
        if index < count {
            return entries[index]
        }
        return nil
    }
}

protocol CECollectionDelegate {
    func collectionDidFinishLoading(collection: CECollection)
    func collection(collection: CECollection, didAddEntry entry: CEEntry)
    func collection(collection: CECollection, didChangeCount count: Int)
}
