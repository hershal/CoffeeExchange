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
                let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.toggleEditMode))
                let clearButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(ViewController.clearAll))
                navigationItem.setRightBarButton(clearButton, animated: true)
                navigationItem.setLeftBarButton(doneButton, animated: true)
            case .NormalMode:
                let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ViewController.toggleEditMode))
                let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.openContactPicker))
                navigationItem.setRightBarButton(addButton, animated: true)
                navigationItem.setLeftBarButton(editButton, animated: true)
            }
            dynamicView.setEditMode(editMode: editMode)
        }
    }

    @objc func clearAll() {
        let alertController = UIAlertController(title: "Clear All?", message: "Are you sure you would like to clear all coffee entries? This will permanantly delete all items.", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Clear All", style: .destructive, handler: { (alertAction) in
            self.collection.removeAll()
            self.dynamicView.reloadData()
            self.toggleEditMode()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @objc func openContactPicker() {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactPostalAddressesKey, CNContactThumbnailImageDataKey]
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    @objc func toggleEditMode() {
        switch (editMode) {
        case .NormalMode: editMode = .EditMode
        case .EditMode: editMode = .NormalMode
        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        NSLog("selected \(contact.identifier)")
        if let entry = collection.entryWithIdentifier(identifier: contact.identifier) {
            self.showEntryDetail(entry: entry)
        } else {
            self.showEntryDetail(entry: CEEntry(contact: contact))
        }
    }

    private func saveCollectionData() {
        DispatchQueue.global().async {
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
            showEntryDetail(entry: entry)
        case .EditMode:
            removeEntry(entry: entry)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showEntryDetail(entry: CEEntry) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailView = mainStoryboard.instantiateViewController(withIdentifier: "CEEntryDetailViewController") as! CEEntryDetailViewController
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
            UIView.animate(withDuration: 1, animations: {
                self.dynamicView.backgroundView.alpha = 0
            })
        } else {
                UIView.animate(withDuration: 1, animations: {
                self.dynamicView.backgroundView.alpha = 1
            })
        }
        saveCollectionData()
    }

    func removeEntry(entry: CEEntry) {
                if let index = collection.indexOfEntry(entry: entry) {
                    collection.removeAtIndex(index: index)
                    dynamicView.removeItemAtIndex(index: index)
        }
    }

    // MARK: - CEEntryDetailDelegate Methods
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry) {
        if entry.balance == 0 {
            removeEntry(entry: entry)
        } else if let index = collection.indexOfEntry(entry: entry) {
            dynamicView.invalidateItemAtIndex(index: index)
        } else {
            collection.addEntry(entry: entry)
        }
        saveCollectionData()
    }

    // MARK: - CEDynamicView Methods
    func dynamicViewNumberOfItems(dynamicView: CECollectionDynamicView) -> Int {
        return collection.count
    }

    func dynamicView(cellForItemAtIndex index: Int) -> CEEntryDynamicItem {
        return CEEntryDynamicItem(entry: collection.entryAtIndex(index: index)!)
    }
}

 enum CEViewControllerEditMode {
    case NormalMode
    case EditMode
 }
