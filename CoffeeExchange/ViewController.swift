 //
//  ViewController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate, CEEntryDetailDelegate, CECollectionDelegate, CECollectionDynamicViewDataSource, CECollectionDynamicViewDelegate {

    private var collection: CECollection!
    @IBOutlet var dynamicView: CECollectionDynamicView!

    @IBAction func pickContact(sender: AnyObject) {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey]
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        NSLog("selected \(contact.identifier)")
        if let entry = collection.getEntryWithIdentifier(contact.identifier) {
            self.showEntryDetail(entry)
        } else {
            self.showEntryDetail(CEEntry(contact: contact))
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
        dynamicView.delegate = self
        collection = CECollection()
        collection.delegate = self
        collection.unarchive()
    }

    func dynamicView(dynamicView: CECollectionDynamicView, didSelectEntry entry: CEEntry) {
        showEntryDetail(entry)
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
        // TODO: investigate uicollectionview's invalidation context to reload only new data
        dynamicView.reloadData()
    }

    // MARK: - CEEntryDetailDelegate Methods
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry) {
        if let index = collection.entries.indexOf(entry) {
            dynamicView.invalidateItemAtIndex(index)
        } else {
            collection.addEntry(entry)
        }
        saveCollectionData()
    }

    // MARK: - CEDynamicVIew Methods
    func dynamicViewNumberOfItems(dynamicView: CECollectionDynamicView) -> Int {
        return collection.entries.count
    }

    func dynamicView(cellForItemAtIndex index: Int) -> CEEntryDynamicItem {
        let item = CEEntryDynamicItem(entry: collection.entries[index])
        return item
    }
}

