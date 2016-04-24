 //
//  ViewController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CEEntryDetailDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    private var collection: CECollection!

    @IBAction func addEntry(sender: AnyObject) {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey]

        picker.predicateForEnablingContact = NSPredicate(format: "NOT (identifier IN %@)",collection.identifiers)
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        NSLog("selected \(contact.identifier)")
        if let entry = collection.addEntry(contact) {
            showEntryDetail(entry)
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collection = CECollection(shouldUnarchive: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "CEEntryView", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "CEEntryView")
        collectionView.backgroundColor = UIColor.whiteColor()
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

    // MARK: - CEEntryDetailDelegate Methods
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry) {
        collectionView.reloadData()
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

