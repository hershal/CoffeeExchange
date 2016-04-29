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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var editMode: CEViewControllerEditMode = .NormalMode {
        didSet {
            switch editMode {
            case .EditMode:
                let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ViewController.toggleEditMode))
                let clearButton = UIBarButtonItem(title: "Clear All", style: .Plain, target: self, action: #selector(ViewController.clearAll))
                navigationItem.setRightBarButtonItem(clearButton, animated: true)
                navigationItem.setLeftBarButtonItem(doneButton, animated: true)
            case .NormalMode:
                let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ViewController.toggleEditMode))
                let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.openContactPicker))
                navigationItem.setRightBarButtonItem(addButton, animated: true)
                navigationItem.setLeftBarButtonItem(editButton, animated: true)
            }
            dynamicView.setEditMode(editMode)
        }
    }

    func clearAll() {
        collection.removeAll()
        dynamicView.reloadData()
        toggleEditMode()
    }

    func openContactPicker() {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactPostalAddressesKey]
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func toggleEditMode() {
        switch (editMode) {
        case .NormalMode: editMode = .EditMode
        case .EditMode: editMode = .NormalMode
        }
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
        editMode = .NormalMode
    }

    func dynamicView(dynamicView: CECollectionDynamicView, didSelectEntry entry: CEEntry) {
        switch (editMode) {
        case .NormalMode:
            showEntryDetail(entry)
        case .EditMode:
            removeEntry(entry)
        }

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
        if collection.count > 0 {
            dynamicView.backgroundView.alpha = 0
        }
        dynamicView.reloadData()
    }

    func collection(collection: CECollection, didAddEntry entry: CEEntry) {
        dynamicView.appendItem()
    }

    func collection(collection: CECollection, didChangeCount count: Int) {
        if count > 0 {
            UIView.animateWithDuration(1, animations: {
                self.dynamicView.backgroundView.alpha = 0
            })
        } else {
            UIView.animateWithDuration(1, animations: {
                self.dynamicView.backgroundView.alpha = 1
            })
        }
    }

    func removeEntry(entry: CEEntry) {
        if let index = collection.indexOfEntry(entry) {
            collection.removeAtIndex(index)
            dynamicView.removeItemAtIndex(index)
        }
    }

    // MARK: - CEEntryDetailDelegate Methods
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry) {
        if entry.balance == 0 {
            removeEntry(entry)
        } else if let index = collection.indexOfEntry(entry) {
            dynamicView.invalidateItemAtIndex(index)
        } else {
            collection.addEntry(entry)
        }
        saveCollectionData()
    }

    // MARK: - CEDynamicView Methods
    func dynamicViewNumberOfItems(dynamicView: CECollectionDynamicView) -> Int {
        let count = collection.count
//        switch (
        return count
    }

    func dynamicView(cellForItemAtIndex index: Int) -> CEEntryDynamicItem {
        return CEEntryDynamicItem(entry: collection.entryAtIndex(index)!)
    }
}

 enum CEViewControllerEditMode {
    case NormalMode
    case EditMode
 }
