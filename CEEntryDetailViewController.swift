//
//  CEEntryDetailView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-23.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit
import Darwin

class CEEntryDetailViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var detailBackgroundView: CEEntryDetailBackgroundView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceControl: UIStepper!
    @IBAction func balanceChanged(sender: AnyObject) {
        let value = balanceControl.value
        let intValue = value < 0 ? Int(value - 0.5) : Int(value + 0.5)
        viewModel.balance = intValue
    }

    var viewModel: CEEntryDetailViewModel!
    var delegate: CEEntryDetailDelegate?

    // It's assumed the model is initailized before this method is called,
    // i.e. before we're ready to display to the screen
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.addObserver(self, forKeyPath: CEEntry.balanceKey, options: [.New, .Initial], context: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObserver(self, forKeyPath: CEEntry.balanceKey)
        delegate?.detailWillDisappear(self, withEntry: viewModel.truth)
    }

    private func commonInit() {
        balanceControl.stepValue = 1.0
        balanceControl.minimumValue = -1.0 * (balanceControl.maximumValue)
        balanceControl.value = Double(viewModel.balance)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        guard let keyPath = keyPath else {
            NSLog("CEEntryDetailViewModel::ObserveValueForKeyPath::NilKeyPath")
            return
        }

        switch keyPath {
        case CEEntry.balanceKey:
            balanceLabel.text = viewModel.balanceText
            detailBackgroundView.pushView()
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
}

protocol CEEntryDetailDelegate {
    func detailWillDisappear(detail: CEEntryDetailViewController, withEntry entry: CEEntry)
}

