//
//  CEEntryDetailView.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-23.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import UIKit

class CEEntryDetailViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceControl: UIStepper!
    @IBAction func balanceChanged(sender: AnyObject) {
        let value = balanceControl.value
        entry.balance = value < 0 ? Int(value - 0.5) : Int(value + 0.5)
        refreshView()
    }

    var entry: CEEntry!

    func refreshView() {
        if self.viewIfLoaded != nil {
            balanceLabel.text = "\(entry.balance)"
            self.title = "\(entry.contact.givenName) \(entry.contact.familyName)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        refreshView()
    }

    func commonInit() {
        balanceControl.stepValue = 1.0
        balanceControl.minimumValue = -1.0 * (balanceControl.maximumValue)
        balanceControl.value = Double(entry.balance)
    }
}

class CEEntryDetailBackgroundView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
