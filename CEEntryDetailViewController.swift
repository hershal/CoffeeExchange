//
//  CEEntryDetailView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-23.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import CoreLocation

class CEEntryDetailViewController: UIViewController {
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
        tableView.delegate = tableController
        tableView.dataSource = tableController
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CEEntryDetailCell")
    }

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

