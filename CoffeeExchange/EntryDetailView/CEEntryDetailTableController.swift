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
    let tableActions = [["Call", "Message", "Remind Me"], ["Remind Me"]]
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
        switch (viewModel.hasPhoneNumber) {
        case true:
            switch (indexPath.item) {
            case 0: presentCallDialog()
            case 1: presentMessageDialog()
            default: presentRemindMeDialog()
            }
        default:
            presentRemindMeDialog()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func sheetWithTitle(title: String?, message: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
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

        let sheet = sheetWithTitle("Call", message: nil)

        for (label, number) in phoneNumbers {
            sheet.addAction(UIAlertAction(title: "\(label) \(number.stringValue)", style: .Default, handler: { (action) in
                delegate.tableControllerDidSelectCallWithPhoneNumber(number)
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        delegate.tableControllerPresentViewController(sheet)
    }

    func presentMessageDialog() {
        guard let phoneNumbers = viewModel.textablePhoneNumbers else {
            NSLog("CEEntryDetailTableController::PresentMessageDialog::CouldNotEnumeratePhoneNumbers")
            return
        }

        guard let delegate = delegate else {
            NSLog("CEEntryDetailTableController::PresentMessageDialog::NoDelegate")
            return
        }

        let sheet = sheetWithTitle("Message", message: nil)

        for (label, number) in phoneNumbers {
            sheet.addAction(UIAlertAction(title: "\(label) \(number.stringValue)", style: .Default, handler: { (action) in
                delegate.tableControllerDidSelectMessageWithPhoneNumber(number)
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        delegate.tableControllerPresentViewController(sheet)
    }

    func presentRemindMeDialog() {
        guard let delegate = delegate else {
            NSLog("CEEntryDetailTableController::PresentMessageDialog::NoDelegate")
            return
        }

        let sheet = sheetWithTitle("Remind Me", message: nil)
        let reminderController = CEReminderController(viewModel: viewModel)

        for (interval, intervalString) in reminderController.reminderIntervalSheetInfo() {
            sheet.addAction(UIAlertAction(title: intervalString, style: .Default, handler: { (alertAction) in
                delegate.tableControllerDidSelectRemindMeWithInterval(interval)
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        delegate.tableControllerPresentViewController(sheet)
    }
}

protocol CEEntryDetailTableControllerDelegate {
    func tableControllerPresentViewController(viewController: UIViewController)
    func tableControllerDidSelectCallWithPhoneNumber(phoneNumber: CNPhoneNumber)
    func tableControllerDidSelectMessageWithPhoneNumber(phoneNumber: CNPhoneNumber)
    func tableControllerDidSelectRemindMeWithInterval(interval: CEReminderInterval)
}
