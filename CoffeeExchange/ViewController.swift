 //
//  ViewController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-22.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var collection: CECollection!

    @IBAction func addEntry(sender: AnyObject) {
        let picker = CNContactPickerViewController()
        picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey]

        picker.predicateForEnablingContact = NSPredicate(format: "NOT (identifier IN %@)",collection.identifiers)
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        NSLog("selected \(contact.identifier)")
        collection.addEntry(contact.identifier)
        collectionView.reloadData()
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

    // MARK: - CollectionViewDataSource Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.entries.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CEEntryView", forIndexPath: indexPath) as! CEEntryView
        let lowerDisplayString = collection.entries[indexPath.item].identifier as String
        cell.lowerLabel.text = lowerDisplayString
        return cell
    }
}

