 //
//  ViewController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate, CEEntryDetailDelegate, CECollectionDelegate, CECollectionDynamicViewDataSource {

    private var collection: CECollection!
    @IBOutlet var dynamicView: CECollectionDynamicView!

    @IBAction func addEntry(sender: AnyObject) {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey]

        picker.predicateForEnablingContact = NSPredicate(format: "NOT (identifier IN %@)", collection.identifiers)
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        NSLog("selected \(contact.identifier)")
        if let entry = collection.addEntry(contact) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5*Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.showEntryDetail(entry)
                self.saveCollectionData()
            }
        }
    }

    private func saveCollectionData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.collection.archive()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicView.dataSource = self
        collection = CECollection()
        collection.delegate = self
        collection.unarchive()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showEntryDetail(entry: CEEntry) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailView = mainStoryboard.instantiateViewControllerWithIdentifier("CEEntryDetailViewController") as! CEEntryDetailViewController
        let viewModel = CEEntryDetailViewModel(truth: entry)
        detailView.viewModel = viewModel
        detailView.delegate = self
        self.navigationController?.pushViewController(detailView, animated: true)
    }

    // MARK: - CECollectionDelegate Methods
    func collectionDidFinishLoading(collection: CECollection) {
        dynamicView.reloadData()
    }

    func collectionDidAddEntry(collection: CECollection, entry: CEEntry) {
        // TODO: find a better way, maybe reload that specific entry?
        dynamicView.reloadData()
    }

    // MARK: - CEEntryDetailDelegate Methods
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry) {
        saveCollectionData()
    }

    func dynamicViewNumberOfItems(dynamicView: CECollectionDynamicView) -> Int {
        return collection.entries.count
    }

    func dynamicView(cellForItemAtIndex index: Int) -> CEEntryDynamicItem {
        let item = CEEntryDynamicItem()
        return item
    }

    // MARK: - CollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.entries.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CEEntryView", forIndexPath: indexPath) as! CEEntryView
        let entry = collection.entries[indexPath.item]
        let contact = entry.contact
        let upperDisplayString = "\(contact.givenName) \(contact.familyName)"
        cell.upperLabel.text = upperDisplayString

        var cupString = "cup"
        if entry.balance != 1 {
            cupString = "cups"
        }

        cell.lowerLabel.text = "\(entry.balance) \(cupString)";
        cell.lowerLabel.textColor = UIColor.brownColor()
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedEntry = collection.entries[indexPath.item]
        showEntryDetail(selectedEntry)
    }
}

