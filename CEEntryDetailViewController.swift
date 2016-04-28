//
//  CEEntryDetailView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-23.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts
import MessageUI
import EventKit

class CEEntryDetailViewController: UIViewController, CEEntryDetailTableControllerDelegate, MFMessageComposeViewControllerDelegate, CEReminderControllerDelegate {
    @IBOutlet weak var picture: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var stepperSublabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableHeightConstriant: NSLayoutConstraint!

    @IBAction func stepperChanged(sender: AnyObject) {
        let value = stepper.value
        viewModel.balance = Int(value)
    }

    var viewModel: CEEntryDetailViewModel!
    var delegate: CEEntryDetailDelegate?
    var locationManager: CLLocationManager!
    var tableController: CEEntryDetailTableController!

    // It's assumed the model is initailized before this method is called,
    // i.e. before we're ready to display to the screen
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.value = Double(viewModel.balance)
        name.text = viewModel.truth.fullName
        locationManager = CLLocationManager()
        tableController = CEEntryDetailTableController(viewModel: viewModel)
        tableController.delegate = self
        tableView.delegate = tableController
        tableView.dataSource = tableController
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CEEntryDetailCell")
    }

    // MARK: - CEEntryDetailTableControllerDelegate Methods
    func tableControllerPresentViewController(viewController: UIViewController) {
        presentViewController(viewController, animated: true, completion: nil)
    }

    func tableControllerDidSelectCallWithPhoneNumber(phoneNumber: CNPhoneNumber) {
        if let number = phoneNumber.valueForKey("digits") as? String {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(number)")!)
        } else {
            NSLog("CEEntryDetailViewController::TableControllerDidSelectCallWithPhoneNumber::CouldNotCallNumber: \(phoneNumber)")
        }
    }

    func tableControllerDidSelectMessageWithPhoneNumber(phoneNumber: CNPhoneNumber) {
        if let number = phoneNumber.valueForKey("digits") as? String {
            if MFMessageComposeViewController.canSendText() {
                let messageController = MFMessageComposeViewController()
                messageController.recipients = [number]
                messageController.body = "Hey, let's get coffee!"
                messageController.messageComposeDelegate = self
                presentViewController(messageController, animated: true, completion: nil)
            } else {
                NSLog("CEEntryDetailViewController::TableControllerDidSelectCallWithPhoneNumber::CantSendTexts")
                let alert = UIAlertController(title: "Can't Send Messages", message: "Your device is not set up to send messages.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        } else {
            NSLog("CEEntryDetailViewController::TableControllerDidSelectCallWithPhoneNumber::CouldNotCallNumber: \(phoneNumber)")
        }
    }

    func tableControllerDidSelectRemindMeWithInterval(interval: CEReminderInterval) {
        print("remindMe \(interval)")
        let reminderController = CEReminderController(viewModel: viewModel)
        reminderController.delegate = self
        reminderController.createReminderWithInterval(interval)
    }

    // MARK: - MessageComposeViewControllerDelegate Methods
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - CEReminderControllerDelegate Methods
    func reminderController(reminderController: CEReminderController, couldNotCreateReminderWithError reminderError: CEReminderError) {
        let alert = UIAlertController(title: "Can't Create Reminder", message: "You have denied access to create reminders. Please enable access in Settings under Privacy.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    func reminderController(reminderController: CEReminderController, didCreateReminder reminder: EKReminder, inCalendar calendar: EKCalendar, withInterval interval: CEReminderInterval) {
        NSLog("created reminder")
    }

    // MARK: - UIView Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.addObserver(self, forKeyPath: CEEntry.balanceKey, options: [.New, .Initial], context: nil)
        stepper.value = Double(viewModel.balance)
        let numItems = tableController.tableView(tableView, numberOfRowsInSection: 0)
        self.tableHeightConstriant.constant = 44.0 * CGFloat(numItems)
        UIView.animateWithDuration(0.5) {
            self.tableView.layoutIfNeeded()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObserver(self, forKeyPath: CEEntry.balanceKey)
        delegate?.detailWillDisappear(self, withEntry: viewModel.truth)
    }

    // MARK: - ObjC methods
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        guard let keyPath = keyPath else {
            NSLog("CEEntryDetailViewModel::ObserveValueForKeyPath::NilKeyPath")
            return
        }

        switch keyPath {
        case CEEntry.balanceKey:
            stepperLabel.text = viewModel.balanceText
            stepperSublabel.text = viewModel.balanceSubtext
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}

protocol CEEntryDetailDelegate {
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry)
}


