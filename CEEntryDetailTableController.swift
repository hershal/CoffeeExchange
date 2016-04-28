//
//  CEEntryDetailTableController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-27.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class CEEntryDetailTableController: NSObject, UITableViewDataSource, UITableViewDelegate {
    var viewModel: CEEntryDetailViewModel
    var tableActions = [["Call", "Message", "Remind Me"], ["Remind Me"]]
    var delegate: CEEntryDetailTableControllerDelegate?

    init(viewModel: CEEntryDetailViewModel) {
        self.viewModel = viewModel
    }

    func cellTextAtIndexPath(indexPath: NSIndexPath) -> String {
        switch (viewModel.hasPhoneNumber) {
        case true:
            return tableActions[0][indexPath.item]
        default:
            return tableActions[1][indexPath.item]
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier("CEEntryDetailCell") {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "CEEntryDetailCell")
        }
        cell.textLabel?.text = cellTextAtIndexPath(indexPath)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (viewModel.hasPhoneNumber) {
        case true:
            return tableActions[0].count
        default:
            return tableActions[1].count
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (viewModel.hasPhoneNumber) {
        case true:
            switch (indexPath.item) {
            case 0: presentCallDialog()
            case 1: presentRemindMeDialog()
            default: presentRemindMeDialog()
            }
        default:
            presentRemindMeDialog()
        }
    }

    func initSheet() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        return alertController
    }

    func presentCallDialog() {
        guard let phoneNumbers = viewModel.callablePhoneNumbers else {
            NSLog("CEEntryDetailTableController::PresentCallDialog::CouldNotEnumeratePhoneNumbers")
            return
        }

        guard let delegate = delegate else {
            NSLog("CEEntryDetailTableController::PresentCallDialog::NoDelegate")
            return
        }

        let sheet = initSheet()

        for (label, number) in phoneNumbers {
            sheet.addAction(UIAlertAction(title: "\(label) \(number.stringValue)", style: .Default, handler: nil))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        delegate.tableControllerPresentViewController(sheet)
    }

    func presentMessageDialog() {

    }

    func presentRemindMeDialog() {

    }
}

protocol CEEntryDetailTableControllerDelegate {
    func tableControllerPresentViewController(viewController: UIViewController)
    func tableControllerDidSelectCallWithPhoneNumber(phoneNumber: CNPhoneNumber)
    func tableControllerDidSelectMessageWithPhoneNumber(phoneNumber: CNPhoneNumber)
    func tableControllerDidSelectRemindMeWithInterval(interval: NSTimeInterval)
}