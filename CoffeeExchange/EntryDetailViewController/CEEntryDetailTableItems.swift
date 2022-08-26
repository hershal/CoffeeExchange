//
//  CEDetailTableItems.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-05-02.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import EventKit
import Contacts

class CETableItemBase: NSObject, CETableItem {
    var delegate: CETableItemDelegate
    var viewModel: CEEntryDetailViewModel
    var cellText: String {
        return "nil"
    }
    var visible: Bool {
        return false
    }
    init(viewModel: CEEntryDetailViewModel, delegate: CETableItemDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init()
    }

    func action() {
        fatalError()
    }
}

// MARK: - CERemindMeTableItem
class CERemindMeTableItem: CETableItemBase, CEReminderControllerDelegate {
    override var cellText: String {
        return "Remind Me"
    }

    override var visible: Bool {
        return true
    }

    override func action() {
        let reminderController = CEReminderController(viewModel: viewModel)

        let sheet = UIAlertController(title: "Remind Me", message: nil, preferredStyle: .actionSheet)
        for (interval, intervalString) in reminderController.reminderIntervalSheetInfo() {
            sheet.addAction(UIAlertAction(title: intervalString, style: .default, handler: { (alertAction) in
                self.didSelectRemindMeWithInterval(interval: interval)
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        delegate.tableItemPresentViewController(viewController: sheet)
    }

    func didSelectRemindMeWithInterval(interval: CEReminderInterval) {
        let reminderController = CEReminderController(viewModel: viewModel)
        reminderController.delegate = self
        reminderController.createReminderWithInterval(interval: interval)
    }

    // MARK: - CEReminderControllerDelegate Methods
    func reminderController(reminderController: CEReminderController, couldNotCreateReminderWithError reminderError: CEReminderError) {
        let alert = UIAlertController(title: "Can't Create Reminder", message: "You have denied access to create reminders. Please enable access in Settings under Privacy.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.delegate.tableItemPresentViewController(viewController: alert)
        }
    }

    func reminderController(reminderController: CEReminderController, didCreateReminder reminder: EKReminder, inCalendar calendar: EKCalendar, withInterval interval: CEReminderInterval) {
        NSLog("CERemindMeTableItem::DidCreateReminder: \(reminder) WithInterval: \(interval)")
    }
}

// MARK: - CEMessageTableItem
class CEMessageTableItem: CETableItemBase, MFMessageComposeViewControllerDelegate {
    override var cellText: String {
        return "Message"
    }

    override var visible: Bool {
        return MFMessageComposeViewController.canSendText()
        && viewModel.textablePhoneNumbers!.count > 0
    }

    override func action() {
        guard let phoneNumbers = viewModel.textablePhoneNumbers else {
            NSLog("CEEntryDetailTableController::PresentMessageDialog::CouldNotEnumeratePhoneNumbers")
            return
        }

        // short-circuit
        if phoneNumbers.count == 1 {
            didSelectMessageWithPhoneNumber(number: phoneNumbers.first!.1)
            return
        }

        let sheet = UIAlertController(title: "Message", message: nil, preferredStyle: .actionSheet)
        for (label, number) in phoneNumbers {
            sheet.addAction(UIAlertAction(title: "\(label) \(number.stringValue)", style: .default, handler: { (action) in
                self.didSelectMessageWithPhoneNumber(number: number)
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        delegate.tableItemPresentViewController(viewController: sheet)
    }

    func didSelectMessageWithPhoneNumber(number: CNPhoneNumber) {
        if let number = number.value(forKey: "digits") as? String {
            if MFMessageComposeViewController.canSendText() {
                let messageController = MFMessageComposeViewController()
                messageController.recipients = [number]
                messageController.body = "Hey, let's get coffee!"
                messageController.messageComposeDelegate = self
                delegate.tableItemPresentViewController(viewController: messageController)
            } else {
                NSLog("CEEntryDetailViewController::TableControllerDidSelectCallWithPhoneNumber::CantSendTexts")
                let alert = UIAlertController(title: "Can't Send Messages", message: "Your device is not set up to send messages.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                delegate.tableItemPresentViewController(viewController: alert)
            }
        } else {
            NSLog("CEEntryDetailViewController::TableControllerDidSelectCallWithPhoneNumber::CouldNotCallNumber: \(number)")
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CECallTableItem
class CECallTableItem: CETableItemBase {
    override var cellText: String {
        return "Call"
    }

    override var visible: Bool {
        return viewModel.callablePhoneNumbers!.count > 0
        && UIApplication.shared.canOpenURL(URL(string: "telprompt://")!)
        
    }

    override func action() {
        guard let phoneNumbers = viewModel.callablePhoneNumbers else {
            NSLog("CEEntryDetailTableController::PresentCallDialog::CouldNotEnumeratePhoneNumbers")
            return
        }

        // short-circuit
        if phoneNumbers.count == 1 {
            didSelectCallWithPhoneNumber(phoneNumber: phoneNumbers.first!.1)
            return
        }

        let sheet = UIAlertController(title: "Call", message: nil, preferredStyle: .actionSheet)
        for (label, number) in phoneNumbers {
            sheet.addAction(UIAlertAction(title: "\(label) \(number.stringValue)", style: .default, handler: { (action) in
                self.didSelectCallWithPhoneNumber(phoneNumber: number)
            }))
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        delegate.tableItemPresentViewController(viewController: sheet)
    }

    func didSelectCallWithPhoneNumber(phoneNumber: CNPhoneNumber) {
        if let phoneNumber = phoneNumber.value(forKey: "digits") as? String {
            UIApplication.shared.open(URL(string: "telprompt://\(phoneNumber)")!)
        }
        NSLog("CEEntryDetailViewController::TableControllerDidSelectCallWithPhoneNumber::CouldNotCallNumber: \(phoneNumber)")
    }
}

protocol CETableItemDelegate {
    func tableItemPresentViewController(viewController: UIViewController)
}
